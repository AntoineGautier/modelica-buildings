within Buildings.Applications.DHC.EnergyTransferStations.FifthGeneration;
model Chiller
  "Energy transfer station model for fifth generation DHC systems with heat recovery chiller"
  extends DHC.EnergyTransferStations.BaseClasses.PartialETS(
    final have_heaWat=true,
    final have_chiWat=true,
    have_hotWat=false,
    have_eleHea=false,
    final have_eleCoo=true,
    final have_fan=false,
    have_weaBus=false,
    final have_pum=true,
    nPorts_aHeaWat=1,
    nPorts_bHeaWat=1,
    nPorts_aChiWat=1,
    nPorts_bChiWat=1);

  parameter Boolean have_val1Hex=false
    "Set to true in case of control valve on district side, false in case of a pump"
    annotation(Evaluate=true);
  parameter Integer nAuxHea = 0
    "Number of auxiliary heating system"
    annotation(Evaluate=true);
  parameter Integer nAuxCoo = 0
    "Number of auxiliary cooling system"
    annotation(Evaluate=true);
  parameter Integer nAuxSou = 0
    "Number of auxiliary heat sources"
    annotation(Evaluate=true);

  parameter Modelica.SIunits.PressureDifference dp1Hex_nominal(displayUnit="Pa")
    "Nominal pressure drop on primary side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.PressureDifference dp2Hex_nominal(displayUnit="Pa")
    "Nominal pressure drop on secondary side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.HeatFlowRate QHex_flow_nominal
    "Nominal heat flow rate through heat exchanger (from district to building)"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.Temperature T_a1Hex_nominal
    "Nominal water inlet temperature on district side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.Temperature T_b1Hex_nominal
    "Nominal water outlet temperature on district side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.Temperature T_a2Hex_nominal
    "Nominal water inlet temperature on building side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  parameter Modelica.SIunits.Temperature T_b2Hex_nominal
    "Nominal water outlet temperature on building side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  final parameter Modelica.SIunits.MassFlowRate m1Hex_flow_nominal=
    hex.m1_flow_nominal
    "Nominal mass flow rate on primary side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));
  final parameter Modelica.SIunits.MassFlowRate m2Hex_flow_nominal=
    hex.m2_flow_nominal
    "Nominal mass flow rate on secondary side of heat exchanger"
    annotation (Dialog(group="District heat exchanger"));

  parameter Modelica.Fluid.Types.Dynamics fixedEnergyDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Formulation of energy balance for mixing volume at inlet and outlet"
    annotation (Dialog(tab="Dynamics"));

  parameter Modelica.SIunits.PressureDifference dpCon_nominal(displayUnit="Pa")
    "Nominal pressure drop accross condenser"
    annotation (Dialog(group="Chiller"));
  parameter Modelica.SIunits.PressureDifference dpEva_nominal(displayUnit="Pa")
    "Nominal pressure drop accross evaporator"
    annotation (Dialog(group="Chiller"));
  parameter Fluid.Chillers.Data.ElectricEIR.Generic datChi
    "Chiller performance data"
    annotation (Dialog(group="Chiller"),
      Placement(transformation(extent={{-10,222},{10,242}})));

  final parameter Modelica.SIunits.Volume VTanHeaWat=
    datChi.PLRMin * datChi.mCon_flow_nominal * 5 * 60 / 1000
    "Heating water tank volume (minimum cycling period of 5')"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Modelica.SIunits.Length hTanHeaWat=
    (VTanHeaWat * 16 / Modelica.Constants.pi)^(1/3)
    "Heating water tank height (assuming twice the diameter)"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Modelica.SIunits.Length dInsTanHeaWat = 0.1
    "Heating water tank insulation thickness"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Modelica.SIunits.Volume VTanChiWat=
    datChi.PLRMin * datChi.mEva_flow_nominal * 5 * 60 / 1000
    "Chilled water tank volume (minimum cycling period of 5')"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Modelica.SIunits.Length hTanChiWat=
    (VTanChiWat * 16 / Modelica.Constants.pi)^(1/3)
    "Chilled water tank height (without insulation)"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Modelica.SIunits.Length dInsTanChiWat = 0.1
    "Chilled water tank insulation thickness"
    annotation (Dialog(group="Buffer Tank"));
  final parameter Integer nSegTan = 3
    "Number of volume segments for tanks"
    annotation (Dialog(group="Buffer Tank"));
  parameter Modelica.SIunits.TemperatureDifference THys = 1
    "Temperature hysteresis for supervisory control"
    annotation (Dialog(group="Buffer Tank"));

  parameter Modelica.SIunits.PressureDifference dpValIso_nominal(
    displayUnit="Pa") = 2E3
    "Nominal pressure drop of ambient circuit isolation valves"
    annotation (Dialog(group="Generic"));

  // IO VARIABLES
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupSet(
    final unit="K", displayUnit="degC")
    "Heating water supply temperature set-point"
    annotation (Placement(transformation(extent={{-340,0},{-300,40}}),
      iconTransformation(extent={{-380,-40},{-300,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(
    final unit="K", displayUnit="degC")
    "Chilled water supply temperature set-point (may be reset down)"
    annotation (Placement(transformation(extent={{-340,-40},{-300,0}}),
      iconTransformation(extent={{-380,-200},{-300,-120}})));

  // COMPONENTS
  FifthGeneration.Controls.Supervisory conSup(
    final THys=THys)
    "Supervisory controller"
    annotation (Placement(transformation(extent={{-260,40},{-240,60}})));

  Fluid.Actuators.Valves.TwoWayLinear valIsoEva(
    redeclare final package Medium = MediumBui,
    final dpValve_nominal=dpValIso_nominal,
    final m_flow_nominal=sum(colAmbWat.mCon_flow_nominal))
    "Evaporator to ambient loop isolation valve"
    annotation (Placement(transformation(extent={{90,-110},{70,-90}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCon(
    redeclare final package Medium = MediumBui,
    final dpValve_nominal=dpValIso_nominal,
    final m_flow_nominal=sum(colAmbWat.mCon_flow_nominal))
    "Condenser to ambient loop isolation valve"
    annotation (Placement(transformation(extent={{-90,-110},{-70,-90}})));

  BaseClasses.Chiller chi(
    redeclare final package Medium = MediumBui,
    final dpCon_nominal=dpCon_nominal,
    final dpEva_nominal=dpEva_nominal,
    final dat=datChi)
    "Base subsystem with heat recovery chiller"
    annotation (Placement(transformation(extent={{-8,-10},{12,10}})));
  BaseClasses.HeatExchanger hex(
    redeclare final package Medium1 = MediumDis,
    redeclare final package Medium2 = MediumBui,
    final allowFlowReversal1=allowFlowReversalDis,
    final allowFlowReversal2=allowFlowReversalBui,
    final have_val1Hex=have_val1Hex,
    final dp1Hex_nominal=dp1Hex_nominal,
    final dp2Hex_nominal=dp2Hex_nominal,
    final QHex_flow_nominal=QHex_flow_nominal,
    final T_a1Hex_nominal=T_a1Hex_nominal,
    final T_b1Hex_nominal=T_b1Hex_nominal,
    final T_a2Hex_nominal=T_a2Hex_nominal,
    final T_b2Hex_nominal=T_b2Hex_nominal)
    "Base subsystem with district heat exchanger"
    annotation (Placement(transformation(extent={{-10,-244},{10,-264}})));

  BaseClasses.StratifiedTank tanChiWat(
    redeclare final package Medium = MediumBui,
    final m_flow_nominal=datChi.mEva_flow_nominal,
    final VTan=VTanChiWat,
    final hTan=hTanChiWat,
    final dIns=dInsTanChiWat,
    final nSeg=nSegTan)
    "Chilled water tank"
    annotation (Placement(transformation(extent={{200,96},{220,116}})));
  BaseClasses.StratifiedTank tanHeaWat(
    redeclare final package Medium = MediumBui,
    final m_flow_nominal=datChi.mCon_flow_nominal,
    final VTan=VTanHeaWat,
    final hTan=hTanHeaWat,
    final dIns=dInsTanHeaWat,
    final nSeg=nSegTan)
    "Heating water tank"
    annotation (Placement(transformation(extent={{-220,96},{-200,116}})));
  Buildings.Applications.DHC.EnergyTransferStations.BaseClasses.CollectorDistributor
    colAmbWat(
      redeclare final package Medium = MediumBui,
      final nCon=1 + nAuxSou,
      final allowFlowReversal=true,
      mCon_flow_nominal={m2Hex_flow_nominal})
    "Collector/distributor for ambient water"
    annotation (Placement(
      transformation(
      extent={{20,-10},{-20,10}},
      rotation=180,
      origin={0,-106})));
  Buildings.Applications.DHC.EnergyTransferStations.BaseClasses.CollectorDistributor
    colChiWat(
      redeclare final package Medium = MediumBui,
      final nCon=1 + nAuxCoo,
      final allowFlowReversal=true,
      mCon_flow_nominal={m2Hex_flow_nominal})
    "Collector/distributor for chilled water"
    annotation (Placement(
      transformation(
      extent={{20,-10},{-20,10}},
      rotation=180,
      origin={108,0})));
  Buildings.Applications.DHC.EnergyTransferStations.BaseClasses.CollectorDistributor
    colHeaWat(
      redeclare final package Medium = MediumBui,
      final nCon=1 + nAuxHea,
      final allowFlowReversal=true,
      mCon_flow_nominal={m2Hex_flow_nominal})
    "Collector/distributor for heating water"
    annotation (Placement(
      transformation(
      extent={{-20,-10},{20,10}},
      rotation=180,
      origin={-108,0})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum totPPum(nin=2)
    "Total pump power"
    annotation (Placement(transformation(extent={{262,-70},{282,-50}})));
equation
  connect(hex.PPum, totPPum.u[2]) annotation (Line(
      points={{11,-254},{40,-254},{40,-62},{260,-62},{260,-61}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(chi.PPum, totPPum.u[1]) annotation (Line(
      points={{13,-3},{40,-3},{40,-59},{260,-59}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(THeaWatSupSet, conSup.THeaWatSupSet) annotation (Line(points={{-320,20},
          {-280,20},{-280,58},{-262,58}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TChiWatSupSet, conSup.TChiWatSupSet) annotation (Line(points={{-320,-20},
          {-276,-20},{-276,49},{-262,49}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conSup.yIsoEva, valIsoEva.y) annotation (Line(points={{-238,43},{-198,
          43},{-198,-80},{80,-80},{80,-88}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conSup.yIsoCon, valIsoCon.y) annotation (Line(points={{-238,46},{-194,
          46},{-194,-76},{-80,-76},{-80,-88}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(port_aDis, hex.port_a1) annotation (Line(points={{-300,-260},{-10,-260}},
                  color={0,127,255}));
  connect(hex.port_b1, port_bDis) annotation (Line(points={{10,-260},{300,-260}},
                                                              color={0,127,255}));
  connect(conSup.yHea, chi.uHea) annotation (Line(points={{-238,58},{-40,58},{-40,
          3},{-10,3}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(conSup.yCoo, chi.uCoo) annotation (Line(points={{-238,55},{-140,55},{-140,
          54},{-44,54},{-44,1},{-10,1}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(THeaWatSupSet, chi.THeaWatSupSet) annotation (Line(points={{-320,20},{
          -42,20},{-42,-1},{-10,-1}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TChiWatSupSet, chi.TChiWatSupSet) annotation (Line(points={{-320,-20},
          {-40,-20},{-40,-3},{-10,-3}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conSup.yHeaRej, hex.uHeaRej) annotation (Line(points={{-238,52},{-186,
          52},{-186,-256},{-12,-256}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(conSup.yColRej, hex.uColRej) annotation (Line(points={{-238,49},{-190,
          49},{-190,-252},{-12,-252}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(ports_aHeaWat[1], tanHeaWat.port_aBot) annotation (Line(points={{-300,
          260},{-280,260},{-280,100},{-220,100}}, color={0,127,255}));
  connect(tanHeaWat.port_bTop, ports_bHeaWat[1]) annotation (Line(points={{-220,
          112},{-260,112},{-260,260},{300,260}}, color={0,127,255}));
  connect(tanHeaWat.TTop, conSup.THeaWatTop) annotation (Line(points={{-199,115},
          {-180,115},{-180,82},{-274,82},{-274,55},{-262,55}}, color={0,0,127},
      pattern=LinePattern.Dash));

  connect(tanHeaWat.TBot, conSup.THeaWatBot) annotation (Line(points={{-199,97},
          {-182,97},{-182,84},{-276,84},{-276,52},{-262,52}},  color={0,0,127},
      pattern=LinePattern.Dash));

  connect(tanChiWat.TTop, conSup.TChiWatTop) annotation (Line(points={{221,115},
          {238,115},{238,80},{-272,80},{-272,46},{-262,46}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(tanChiWat.TBot, conSup.TChiWatBot) annotation (Line(points={{221,97},{
          240,97},{240,78},{-270,78},{-270,43},{-262,43}},   color={0,0,127},
      pattern=LinePattern.Dash));
  connect(hex.port_b2, colAmbWat.ports_aCon[1]) annotation (Line(points={{-10,-248},
          {-20,-248},{-20,-140},{12,-140},{12,-116}}, color={0,127,255}));
  connect(chi.port_bChiWat, colChiWat.port_aDisSup) annotation (Line(points={{12,6},{
          60,6},{60,1.77636e-15},{88,1.77636e-15}},
                                        color={0,127,255}));
  connect(colChiWat.port_bDisSup, tanChiWat.port_aBot) annotation (Line(points={{128,
          -3.10862e-15},{160,-3.10862e-15},{160,100},{200,100}},
                                                  color={0,127,255}));
  connect(tanChiWat.port_bTop, colChiWat.port_aDisRet) annotation (Line(points={{200,112},
          {140,112},{140,6},{128,6}},             color={0,127,255}));
  connect(chi.port_aChiWat, colChiWat.port_bDisRet) annotation (Line(points={{12,-6},
          {80,-6},{80,6},{88,6}},       color={0,127,255}));
  connect(colChiWat.ports_bCon[1], valIsoEva.port_a) annotation (Line(points={{96,-10},
          {100,-10},{100,-100},{90,-100}},    color={0,127,255}));
  connect(valIsoCon.port_b, colAmbWat.port_bDisRet)
    annotation (Line(points={{-70,-100},{-20,-100}}, color={0,127,255}));
  connect(colAmbWat.port_aDisRet, valIsoEva.port_b)
    annotation (Line(points={{20,-100},{70,-100}}, color={0,127,255}));
  connect(colAmbWat.port_bDisSup, colChiWat.ports_aCon[1]) annotation (Line(
        points={{20,-106},{28,-106},{28,-120},{120,-120},{120,-10}},color={0,127,
          255}));
  connect(chi.port_bHeaWat, colHeaWat.port_aDisSup) annotation (Line(points={{-8,6},{
          -60,6},{-60,-1.77636e-15},{-88,-1.77636e-15}},
                                           color={0,127,255}));
  connect(colHeaWat.port_bDisSup, tanHeaWat.port_aTop) annotation (Line(points={{-128,
          3.10862e-15},{-140,3.10862e-15},{-140,112},{-200,112}},
                                                      color={0,127,255}));
  connect(colHeaWat.ports_bCon[1], valIsoCon.port_a) annotation (Line(points={{-96,-10},
          {-100,-10},{-100,-100},{-90,-100}},    color={0,127,255}));
  connect(colAmbWat.port_aDisSup, colHeaWat.ports_aCon[1]) annotation (Line(
        points={{-20,-106},{-30,-106},{-30,-120},{-120,-120},{-120,-10}},color={
          0,127,255}));
  connect(colHeaWat.port_bDisRet, chi.port_aHeaWat) annotation (Line(points={{-88,6},
          {-80,6},{-80,-6},{-8,-6}},      color={0,127,255}));
  connect(tanHeaWat.port_bBot, colHeaWat.port_aDisRet) annotation (Line(points={{-200,
          100},{-160,100},{-160,6},{-128,6}},         color={0,127,255}));
  connect(hex.port_a2, colAmbWat.ports_bCon[1]) annotation (Line(points={{10,-248},
          {20,-248},{20,-130},{-12,-130},{-12,-116}}, color={0,127,255}));
  connect(tanChiWat.port_bBot, ports_bChiWat[1]) annotation (Line(points={{220,100},
          {280,100},{280,200},{300,200}}, color={0,127,255}));
  connect(ports_aChiWat[1], tanChiWat.port_aTop) annotation (Line(points={{-300,
          200},{260,200},{260,112},{220,112}}, color={0,127,255}));
  connect(totPPum.y, PPum) annotation (Line(points={{284,-60},{320,-60}},
                      color={0,0,127}));
  connect(chi.PChi, PCoo) annotation (Line(
      points={{13,3},{20,3},{20,20},{320,20}},
      color={0,0,127},
      pattern=LinePattern.Dot));
annotation (Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false,
                  extent={{-300,-300},{300,300}}),
                  graphics={Line(
                  points={{86,92}},
                  color={28,108,200},
                  pattern=LinePattern.Dash)}),
        defaultComponentName="ets",
Documentation(info="<html>
<p>
This models represents an energy transfer station (ETS) for fifth generation
district heating and cooling systems.
The control logic is based on five operating modes:
</p>
<ul>
<li>
heating only,
</li>
<li>
cooling only,
</li>
<li>
simultaneous heating and cooling,
</li>
<li>
part surplus heat or cold rejection,
</li>
<li>
full surplus heat or cold rejection.
</li>
</ul>
<p align=\"center\">
<img alt=\"Image the 5th generation of district heating and cooling substation\"
src=\"modelica://Buildings/Resources/Images/Applications/DHC/EnergyTransferStations/SubstationModifiedLayout.png\"/>
<p>
The substation layout consists in three water circuits:
</p>
<ol>
<li>
the heating water circuit, which is connected to the building heating water
distribution system,
</li>
<li>
the chilled water circuit, which is connected to the building chilled water
distribution system,
</li>
<li>
the ambient water circuit, which is connected to the district heat exchanger
(and optionally to the geothermal borefield).
</li>
</ol>
<h4>Heating water circuit</h4>
<p>
It satisfies the building heating requirements and consists in:
</p>
<ol>
<li>
the heating/cooling generating source, where the EIR chiller i.e. condenser heat exchanger operates to satisfy the heating setpoint
<code>TSetHea</code>.
</li>
<li>
The constant speed condenser water pump <code>pumCon</code>.
</li>
<li>
The hot buffer tank, is implemented to provide hydraulic decoupling between the primary (the ETS side) and secondary (the building side)
water circulators i.e. pumps and to eliminate the cycling of the heat generating source machine i.e EIR chiller.
</li>
<li>
Modulating mixing three way valve <code>valCon</code> to control the condenser entering water temperature.
</li>
</ol>
<h4>Chilled water circuit</h4>
<p>
It operates to satisfy the building cooling requirements and consists of
</p>
<ol>
<li>
The heating/cooling generating source, where the  EIR chiller i.e evaporator heat
exchanger operates to satisfy the cooling setpoint <code>TSetCoo</code>.
</li>
<li>
The constant speed evaporator water pump <code>pumEva</code>.
</li>
<li>
The chilled water buffer tank, is implemented obviously for the same mentioned reasons of the hot buffer tank.
</li>
<li>
Modulating mixing three way valve <code>valEva</code> to control the evaporator entering water temperature.
</li>
</ol>
<p>
For more detailed description of
</p>
<p>
The controller of heating/cooling generating source, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.ChillerController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.ChillerController.</a>
</p>
<p>
The evaporator pump <code>pumEva</code> and the condenser pump <code>pumCon</code>, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.PrimaryPumpsConstantSpeed\">
Buildings.Applications.DHC.EnergyTransferStations.Control.PrimaryPumpsConstantSpeed.</a>
</p>
<h4>Ambient water circuit</h4>
<p>
The ambient water circuit operates to maximize the system exergy by rejecting surplus i.e. heating or cooling energy
first to the borefield system and second to either or both of the borefield and the district systems.
It consists of
</p>
<ol>
<li>
The borefield component model <code>borFie</code>.
</li>
<li>
The borefield pump <code>pumBor</code>, where its mass flow rate is modulated using a reverse action PI controller.
</li>
<li>
Modulating mixing three way valve <code>valBor</code> to control the borefield entering water temperature.
</li>
<li>
The heat exchanger component model <code>hex</code>.
</li>
<li>
The heat exchanger district pump <code>pumHexDis</code>, where its mass flow rate is modulated using a reverse action PI controller.
</li>
<li>
Two on/off 2-way valves <code> valHea</code>, <code>valCoo</code>
which separates the ambient from the chilled water and heating water circuits.
</ol>
<p>
For more detailed description of the ambient circuit control concept see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.AmbientCircuitController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.AmbientCircuitController.</a>
</p>
<h4>Notes</h4>
<p>
For more detailed description of the finite state machines which transitions the ETS between
different operational modes, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.HotSideController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.HotSideController</a> and
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.ColdSideController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.ColdSideController</a>.
</p>

</html>", revisions="<html>
<ul>
<li>
January 18, 2020, by Hagar Elarga: <br/>
First implementation
</li>
</ul>
</html>"));
end Chiller;
