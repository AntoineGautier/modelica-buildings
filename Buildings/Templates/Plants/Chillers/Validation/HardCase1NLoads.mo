within Buildings.Templates.Plants.Chillers.Validation;
model HardCase1NLoads
  "Validation of chiller plant template with a distributed set of terminal loads"
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and CW)";

  parameter Integer nLoa(final min=1) = 12
    "Number of terminal loads connected in parallel on the CHW loop"
    annotation(Evaluate=true);
  parameter Modelica.Units.SI.PressureDifference dpTer_nominal(
    displayUnit="Pa") = 3E4
    "Liquid pressure drop across terminal unit at design conditions";
  parameter Modelica.Units.SI.PressureDifference dpValve_nominal(
    displayUnit="Pa") = dpTer_nominal
    "Terminal unit control valve pressure drop at design conditions";
  parameter Boolean allowFlowReversal = true
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation(Dialog(tab="Assumptions"),
      Evaluate=true);
  parameter Modelica.Fluid.Types.Dynamics energyDynamics =
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true,
      Dialog(tab="Dynamics",
        group="Conservation equations"));
  replaceable Buildings.Templates.Plants.Chillers.WaterCooled pla(
    redeclare final package MediumCon=Medium,
    chi(have_senTConWatChiSup=true, have_senTConWatChiRet_select=true),
    redeclare replaceable Buildings.Templates.Plants.Chillers.Components.Economizers.HeatExchangerWithValve eco
      "Heat exchanger with bypass valve for CHW flow control",
    ctl(
      locSenFloChiWatPri=Buildings.Templates.Plants.Chillers.Types.SensorLocation.Supply,
      have_senDpChiWatRemWir=false,
      typCtlHea=Buildings.Controls.OBC.ASHRAE.G36.Plants.Chillers.Types.HeadPressureControl.ByChiller))
    constrainedby Buildings.Templates.Plants.Chillers.Interfaces.PartialChilledWaterLoop(
      redeclare final package MediumChiWat=Medium,
      nChi=2,
      nAirHan=1,
      final energyDynamics=energyDynamics,
      final allowFlowReversal=allowFlowReversal,
      final dat=datAll.pla,
      show_T=true,
      chi(have_senTChiWatChiSup_select=true, have_senTChiWatChiRet=true))
    "Chiller plant"
    annotation(Placement(transformation(extent={{-80,-100},{-40,-60}})));
  /*
   * HACK(AntoineGautier):
   * Keep 'datAll' declared after 'pla' below.
   * With Dymola 2026x Refresh 1, declaring 'datAll' *before* 'pla' yields a
   * 6x overhead in checkModel/translateModel, see the same comment in
   * Buildings.Templates.Plants.Chillers.Validation.WaterCooled.
   */
  replaceable parameter Buildings.Templates.Plants.Chillers.Validation.UserProject.Data.AllSystemsWaterCooled datAll(
    pla(cfg=pla.cfg))
    "Plant parameters"
    annotation(Placement(transformation(extent={{-180,120},{-160,140}})));
  final parameter Modelica.Units.SI.PressureDifference dpChiWatDis_nominal(
    displayUnit="Pa") = Buildings.Templates.Data.Defaults.dpChiWatLocSet_max -
    max(datAll.pla.ctl.dpChiWatRemSet_max)
    "CHW distribution piping pressure drop at design flow, supply and return combined";
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam=Modelica.Utilities.Files.loadResource(
      "modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    "Outdoor conditions"
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=0,
      origin={-170,-40})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant TAirSup(
    k=293.15,
    y(final unit="K", displayUnit="degC"))
    "Placeholder signal for request generator"
    annotation(Placement(transformation(extent={{-180,70},{-160,90}})));
  Buildings.Fluid.Sensors.RelativePressure dpChiWatRem[1](
    redeclare each final package Medium=Medium)
    "CHW differential pressure at one remote location"
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=-90,
      origin={120,-80})));
  Buildings.Controls.OBC.ASHRAE.G36.AHUs.MultiZone.VAV.SetPoints.PlantRequests reqPlaRes(
    final heaCoi=Buildings.Controls.OBC.ASHRAE.G36.Types.HeatingCoil.None,
    final cooCoi=Buildings.Controls.OBC.ASHRAE.G36.Types.CoolingCoil.WaterBased)
    "Plant and reset request"
    annotation(Placement(transformation(extent={{90,50},{70,70}})));
  Buildings.Templates.AirHandlersFans.Interfaces.Bus busAirHan
    "AHU control bus"
    annotation(Placement(transformation(extent={{-60,40},{-20,80}}),
      iconTransformation(extent={{-340,-140},{-300,-100}})));
  Buildings.Templates.Plants.HeatPumps.Interfaces.Bus busPla
    "Plant control bus"
    annotation(Placement(transformation(extent={{-100,-40},{-60,0}}),
      iconTransformation(extent={{-370,-70},{-330,-30}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.TimeTable ratLoa(
    table=[0, 0; 5, 0; 7, 0; 12, 0.2; 16, 1; 22, 0.1; 24, 0],
    timeScale=3600)
    "Fraction of design load"
    annotation(Placement(transformation(extent={{-180,30},{-160,50}})));
  Buildings.Fluid.Sensors.MassFlowRate mChiWat_flow(
    redeclare final package Medium=Medium)
    "CHW mass flow rate"
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=180,
      origin={0,-120})));
  Buildings.Controls.OBC.CDL.Integers.Multiply mulInt[2]
    "Importance multiplier"
    annotation(Placement(transformation(extent={{0,50},{-20,70}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant cst[2](each k=10)
    "Request multiplier factor"
    annotation(Placement(transformation(extent={{40,90},{20,110}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant schEna(k=true)
    "Plant enable schedule"
    annotation(Placement(transformation(extent={{-180,-10},{-160,10}})));
  Buildings.Fluid.FixedResistances.PressureDrop pipChiWatSup[nLoa](
    redeclare each final package Medium=Medium,
    final m_flow_nominal={pla.mChiWat_flow_nominal * (nLoa - i + 1) / nLoa
      for i in 1:nLoa},
    each final dp_nominal=dpChiWatDis_nominal / (2 * nLoa))
    "CHW supply main – Segment i feeds the branch of terminal unit i"
    annotation(Placement(transformation(extent={{30,-90},{50,-70}})));
  Buildings.Fluid.FixedResistances.PressureDrop pipChiWatRet[nLoa](
    redeclare each final package Medium=Medium,
    final m_flow_nominal={pla.mChiWat_flow_nominal * (nLoa - i + 1) / nLoa
      for i in 1:nLoa},
    each final dp_nominal=dpChiWatDis_nominal / (2 * nLoa))
    "CHW return main – Segment i drains the branch of terminal unit i"
    annotation(Placement(transformation(extent={{50,-130},{30,-110}})));
  Buildings.Templates.Components.Loads.LoadTwoWayValve loa[nLoa](
    redeclare each final package MediumLiq=Medium,
    each final energyDynamics=energyDynamics,
    each final typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Cooling,
    each final mLiq_flow_nominal=pla.mChiWat_flow_nominal / nLoa,
    each final dpTer_nominal=dpTer_nominal,
    each final dpValve_nominal=dpValve_nominal,
    final dpBal1_nominal={datAll.pla.ctl.dpChiWatRemSet_max[1] - dpTer_nominal -
      dpValve_nominal + (nLoa - i) * dpChiWatDis_nominal / nLoa for i in 1:nLoa},
    each final TLiqEnt_nominal=pla.TChiWatSup_nominal,
    each final TLiqLvg_nominal=pla.TChiWatRet_nominal,
    each con(val(y_start=0)))
    "Cooling loads"
    annotation(Placement(transformation(extent={{70,-90},{90,-70}})));
  Buildings.Controls.OBC.CDL.Reals.MultiMax yVal_max(nin=nLoa)
    "Maximum cooling coil valve position"
    annotation(Placement(transformation(extent={{130,-30},{150,-10}})));
  Buildings.Fluid.MixingVolumes.MixingVolume vol(
    redeclare package Medium=Medium,
    final energyDynamics=energyDynamics,
    final m_flow_nominal=pla.mChiWat_flow_nominal,
    V=Buildings.Templates.Data.Defaults.ratVLiqByCap * pla.cap_nominal,
    nPorts=2)
    "Fluid volume in distribution system"
    annotation(Placement(transformation(extent={{-10,-70},{10,-90}})));
equation
  // Distribution mains: terminal unit 1 is the closest to the plant,
  // terminal unit nLoa the most remote.
  for i in 1:(nLoa - 1) loop
    connect(pipChiWatSup[i].port_b, pipChiWatSup[i + 1].port_a)
      annotation(Line(points={{50,-80},{30,-80}},
        color={0,127,255}));
    connect(pipChiWatRet[i + 1].port_b, pipChiWatRet[i].port_a)
      annotation(Line(points={{30,-120},{50,-120}},
        color={0,127,255}));
  end for;
  for i in 1:nLoa loop
    connect(pipChiWatSup[i].port_b, loa[i].port_a)
      annotation(Line(points={{50,-80},{70,-80}},
        color={0,127,255}));
    connect(loa[i].port_b, pipChiWatRet[i].port_a)
      annotation(Line(points={{90,-80},{100,-80},{100,-120},{50,-120}},
        color={0,127,255}));
    connect(ratLoa.y[1], loa[i].u)
      annotation(Line(points={{-158,40},{60,40},{60,-72},{68,-72}},
        color={0,0,127}));
    connect(schEna.y, loa[i].u1)
      annotation(Line(points={{-158,0},{56,0},{56,-76},{68,-76}},
        color={255,0,255}));
  end for;
  connect(weaDat.weaBus, pla.busWea)
    annotation(Line(points={{-160,-40},{-60,-40},{-60,-60}},
      color={255,204,51},
      thickness=0.5));
  connect(TAirSup.y, reqPlaRes.TAirSup)
    annotation(Line(points={{-158,80},{100,80},{100,68},{92,68}},
      color={0,0,127}));
  connect(TAirSup.y, reqPlaRes.TAirSupSet)
    annotation(Line(points={{-158,80},{100,80},{100,63},{92,63}},
      color={0,0,127}));
  connect(busAirHan, pla.busAirHan[1])
    annotation(Line(points={{-40,60},{-40,-66}},
      color={255,204,51},
      thickness=0.5));
  connect(pla.bus, busPla)
    annotation(Line(points={{-80,-70},{-80,-20}},
      color={255,204,51},
      thickness=0.5));
  connect(cst.y, mulInt.u1)
    annotation(Line(points={{18,100},{6,100},{6,66},{2,66}},
      color={255,127,0}));
  connect(mulInt[1].y, busAirHan.reqResChiWat)
    annotation(Line(points={{-22,60},{-40,60}},
      color={255,127,0}));
  connect(mulInt[2].y, busAirHan.reqPlaChiWat)
    annotation(Line(points={{-22,60},{-40,60}},
      color={255,127,0}));
  connect(reqPlaRes.yChiWatResReq, mulInt[1].u2)
    annotation(Line(points={{68,68},{12,68},{12,54},{2,54}},
      color={255,127,0}));
  connect(reqPlaRes.yChiPlaReq, mulInt[2].u2)
    annotation(Line(points={{68,63},{12,63},{12,54},{2,54}},
      color={255,127,0}));
  connect(schEna.y, busPla.u1SchEna)
    annotation(Line(points={{-158,0},{-80,0},{-80,-20}},
      color={255,0,255}));
  connect(dpChiWatRem.p_rel, busPla.dpChiWatRem)
    annotation(Line(points={{111,-80},{20,-80},{20,-20},{-80,-20}},
      color={0,0,127}),
      Text(string="%second",
        index=1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
  // The remote differential pressure sensor is located just upstream of the
  // last connected terminal unit.
  connect(pipChiWatSup[nLoa].port_b, dpChiWatRem[1].port_a)
    annotation(Line(points={{50,-80},{120,-80},{120,-70}},
      color={0,127,255}));
  connect(pipChiWatRet[nLoa].port_a, dpChiWatRem[1].port_b)
    annotation(Line(points={{50,-120},{120,-120},{120,-90}},
      color={0,127,255}));
  connect(loa.yVal_actual, yVal_max.u)
    annotation(Line(points={{92,-72},{128,-72},{128,-20}},
      color={0,0,127}));
  connect(yVal_max.y, reqPlaRes.uCooCoiSet)
    annotation(Line(points={{152,-20},{160,-20},{160,57},{92,57}},
      color={0,0,127}));
  connect(pla.port_b, vol.ports[1])
    annotation(Line(points={{-39.8,-80},{-20,-80},{-1,-80}},
      color={0,127,255}));
  connect(vol.ports[2], pipChiWatSup[1].port_a)
    annotation(Line(points={{1,-80},{30,-80}},
      color={0,127,255}));
  connect(pipChiWatRet[1].port_b, mChiWat_flow.port_a)
    annotation(Line(points={{30,-120},{10,-120}},
      color={0,127,255}));
  connect(mChiWat_flow.port_b, pla.port_a)
    annotation(Line(points={{-10,-120},{-20,-120},{-20,-90},{-39.8,-90}},
      color={0,127,255}));
annotation(
  experiment(StopTime=86400,
    Tolerance=1e-06,
    __Dymola_Algorithm="Cvode"),
  Documentation(
    info="<html>
<p>
  This model is a variant of
  <a href=\"modelica://Buildings.Templates.Plants.Chillers.Validation.HardCase1\">
    Buildings.Templates.Plants.Chillers.Validation.HardCase1</a>
  in which the single aggregated load of the CHW loop is replaced by
  <code>nLoa</code> terminal units distributed along a supply and a return
  main. It is used to assess how the cost of the plant hydraulic equations
  scales with the number of components exposed to the plant supply pressure.
</p>
<p>
  Terminal unit <i>1</i> is the closest to the plant, terminal unit
  <code>nLoa</code> the most remote. Each main is split into <code>nLoa</code>
  segments of equal design pressure drop, each sized for the flow rate it
  carries at design conditions. The total pressure drop of the two mains and
  the pressure drop of the most remote branch are independent of
  <code>nLoa</code> and equal to those of the aggregated load model, so the
  design operating point of the plant is unchanged. The primary balancing
  valve of each branch absorbs the additional pressure available closer to the
  plant.
</p>
<p>
  The remote differential pressure sensor is located just upstream of the last
  connected terminal unit. The plant requests and reset requests are generated
  from the maximum valve position over all terminal units.
</p>
</html>",
    revisions="<html>
<ul>
<li>
September 21, 2026, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"),
  Diagram(coordinateSystem(extent={{-200,-160},{200,160}})));
end HardCase1NLoads;
