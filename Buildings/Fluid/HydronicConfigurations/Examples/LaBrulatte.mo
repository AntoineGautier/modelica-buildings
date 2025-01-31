within Buildings.Fluid.HydronicConfigurations.Examples;
model LaBrulatte
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water
    "Medium model for hot water";
  package MediumAir = Buildings.Media.Air
    "Medium model for air";
  parameter Modelica.Units.SI.Temperature TSup_nominal = 65 + 273.15;
  parameter Modelica.Units.SI.Temperature TRet_nominal = 50 + 273.15;
  parameter Modelica.Units.SI.Temperature TPlcSup_nominal = 40 + 273.15;
  parameter Modelica.Units.SI.Temperature TPlcRet_nominal = 35 + 273.15;
  parameter Modelica.Units.SI.HeatFlowRate QBoi_flow_nominal = 85E3;
  parameter Modelica.Units.SI.MassFlowRate mBoi_flow_nominal =
    QBoi_flow_nominal / (TSup_nominal - TRet_nominal) /
    Medium.cp_const
    "Boiler flow";
  parameter Modelica.Units.SI.MassFlowRate mPri_flow_nominal =
    5160 / 3600 / 1000 * Medium.d_const
    "Mass flow from schematics - Primary";
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
  parameter Modelica.Units.SI.PressureDifference dpBoi_nominal = 2000;
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

  PassiveNetworks.SingleMixing con(
    redeclare final package Medium = Medium,
    final m2_flow_nominal=mBoi_flow_nominal,
    final dp1_nominal=dpTan_nominal,
    final dp2_nominal=dpBoi_nominal,
    typPum=Buildings.Fluid.HydronicConfigurations.Types.Pump.NoVariableInput,
    typCtl=Buildings.Fluid.HydronicConfigurations.Types.Control.Cooling)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-120,-6})));
  Storage.StratifiedEnhanced tanBoi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    VTan=0.85,
    hTan=(16 * tanBoi.VTan / Modelica.Constants.pi)^(1/3),
    dIns=0.1) annotation (Placement(transformation(extent={{-30,-30},{-10,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con1(k=TRet_nominal)
    annotation (Placement(transformation(extent={{-310,190},{-290,210}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt(k=1)
    annotation (Placement(transformation(extent={{-310,150},{-290,170}})));
  Sensors.TemperatureTwoPort TRetBoi(
  redeclare final package Medium=Medium,
    m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-150,-30},{-170,-10}})));
  Sensors.TemperatureTwoPort TSup(redeclare final package Medium = Medium,
      m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
  Sensors.MassFlowRate mPriSup(redeclare final package Medium = Medium)
    annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
  Sensors.TemperatureTwoPort TRet(redeclare final package Medium = Medium,
      m_flow_nominal=mBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-90,-50},{-110,-30}})));
  FixedResistances.PressureDrop resTanBoi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    dp_nominal=dpTan_nominal)
    annotation (Placement(transformation(extent={{-20,-50},{-40,-30}})));
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
    annotation (Placement(transformation(extent={{-270,170},{-250,190}})));
  LaBrulatteSub subSdf(
    redeclare final package Medium = Medium,
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
  FixedResistances.HydraulicDiameter dn40(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal,
    show_T=true,
    dh=42.5E-3,
    length=30) annotation (Placement(transformation(extent={{-20,30},{0,50}})));
  FixedResistances.HydraulicDiameter dn40Ret(
    redeclare final package Medium = Medium,
    m_flow_nominal=dn40.m_flow_nominal,
    dh=dn40.dh,
    length=dn40.length)
               annotation (Placement(transformation(extent={{0,10},{-20,30}})));
  FixedResistances.HydraulicDiameter dn32(
    redeclare final package Medium = Medium,
    m_flow_nominal=mPri_flow_nominal - mBibMai_flow_nominal,
    dh=36.6E-3,
    length=20)
    annotation (Placement(transformation(extent={{20,-70},{40,-50}})));
  FixedResistances.HydraulicDiameter dn32Ret(
    redeclare final package Medium = Medium,
    m_flow_nominal=dn32.m_flow_nominal,
    dh=dn32.dh,
    length=dn32.length)
    annotation (Placement(transformation(extent={{20,-90},{40,-70}})));
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
    annotation (Placement(transformation(extent={{-200,-10},{-180,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(k=TSup_nominal)
    annotation (Placement(transformation(extent={{-270,130},{-250,150}})));
  Sources.Boundary_pT bou(
    redeclare final package Medium = Medium,
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal + Medium.p_default,
    nPorts=1)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-200,-60})));
  PassiveNetworks.DualMixing conBib(
    redeclare final package Medium = Medium,
    m1_flow_nominal=0.9*mBib_flow_nominal,
    m2_flow_nominal=mBib_flow_nominal,
    dp1_nominal=0,
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
    annotation (Placement(transformation(extent={{-310,90},{-290,110}})));
equation
  connect(con1.y, con.set)
    annotation (Line(points={{-288,200},{-242,200},{-242,38},{-116,38},{-116,-18}},
                                                             color={0,0,127}));
  connect(conInt.y, con.mode) annotation (Line(points={{-288,160},{-240,160},{-240,
          40},{-128,40},{-128,-18}},
                color={255,127,0}));
  connect(con.port_b2, TRetBoi.port_a)
    annotation (Line(points={{-130,-12},{-130,-20},{-150,-20}},
                                                color={0,127,255}));
  connect(con.port_b1, TSup.port_a)
    annotation (Line(points={{-110,0},{-110,0}}, color={0,127,255}));
  connect(TSup.port_b, mPriSup.port_a)
    annotation (Line(points={{-90,0},{-90,0}},   color={0,127,255}));
  connect(TRet.port_b, con.port_a1)
    annotation (Line(points={{-110,-40},{-110,-12}},
                                               color={0,127,255}));
  connect(tanBoi.port_b, resTanBoi.port_a)
    annotation (Line(points={{-20,-30},{-20,-40}}, color={0,127,255}));
  connect(resTanBoi.port_b, TRet.port_a)
    annotation (Line(points={{-40,-40},{-90,-40}}, color={0,127,255}));
  connect(conInt.y, intToRea.u) annotation (Line(points={{-288,160},{-280,160},{
          -280,180},{-272,180}},
                            color={255,127,0}));
  connect(intToRea.y, loaSdf.u) annotation (Line(points={{-248,180},{148,180},{148,
          -58}},           color={0,0,127}));
  connect(conInt.y, loaSdf.mode) annotation (Line(points={{-288,160},{144,160},{
          144,-58}},       color={255,127,0}));
  connect(loaSdf.port_b, subSdf.port_a2)
    annotation (Line(points={{140,-80},{80,-80},{80,-76}}, color={0,127,255}));
  connect(intToRea.y, subSdf.y) annotation (Line(points={{-248,180},{40,180},{40,
          -40},{64,-40},{64,-58}}, color={0,0,127}));
  connect(mPriSup.port_b, tanBoi.port_a)
    annotation (Line(points={{-70,0},{-20,0},{-20,-10}}, color={0,127,255}));
  connect(loaMai.port_b, subBibMai.port_a2)
    annotation (Line(points={{180,20},{80,20},{80,24}}, color={0,127,255}));
  connect(subSdf.port_b1, pumSdf2.port_a)
    annotation (Line(points={{80,-64},{80,-60},{90,-60}}, color={0,127,255}));
  connect(pumSdf2.port_b, loaSdf.port_a)
    annotation (Line(points={{110,-60},{140,-60}}, color={0,127,255}));
  connect(intToRea.y, pumSdf2.y) annotation (Line(points={{-248,180},{40,180},{40,
          -40},{100,-40},{100,-48}}, color={0,0,127}));
  connect(mPriSup.port_b, dn40.port_a) annotation (Line(points={{-70,0},{-60,0},
          {-60,40},{-20,40}}, color={0,127,255}));
  connect(dn40.port_b, subBibMai.port_a1)
    annotation (Line(points={{0,40},{60,40},{60,36}}, color={0,127,255}));
  connect(dn40Ret.port_b, TRet.port_a) annotation (Line(points={{-20,20},{-50,20},
          {-50,-40},{-90,-40}}, color={0,127,255}));
  connect(dn32.port_b, subSdf.port_a1)
    annotation (Line(points={{40,-60},{60,-60},{60,-64}}, color={0,127,255}));
  connect(subSdf.port_b2, dn32Ret.port_b)
    annotation (Line(points={{60,-76},{60,-80},{40,-80}}, color={0,127,255}));
  connect(subBibMai.port_b2, dn40Ret.port_a)
    annotation (Line(points={{60,24},{60,20},{0,20}}, color={0,127,255}));
  connect(dn32Ret.port_a, dn40Ret.port_a)
    annotation (Line(points={{20,-80},{0,-80},{0,20}}, color={0,127,255}));
  connect(dn32.port_a, dn40.port_b)
    annotation (Line(points={{20,-60},{20,40},{0,40}}, color={0,127,255}));
  connect(intToRea.y, subBibMai.y) annotation (Line(points={{-248,180},{40,180},
          {40,54},{64,54},{64,42}}, color={0,0,127}));
  connect(intToRea.y, loaMai.u)
    annotation (Line(points={{-248,180},{202,180},{202,46},{188,46},{188,42}},
                                                             color={0,0,127}));
  connect(conInt.y, loaMai.mode) annotation (Line(points={{-288,160},{200,160},
          {200,50},{184,50},{184,42}},
                    color={255,127,0}));
  connect(subBibMai.port_b1, pumMai2.port_a)
    annotation (Line(points={{80,36},{80,40},{96,40}}, color={0,127,255}));
  connect(pumMai2.port_b, loaMai.port_a)
    annotation (Line(points={{116,40},{180,40}}, color={0,127,255}));
  connect(intToRea.y, pumMai2.y) annotation (Line(points={{-248,180},{40,180},{40,
          54},{106,54},{106,52}}, color={0,0,127}));
  connect(TRetBoi.port_b, boi.port_a) annotation (Line(points={{-170,-20},{-200,
          -20},{-200,0}}, color={0,127,255}));
  connect(boi.port_b, con.port_a2)
    annotation (Line(points={{-180,0},{-130,0}}, color={0,127,255}));
  connect(con2.y, boi.TSet) annotation (Line(points={{-248,140},{-244,140},{-244,
          8},{-202,8}},
                     color={0,0,127}));
  connect(bou.ports[1], boi.port_a) annotation (Line(points={{-200,-50},{-200,0}},
                     color={0,127,255}));
  connect(subBibMai.port_b1, conBib.port_a1)
    annotation (Line(points={{80,36},{80,76},{100,76}}, color={0,127,255}));
  connect(conBib.port_b2, loaBib.port_a)
    annotation (Line(points={{120,76},{120,80},{180,80}}, color={0,127,255}));
  connect(loaBib.port_b, conBib.port_a2)
    annotation (Line(points={{180,60},{120,60},{120,64}}, color={0,0,127}));
  connect(conBib.port_b1, subBibMai.port_a2) annotation (Line(points={{100,64},
          {90,64},{90,24},{80,24}}, color={0,127,255}));
  connect(intToRea.y, conBib.yPum)
    annotation (Line(points={{-248,180},{114,180},{114,82}}, color={0,0,127}));
  connect(conInt.y, conBib.mode) annotation (Line(points={{-288,160},{118,160},
          {118,82}}, color={255,127,0}));
  connect(con4.y, conBib.set)
    annotation (Line(points={{-288,100},{106,100},{106,82}}, color={0,0,127}));
  connect(conInt.y, loaBib.mode) annotation (Line(points={{-288,160},{184,160},
          {184,82}}, color={255,127,0}));
  connect(intToRea.y, loaBib.u)
    annotation (Line(points={{-248,180},{188,180},{188,82}}, color={0,0,127}));
 annotation(  experiment(
    StopTime=86400,
    Tolerance=1e-6),
    __Dymola_Commands(file=
    "modelica://Buildings/Resources/Scripts/Dymola/Fluid/HydronicConfigurations/Examples/LaBrulatte.mos"
    "Simulate and plot"),
    Diagram(coordinateSystem(extent={{-220,-140},{220,140}})));
end LaBrulatte;
