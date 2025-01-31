within Buildings.Fluid.HydronicConfigurations.Examples;
model LaBrulatte
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water
    "Medium model for hot water";
  package MediumAir = Buildings.Media.Air
    "Medium model for air";
  parameter Modelica.Units.SI.Temperature TSup_nominal = 65 + 273.15;
  parameter Modelica.Units.SI.Temperature TRet_nominal = 50 + 273.15;
  parameter Modelica.Units.SI.HeatFlowRate QBoi_flow_nominal = 85E3;
  parameter Modelica.Units.SI.MassFlowRate mBoi_flow_nominal =
    QBoi_flow_nominal / (TSup_nominal - TRet_nominal) /
    Medium.cp_const
    "Boiler flow";
  parameter Modelica.Units.SI.MassFlowRate mPri_flow_nominal =
    5160 / 3600 / 1000 * Medium.d_const
    "Primary flow from schematics";
  parameter Modelica.Units.SI.MassFlowRate mSdf_flow_nominal =
    2150 / 3600 / 1000 * Medium.d_const
    "Primary flow from schematics";
  parameter Modelica.Units.SI.MassFlowRate mBibMai_flow_nominal =
    1436 / 3600 / 1000 * Medium.d_const
    "Primary flow from schematics";
  parameter Modelica.Units.SI.PressureDifference dpBoi_nominal = 2000;
  parameter Modelica.Units.SI.PressureDifference dpTan_nominal=1000;
  parameter Modelica.Units.SI.PressureDifference dpSdf1_nominal =
    5 * Medium.d_const * Modelica.Constants.g_n;
  parameter Modelica.Units.SI.PressureDifference dpSdf2_nominal = dpSdf1_nominal;
  parameter Modelica.Units.SI.PressureDifference dpBibMai1_nominal =
    3 * Medium.d_const * Modelica.Constants.g_n;
  parameter Modelica.Units.SI.PressureDifference dpBibMai2_nominal =
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
    annotation (Placement(transformation(extent={{-310,110},{-290,130}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt(k=1)
    annotation (Placement(transformation(extent={{-310,70},{-290,90}})));
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
    annotation (Placement(transformation(extent={{-270,90},{-250,110}})));
  LaBrulatteSub subSdf(
    redeclare final package Medium = Medium,
    m_flow_nominal=mSdf_flow_nominal,
    dpTan_nominal=dpTan_nominal,
    dp_nominal=dpSdf1_nominal,
    dhPip=27E-3,
    lPip=10,
    VTan=0.6) annotation (Placement(transformation(extent={{60,-80},{80,-60}})));
  ActiveNetworks.Examples.BaseClasses.LoadThreeWayValveControl loaBibMai(
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=mBibMai_flow_nominal,
    dpTer_nominal=dpBibMai2_nominal/3,
    dpBal1_nominal=dpBibMai2_nominal/3,
    redeclare final package MediumLiq = Medium,
    redeclare final package MediumAir = MediumAir,
    TLiqEnt_nominal=TSup_nominal,
    TLiqLvg_nominal=TRet_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={140,30})));
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
  Movers.Preconfigured.SpeedControlled_y pumBibMai2(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    show_T=true,
    final m_flow_nominal=mBibMai_flow_nominal,
    dp_nominal=dpBibMai2_nominal)
    annotation (Placement(transformation(extent={{90,30},{110,50}})));
  HeatExchangers.Heater_T boi(
    redeclare final package Medium = Medium,
    m_flow_nominal=mBoi_flow_nominal,
    dp_nominal=dpBoi_nominal,
    QMax_flow=QBoi_flow_nominal)
    annotation (Placement(transformation(extent={{-200,-10},{-180,10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con2(k=TSup_nominal)
    annotation (Placement(transformation(extent={{-310,30},{-290,50}})));
  Sources.Boundary_pT bou(
    redeclare final package Medium = Medium,
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal + Medium.p_default,
    nPorts=1)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-200,-60})));
equation
  connect(con1.y, con.set)
    annotation (Line(points={{-288,120},{-242,120},{-242,-42},{-116,-42},{-116,-18}},
                                                             color={0,0,127}));
  connect(conInt.y, con.mode) annotation (Line(points={{-288,80},{-240,80},{-240,
          -40},{-128,-40},{-128,-18}},
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
  connect(conInt.y, intToRea.u) annotation (Line(points={{-288,80},{-280,80},{-280,
          100},{-272,100}}, color={255,127,0}));
  connect(intToRea.y, loaSdf.u) annotation (Line(points={{-248,100},{122,100},{122,
          -48},{148,-48},{148,-58}},
                           color={0,0,127}));
  connect(conInt.y, loaSdf.mode) annotation (Line(points={{-288,80},{120,80},{120,
          -50},{144,-50},{144,-58}},
                           color={255,127,0}));
  connect(loaSdf.port_b, subSdf.port_a2)
    annotation (Line(points={{140,-80},{80,-80},{80,-76}}, color={0,127,255}));
  connect(intToRea.y, subSdf.y) annotation (Line(points={{-248,100},{40,100},{40,
          -40},{64,-40},{64,-58}}, color={0,0,127}));
  connect(mPriSup.port_b, tanBoi.port_a)
    annotation (Line(points={{-70,0},{-20,0},{-20,-10}}, color={0,127,255}));
  connect(loaBibMai.port_b, subBibMai.port_a2)
    annotation (Line(points={{140,20},{80,20},{80,24}}, color={0,127,255}));
  connect(subSdf.port_b1, pumSdf2.port_a)
    annotation (Line(points={{80,-64},{80,-60},{90,-60}}, color={0,127,255}));
  connect(pumSdf2.port_b, loaSdf.port_a)
    annotation (Line(points={{110,-60},{140,-60}}, color={0,127,255}));
  connect(intToRea.y, pumSdf2.y) annotation (Line(points={{-248,100},{40,100},{40,
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
  connect(intToRea.y, subBibMai.y) annotation (Line(points={{-248,100},{40,100},
          {40,60},{64,60},{64,42}}, color={0,0,127}));
  connect(intToRea.y, loaBibMai.u)
    annotation (Line(points={{-248,100},{148,100},{148,42}}, color={0,0,127}));
  connect(conInt.y, loaBibMai.mode)
    annotation (Line(points={{-288,80},{144,80},{144,42}}, color={255,127,0}));
  connect(subBibMai.port_b1, pumBibMai2.port_a)
    annotation (Line(points={{80,36},{80,40},{90,40}}, color={0,127,255}));
  connect(pumBibMai2.port_b, loaBibMai.port_a)
    annotation (Line(points={{110,40},{140,40}}, color={0,127,255}));
  connect(intToRea.y, pumBibMai2.y) annotation (Line(points={{-248,100},{40,100},
          {40,60},{100,60},{100,52}}, color={0,0,127}));
  connect(TRetBoi.port_b, boi.port_a) annotation (Line(points={{-170,-20},{-200,
          -20},{-200,0}}, color={0,127,255}));
  connect(boi.port_b, con.port_a2)
    annotation (Line(points={{-180,0},{-130,0}}, color={0,127,255}));
  connect(con2.y, boi.TSet) annotation (Line(points={{-288,40},{-244,40},{-244,8},
          {-202,8}}, color={0,0,127}));
  connect(bou.ports[1], boi.port_a) annotation (Line(points={{-200,-50},{-200,0}},
                     color={0,127,255}));
 annotation(  experiment(
    StopTime=86400,
    Tolerance=1e-6),
    __Dymola_Commands(file=
    "modelica://Buildings/Resources/Scripts/Dymola/Fluid/HydronicConfigurations/Examples/LaBrulatte.mos"
    "Simulate and plot"),
    Diagram(coordinateSystem(extent={{-220,-140},{220,140}})));
end LaBrulatte;
