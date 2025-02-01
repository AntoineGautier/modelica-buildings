within Buildings.Fluid.HydronicConfigurations.Examples;
model LaBrulatte
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water
    "Medium model for hot water";
  package MediumAir = Buildings.Media.Air
    "Medium model for air";

  parameter Boolean have_valSub = false
    annotation(Evaluate=true);
  parameter Boolean have_tanSub=true
    annotation(Evaluate=true);

  parameter Modelica.Units.SI.Temperature TSup_nominal=338.15;
  parameter Modelica.Units.SI.Temperature TRet_nominal=323.15;
  parameter Modelica.Units.SI.Temperature TPlcSup_nominal=313.15;
  parameter Modelica.Units.SI.Temperature TPlcRet_nominal=308.15;
  parameter Modelica.Units.SI.HeatFlowRate QBoi_flow_nominal =
    85E3 / (5160 / 3600 / 1000 * Medium.d_const) * mPri_flow_nominal
    "Boiler capacity (scaled down from 85E3)";
  parameter Modelica.Units.SI.MassFlowRate mBoi_flow_nominal =
    QBoi_flow_nominal / (TSup_nominal - TRet_nominal) /
    Medium.cp_const
    "Boiler flow";
  parameter Modelica.Units.SI.MassFlowRate mPri_flow_nominal =
    mSdf_flow_nominal + mBibMai_flow_nominal
    "Mass flow from schematics - Primary (scaled down from 5160)";
  parameter Modelica.Units.SI.MassFlowRate mSdf_flow_nominal =
    2150 / 3600 / 1000 * Medium.d_const
    "Mass flow from schematics - SDF";
  parameter Modelica.Units.SI.MassFlowRate mBibMai_flow_nominal =
    1436 / 3600 / 1000 * Medium.d_const
    "Mass flow from schematics";
  parameter Modelica.Units.SI.MassFlowRate mMai_flow_nominal =
    860 / 3600 / 1000 * Medium.d_const
    "Mass flow from schematics";
  parameter Modelica.Units.SI.MassFlowRate mBib_flow_nominal =
    576 / 3600 / 1000 * Medium.d_const
    "Mass flow from schematics";
  parameter Modelica.Units.SI.PressureDifference dpBoi_nominal=2000;
  parameter Modelica.Units.SI.PressureDifference dpTan_nominal=1000;
  parameter Modelica.Units.SI.PressureDifference dpSdf1_nominal =
    5 * Medium.d_const * Modelica.Constants.g_n;
  parameter Modelica.Units.SI.PressureDifference dpSdf2_nominal = dpSdf1_nominal;
  parameter Modelica.Units.SI.PressureDifference dpBibMai1_nominal =
    3 * Medium.d_const * Modelica.Constants.g_n;
  parameter Modelica.Units.SI.PressureDifference dpBib2_nominal =
    dpBibMai1_nominal;
  parameter Modelica.Units.SI.PressureDifference dpMai2_nominal =
    dpBibMai1_nominal;
  parameter Modelica.Units.SI.Velocity vPip_nominal=1.1;
  parameter Modelica.Units.SI.Length lPip=25;

  PassiveNetworks.SingleMixing con(
    redeclare final package Medium = Medium,
    final m2_flow_nominal=mBoi_flow_nominal,
    final dp1_nominal=0,
    final dp2_nominal=dpBoi_nominal,
    typPum=Buildings.Fluid.HydronicConfigurations.Types.Pump.NoVariableInput,
    typCtl=Buildings.Fluid.HydronicConfigurations.Types.Control.Cooling,
    dpBal3_nominal=dpTan_nominal)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-130,-80})));
  Storage.StratifiedEnhanced tanBoi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    VTan=0.85,
    hTan=(16 * tanBoi.VTan / Modelica.Constants.pi)^(1/3),
    dIns=50E-3)
    annotation (Placement(transformation(extent={{-50,-80},{-30,-60}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(k=TRet_nominal)
    annotation (Placement(transformation(extent={{-300,190},{-280,210}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt(k=1)
    annotation (Placement(transformation(extent={{-300,150},{-280,170}})));
  Sensors.TemperatureTwoPort TBoiRet(
  redeclare final package Medium=Medium,
    m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-150,-100},{-170,-80}})));
  Sensors.TemperatureTwoPort TSup(redeclare final package Medium = Medium,
      m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,-30})));
  Sensors.MassFlowRate mPriSup(redeclare final package Medium = Medium)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-80,0})));
  Sensors.TemperatureTwoPort TRet(redeclare final package Medium = Medium,
      m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-60,-30})));
  FixedResistances.PressureDrop resTanBoi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    dp_nominal=dpTan_nominal)
    annotation (Placement(transformation(extent={{-40,-100},{-60,-80}})));
  ActiveNetworks.Examples.BaseClasses.LoadThreeWayValveControl loaSdf(
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=mSdf_flow_nominal,
    dpTer_nominal=dpSdf2_nominal/3,
    dpBal1_nominal=dpSdf2_nominal/3,
    redeclare final package MediumLiq=Medium,
    redeclare final package MediumAir=MediumAir)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={140,-70})));
  Buildings.Controls.OBC.CDL.Conversions.IntegerToReal intToRea
    annotation (Placement(transformation(extent={{-240,172},{-220,192}})));
  LaBrulatteSub subSdf(
    redeclare final package Medium = Medium,
    final have_val=have_valSub,
    final have_tan=have_tanSub,
    m_flow_nominal=mSdf_flow_nominal,
    dpTan_nominal=dpTan_nominal,
    dp_nominal=dpSdf1_nominal,
    dhPip=27E-3,
    lPip=10,
    VTan=0.6) annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  ActiveNetworks.Examples.BaseClasses.LoadThreeWayValveControl loaMai(
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=mMai_flow_nominal,
    dpTer_nominal=dpMai2_nominal/3,
    dpBal1_nominal=dpMai2_nominal/3,
    redeclare final package MediumLiq = Medium,
    redeclare final package MediumAir = MediumAir,
    TLiqEnt_nominal=TSup_nominal,
    TLiqLvg_nominal=TRet_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={180,30})));
  LaBrulatteSub subBibMai(
    show_T=true,
    redeclare final package Medium = Medium,
    final have_val=have_valSub,
    final have_tan=have_tanSub,
    m_flow_nominal=mBibMai_flow_nominal,
    dpTan_nominal=dpTan_nominal,
    dp_nominal=dpBibMai1_nominal,
    dhPip=27E-3,
    lPip=10,
    VTan=0.6) annotation (Placement(transformation(extent={{60,20},{80,40}})));
  Movers.Preconfigured.SpeedControlled_y pumSdf2(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    final m_flow_nominal=mSdf_flow_nominal,
    dp_nominal=dpSdf2_nominal)
    annotation (Placement(transformation(extent={{90,-70},{110,-50}})));
  Movers.Preconfigured.SpeedControlled_y pumMai2(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    show_T=true,
    final m_flow_nominal=mBibMai_flow_nominal,
    dp_nominal=dpMai2_nominal)
    annotation (Placement(transformation(extent={{96,30},{116,50}})));
  HeatExchangers.Heater_T boi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    dp_nominal=dpBoi_nominal,
    QMax_flow=QBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-180,-70},{-160,-50}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(k=TSup_nominal)
    annotation (Placement(transformation(extent={{-300,120},{-280,140}})));
  Sources.Boundary_pT bou(
    redeclare final package Medium = Medium,
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal + Medium.p_default,
    nPorts=1)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-200,-100})));
  PassiveNetworks.DualMixing conBib(
    redeclare final package Medium = Medium,
    m1_flow_nominal=mBib_flow_nominal*(TPlcSup_nominal - TPlcRet_nominal)/(
        TSup_nominal - TPlcRet_nominal),
    m2_flow_nominal=mBib_flow_nominal,
    dp1_nominal=100,
    dp2_nominal=dpBib2_nominal,
    typCtl=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={110,70})));
  ActiveNetworks.Examples.BaseClasses.LoadThreeWayValveControl loaBib(
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=mBib_flow_nominal,
    dpTer_nominal=dpBib2_nominal/3,
    dpBal1_nominal=dpBib2_nominal/3,
    redeclare final package MediumLiq = Medium,
    redeclare final package MediumAir = MediumAir,
    TLiqEnt_nominal=TPlcSup_nominal,
    TLiqLvg_nominal=TPlcRet_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={180,70})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con4(k=TPlcSup_nominal)
    annotation (Placement(transformation(extent={{-300,90},{-280,110}})));
  DHC.Networks.BaseClasses.DifferenceEnthalpyFlowRate QPri_flow(redeclare
      final package Medium1 = Medium, final m_flow_nominal=mPri_flow_nominal)
    "Difference in enthalpy flow rate" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-74,30})));
  HeatTransfer.Sources.FixedTemperature preTem(T=268.15)
    annotation (Placement(transformation(extent={{-300,-130},{-280,-110}})));
  FixedResistances.PlugFlowPipe pipSup(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal,
    v_nominal=vPip_nominal,
    length=lPip,
    dIns=25E-3,
    kIns=0.04) annotation (Placement(transformation(extent={{-30,50},{-10,70}})));
  FixedResistances.PlugFlowPipe pipRet(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal,
    v_nominal=vPip_nominal,
    length=lPip,
    dIns=25E-3,
    kIns=0.04) annotation (Placement(transformation(extent={{-10,30},{-30,50}})));
  FixedResistances.PlugFlowPipe pipSup1(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal-mBibMai_flow_nominal,
    v_nominal=vPip_nominal,
    length=lPip,
    dIns=25E-3,
    kIns=0.04)
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  FixedResistances.PlugFlowPipe pipRet1(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal-mBibMai_flow_nominal,
    v_nominal=vPip_nominal,
    length=lPip,
    dIns=25E-3,
    kIns=0.04)
    annotation (Placement(transformation(extent={{40,-90},{20,-70}})));
  HeatTransfer.Sources.FixedTemperature preTem1(T=278.15)
    annotation (Placement(transformation(extent={{-300,-170},{-280,-150}})));
equation
  connect(con1.y, con.set)
    annotation (Line(points={{-278,200},{-254,200},{-254,-116},{-126,-116},{
          -126,-92}},                                        color={0,0,127}));
  connect(conInt.y, con.mode) annotation (Line(points={{-278,160},{-248,160},{
          -248,-112},{-138,-112},{-138,-92}},
                color={255,127,0}));
  connect(con.port_b2,TBoiRet. port_a)
    annotation (Line(points={{-140,-86},{-140,-90},{-150,-90}},
                                                color={0,127,255}));
  connect(tanBoi.port_b, resTanBoi.port_a)
    annotation (Line(points={{-40,-80},{-40,-90}}, color={0,127,255}));
  connect(conInt.y, intToRea.u) annotation (Line(points={{-278,160},{-260,160},{
          -260,182},{-242,182}},
                            color={255,127,0}));
  connect(conInt.y, loaSdf.mode) annotation (Line(points={{-278,160},{144,160},{
          144,-58}},       color={255,127,0}));
  connect(loaSdf.port_b, subSdf.port_a2)
    annotation (Line(points={{140,-80},{80,-80},{80,-76}}, color={0,127,255}));
  connect(intToRea.y, subSdf.y) annotation (Line(points={{-218,182},{40,182},{40,
          -40},{64,-40},{64,-58}}, color={0,0,127}));
  connect(loaMai.port_b, subBibMai.port_a2)
    annotation (Line(points={{180,20},{80,20},{80,24}}, color={0,127,255}));
  connect(subSdf.port_b1, pumSdf2.port_a)
    annotation (Line(points={{80,-64},{80,-60},{90,-60}}, color={0,127,255}));
  connect(pumSdf2.port_b, loaSdf.port_a)
    annotation (Line(points={{110,-60},{140,-60}}, color={0,127,255}));
  connect(intToRea.y, pumSdf2.y) annotation (Line(points={{-218,182},{40,182},{40,
          -40},{100,-40},{100,-48}}, color={0,0,127}));
  connect(intToRea.y, subBibMai.y) annotation (Line(points={{-218,182},{40,182},
          {40,54},{64,54},{64,42}}, color={0,0,127}));
  connect(intToRea.y, loaMai.u)
    annotation (Line(points={{-218,182},{202,182},{202,46},{188,46},{188,42}},
                                                             color={0,0,127}));
  connect(conInt.y, loaMai.mode) annotation (Line(points={{-278,160},{200,160},{
          200,50},{184,50},{184,42}},
                    color={255,127,0}));
  connect(subBibMai.port_b1, pumMai2.port_a)
    annotation (Line(points={{80,36},{80,40},{96,40}}, color={0,127,255}));
  connect(pumMai2.port_b, loaMai.port_a)
    annotation (Line(points={{116,40},{180,40}}, color={0,127,255}));
  connect(intToRea.y, pumMai2.y) annotation (Line(points={{-218,182},{40,182},{40,
          54},{106,54},{106,52}}, color={0,0,127}));
  connect(TBoiRet.port_b, boi.port_a) annotation (Line(points={{-170,-90},{-200,
          -90},{-200,-60},{-180,-60}},
                          color={0,127,255}));
  connect(boi.port_b, con.port_a2)
    annotation (Line(points={{-160,-60},{-140,-60},{-140,-74}},
                                                 color={0,127,255}));
  connect(con2.y, boi.TSet) annotation (Line(points={{-278,130},{-244,130},{
          -244,-52},{-182,-52}},
                     color={0,0,127}));
  connect(subBibMai.port_b1, conBib.port_a1)
    annotation (Line(points={{80,36},{80,76},{100,76}}, color={0,127,255}));
  connect(conBib.port_b2, loaBib.port_a)
    annotation (Line(points={{120,76},{120,80},{180,80}}, color={0,127,255}));
  connect(loaBib.port_b, conBib.port_a2)
    annotation (Line(points={{180,60},{120,60},{120,64}}, color={0,0,127}));
  connect(conBib.port_b1, subBibMai.port_a2) annotation (Line(points={{100,64},
          {90,64},{90,24},{80,24}}, color={0,127,255}));
  connect(intToRea.y, conBib.yPum)
    annotation (Line(points={{-218,182},{114,182},{114,82}}, color={0,0,127}));
  connect(conInt.y, conBib.mode) annotation (Line(points={{-278,160},{118,160},{
          118,82}},  color={255,127,0}));
  connect(con4.y, conBib.set)
    annotation (Line(points={{-278,100},{106,100},{106,82}}, color={0,0,127}));
  connect(conInt.y, loaBib.mode) annotation (Line(points={{-278,160},{184,160},{
          184,82}},  color={255,127,0}));
  connect(intToRea.y, loaBib.u)
    annotation (Line(points={{-218,182},{188,182},{188,82}}, color={0,0,127}));
  connect(bou.ports[1], TBoiRet.port_b)
    annotation (Line(points={{-200,-90},{-170,-90}}, color={0,127,255}));
  connect(con1.y, subBibMai.TSet) annotation (Line(points={{-278,200},{44,200},{
          44,30},{58,30}}, color={0,0,127}));
  connect(con1.y, subSdf.TSet) annotation (Line(points={{-278,200},{44,200},{44,
          -70},{58,-70}}, color={0,0,127}));
  connect(preTem.port, subSdf.heaPor) annotation (Line(points={{-280,-120},{80,-120},
          {80,-70}}, color={191,0,0}));
  connect(preTem.port, subBibMai.heaPor)
    annotation (Line(points={{-280,-120},{80,-120},{80,30}}, color={191,0,0}));
  connect(tanBoi.heaPorSid, preTem.port) annotation (Line(points={{-34.4,-70},{
          -34.4,-120},{-280,-120}},
                              color={191,0,0}));
  connect(preTem.port, tanBoi.heaPorBot) annotation (Line(points={{-280,-120},{
          -34,-120},{-34,-78},{-38,-78},{-38,-77.4}},
                                                  color={191,0,0}));
  connect(preTem.port, tanBoi.heaPorTop) annotation (Line(points={{-280,-120},{
          -34,-120},{-34,-62.6},{-38,-62.6}},
                                          color={191,0,0}));
  connect(mPriSup.port_b, QPri_flow.port_a1)
    annotation (Line(points={{-80,10},{-80,20}}, color={0,127,255}));
  connect(TSup.port_b, mPriSup.port_a)
    annotation (Line(points={{-80,-20},{-80,-10}}, color={0,127,255}));
  connect(QPri_flow.port_b2, TRet.port_a)
    annotation (Line(points={{-68,20},{-60,20},{-60,-20}}, color={0,127,255}));
  connect(TRet.port_b, resTanBoi.port_b)
    annotation (Line(points={{-60,-40},{-60,-90}}, color={0,127,255}));
  connect(resTanBoi.port_b, con.port_a1) annotation (Line(points={{-60,-90},{
          -120,-90},{-120,-86}}, color={0,127,255}));
  connect(con.port_b1, tanBoi.port_a) annotation (Line(points={{-120,-74},{-120,
          -60},{-40,-60}}, color={0,127,255}));
  connect(con.port_b1, TSup.port_a) annotation (Line(points={{-120,-74},{-120,
          -60},{-80,-60},{-80,-40}}, color={0,127,255}));
  connect(intToRea.y, loaSdf.u) annotation (Line(points={{-218,182},{148,182},{148,
          -58}}, color={0,0,127}));
  connect(QPri_flow.port_b1, pipSup.port_a)
    annotation (Line(points={{-80,40},{-80,60},{-30,60}}, color={0,0,127}));
  connect(pipSup.port_b, subBibMai.port_a1)
    annotation (Line(points={{-10,60},{60,60},{60,36}},color={0,127,255}));
  connect(pipRet.port_b, QPri_flow.port_a2)
    annotation (Line(points={{-30,40},{-68,40}}, color={0,127,255}));
  connect(subBibMai.port_b2, pipRet.port_a) annotation (Line(points={{60,24},{
          60,20},{0,20},{0,40},{-10,40}},
                                      color={0,127,255}));
  connect(subSdf.port_b2, pipRet1.port_a)
    annotation (Line(points={{60,-76},{60,-80},{40,-80}}, color={0,127,255}));
  connect(pipRet1.port_b, pipRet.port_a) annotation (Line(points={{20,-80},{0,
          -80},{0,40},{-10,40}},
                           color={0,127,255}));
  connect(pipSup.port_b, pipSup1.port_a)
    annotation (Line(points={{-10,60},{20,60},{20,-60}},color={0,127,255}));
  connect(pipSup1.port_b, subSdf.port_a1)
    annotation (Line(points={{40,-60},{60,-60},{60,-64}}, color={0,127,255}));
  connect(preTem1.port, pipRet1.heatPort) annotation (Line(points={{-280,-160},
          {30,-160},{30,-70}}, color={191,0,0}));
  connect(preTem1.port, pipSup1.heatPort) annotation (Line(points={{-280,-160},
          {30,-160},{30,-50}}, color={191,0,0}));
  connect(preTem1.port, pipRet.heatPort) annotation (Line(points={{-280,-160},{
          -20,-160},{-20,50}}, color={191,0,0}));
  connect(preTem1.port, pipSup.heatPort) annotation (Line(points={{-280,-160},{
          -20,-160},{-20,70}}, color={191,0,0}));
 annotation(  experiment(
    StopTime=86400,
    Tolerance=1e-6),
    __Dymola_Commands(file=
    "modelica://Buildings/Resources/Scripts/Dymola/Fluid/HydronicConfigurations/Examples/LaBrulatte.mos"
    "Simulate and plot"),
    Diagram(coordinateSystem(extent={{-220,-140},{220,140}})),
    Documentation(info="<html>
<p>
Pompe sous-station avec plancher chauffant surdimensionnée : 
charge ballon permanente :
ex. 
Biblio PCH	576
Biblio PCH db1 96
</p>
<p>
Isoler ballon :
1) évite charge intempestive > nominale si ballon froid
2) couple pompes primaire et secondaire en série => HMT augmentée
</p>
<p>
Quel automatisme prévu pour éviter excès de charge sur la 
production si ballons froids ?
</p>
</html>"));
end LaBrulatte;
