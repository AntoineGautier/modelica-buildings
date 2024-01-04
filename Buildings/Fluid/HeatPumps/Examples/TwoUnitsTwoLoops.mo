within Buildings.Fluid.HeatPumps.Examples;
model TwoUnitsTwoLoops
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.MassFlowRate mHeaWat_flow_nominal(
    final min=0)=2 * dat.hea.mLoa_flow
    "Design HW mass flow rate"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.MassFlowRate mChiWat_flow_nominal(
    final min=0)=2 * dat.coo.mLoa_flow
    "Design CHW mass flow rate"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature THeaWatSup_nominal(
    final min=0)=45 + 273.15
    "Design HW supply temperature"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TChiWatSup_nominal(
    final min=0)=12 + 273.15
    "Design CHW supply temperature"
    annotation(Dialog(group="Nominal condition"));

  parameter HeatPumps.Data.EquationFitReversible.Generic dat(
    dpHeaLoa_nominal=40000,
    dpHeaSou_nominal=100,
    hea(
      mLoa_flow=dat.hea.Q_flow/10/4186,
      mSou_flow=1E-4*dat.hea.Q_flow,
      Q_flow=1E6,
      P=dat.hea.Q_flow/2.2,
      coeQ={-4.7042248557,-0.8254212432,6.6259593798,0,0},
      coeP={-4.8830101014,5.2443974448,0.5318696177,0,0},
      TRefLoa=313.15,
      TRefSou=280.15),
    coo(
      mLoa_flow=abs(dat.coo.Q_flow)/8/4186,
      mSou_flow=dat.hea.mSou_flow,
      Q_flow=-2.7*dat.coo.P,
      P=dat.hea.P,
      coeQ={-2.2545246871,6.9089257665,-3.6548225094,0,0},
      coeP={-5.808601045,1.6894933909,5.1167787434,0,0},
      TRefLoa=285.15,
      TRefSou=308.15))
    "Heat pump parameters"
    annotation (Placement(transformation(extent={{-300,200},{-280,220}})));

  Movers.Preconfigured.SpeedControlled_y P_1(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal(displayUnit="Pa") = dat.dpHeaLoa_nominal + 1E4)
    annotation (Placement(transformation(extent={{40,-90},{20,-70}})));
  Movers.Preconfigured.SpeedControlled_y P_2(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal(displayUnit="Pa") = dat.dpHeaLoa_nominal + 1E4)
    annotation (Placement(transformation(extent={{40,50},{20,70}})));
  FixedResistances.PressureDrop decChiWat(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=dat.coo.mLoa_flow,
    dp_nominal=3000) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={200,-170})));
  Controls.OBC.CDL.Logical.Sources.TimeTable booTimTab(
    table=[0,0; 1,0; 1,1; 10,1],
    timeScale=1000,
    period=10000)
    annotation (Placement(transformation(extent={{-300,150},{-280,170}})));
  Sources.Boundary_pT EXP(redeclare package Medium = Buildings.Media.Water,
      nPorts=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={50,-112})));
  FixedResistances.CheckValve che1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_1.m_flow_nominal,
    dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{20,-90},{0,-70}})));
  FixedResistances.CheckValve che2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_2.m_flow_nominal,
    dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{20,50},{0,70}})));
  Controls.OBC.CDL.Reals.Sources.Constant con1(k=1)
    annotation (Placement(transformation(extent={{-300,50},{-280,70}})));
  Actuators.Valves.TwoWayLinear V_1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_1.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={-140,-100})));
  Controls.OBC.CDL.Reals.Sources.Constant con2(k=0)
    annotation (Placement(transformation(extent={{-300,90},{-280,110}})));
  Actuators.Valves.TwoWayLinear V_4(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_2.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-140,80})));
  Actuators.Valves.TwoWayLinear V_2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_1.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={-140,-60})));
  Actuators.Valves.TwoWayLinear V_3(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_2.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-140,40})));
  FixedResistances.Junction jun(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mChiWat_flow_nominal*{1,-1,1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={-200,-100})));
  FixedResistances.Junction jun1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mChiWat_flow_nominal*{1,-1,1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={80,-80})));
  FixedResistances.Junction jun2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mHeaWat_flow_nominal*{1,-1,1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={80,60})));
  FixedResistances.PressureDrop decHeaWat(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal=3000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={200,110})));
  FixedResistances.Junction jun4(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mHeaWat_flow_nominal*{1,-1,1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={-180,80})));
  Delays.DelayFirstOrder BUFFER_HHW(
    redeclare final package Medium = Buildings.Media.Water,
    final m_flow_nominal=mHeaWat_flow_nominal,
    tau=4*60,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=THeaWatSup_nominal,
    nPorts=2) "HHW buffer tank" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={160,150})));
  Delays.DelayFirstOrder BUFFER_CHW(
    redeclare final package Medium = Buildings.Media.Water,
    final m_flow_nominal=mChiWat_flow_nominal,
    tau=2*60,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    T_start=TChiWatSup_nominal,
    nPorts=2) "CHW buffer tank" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={160,-130})));
  BaseClasses.AirToWaterHeatPump AWHP_1(redeclare package Medium =
        Buildings.Media.Water, dat=dat) "AWHP"
    annotation (Placement(transformation(extent={{-50,-90},{-70,-70}})));
  BaseClasses.AirToWaterHeatPump AWHP_2(redeclare package Medium =
        Buildings.Media.Water, dat=dat) "AWHP"
    annotation (Placement(transformation(extent={{-50,50},{-70,70}})));
  FixedResistances.Junction jun3(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mHeaWat_flow_nominal*{1,-1,-1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={140,60})));
  FixedResistances.Junction jun5(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=mChiWat_flow_nominal*{1,-1,-1},
    dp_nominal=fill(100, 3)) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={120,-120})));
  Controls.OBC.CDL.Reals.Sources.Constant THeaWatSupSet(k=THeaWatSup_nominal)
    "HWST setpoint"
    annotation (Placement(transformation(extent={{-300,-70},{-280,-50}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    "Outdoor conditions"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-100,200})));
  Controls.OBC.CDL.Logical.Sources.Constant tru(k=true)
    annotation (Placement(transformation(extent={{-300,-150},{-280,-130}})));
  Controls.OBC.CDL.Logical.Sources.Constant fal(k=false)
    annotation (Placement(transformation(extent={{-300,10},{-280,30}})));
  Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-250,170},{-230,190}})));
  Controls.OBC.CDL.Conversions.BooleanToReal booToRea1
    annotation (Placement(transformation(extent={{-250,-170},{-230,-150}})));
  Controls.OBC.CDL.Reals.Sources.Constant TChiWatSupSet(k=TChiWatSup_nominal)
    "CHWST setpoint"
    annotation (Placement(transformation(extent={{-300,-30},{-280,-10}})));
  Sensors.TemperatureTwoPort TE_2(redeclare package Medium =
        Buildings.Media.Water, m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-90,-90},{-110,-70}})));
  Sensors.TemperatureTwoPort TE_1(redeclare package Medium =
        Buildings.Media.Water, m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-10,-90},{-30,-70}})));
  Sensors.TemperatureTwoPort TE_3(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-10,50},{-30,70}})));
  Sensors.TemperatureTwoPort TE_4(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-90,50},{-110,70}})));
equation
  connect(P_1.port_b, che1.port_a)
    annotation (Line(points={{20,-80},{20,-80}},   color={28,108,200}));
  connect(con2.y, V_4.y)
    annotation (Line(points={{-278,100},{-140,100},{-140,92}},
                                                             color={0,0,127}));
  connect(con2.y, V_1.y) annotation (Line(points={{-278,100},{-240,100},{-240,-80},
          {-140,-80},{-140,-88}}, color={0,0,127}));
  connect(con1.y, V_3.y)
    annotation (Line(points={{-278,60},{-140,60},{-140,52}}, color={0,0,127}));
  connect(con1.y, V_2.y) annotation (Line(points={{-278,60},{-220,60},{-220,-40},
          {-140,-40},{-140,-48}}, color={0,0,127}));
  connect(V_1.port_b, jun.port_3)
    annotation (Line(points={{-150,-100},{-190,-100}}, color={28,108,200}));
  connect(V_3.port_b, jun.port_1) annotation (Line(points={{-150,40},{-200,40},{
          -200,-90}}, color={0,127,255},
      thickness=1));
  connect(jun.port_2, decChiWat.port_a) annotation (Line(points={{-200,-110},{
          -200,-200},{200,-200},{200,-180}},
                                           color={0,127,255},
      thickness=1));
  connect(V_4.port_b, jun4.port_3)
    annotation (Line(points={{-150,80},{-170,80}}, color={28,108,200}));
  connect(V_2.port_b, jun4.port_1) annotation (Line(points={{-150,-60},{-180,
          -60},{-180,70}},
                      color={238,46,47},
      thickness=1));
  connect(BUFFER_HHW.ports[1], decHeaWat.port_a) annotation (Line(points={{161,140},
          {200,140},{200,120}},color={238,46,47},
      thickness=1));
  connect(jun4.port_2, BUFFER_HHW.ports[2]) annotation (Line(points={{-180,90},
          {-180,140},{159,140}},color={238,46,47},
      thickness=1));
  connect(decChiWat.port_b, BUFFER_CHW.ports[1]) annotation (Line(points={{200,
          -160},{200,-140},{161,-140}},
                                  color={0,127,255},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(decHeaWat.port_b, jun3.port_1) annotation (Line(
      points={{200,100},{200,78},{140,78},{140,70}},
      color={238,46,47},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(jun3.port_3, jun2.port_1) annotation (Line(
      points={{130,60},{90,60}},
      color={238,46,47},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(jun3.port_2, jun1.port_1) annotation (Line(
      points={{140,50},{140,-80},{90,-80}},
      color={238,46,47},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(BUFFER_CHW.ports[2], jun5.port_1) annotation (Line(points={{159,-140},
          {120,-140},{120,-130}}, color={0,127,255},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(jun5.port_3,jun1. port_3) annotation (Line(points={{110,-120},{80,-120},
          {80,-90}}, color={0,127,255},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(jun5.port_2,jun2. port_3) annotation (Line(points={{120,-110},{120,20},
          {80,20},{80,50}}, color={28,108,200},
      thickness=1,
      pattern=LinePattern.Dash));
  connect(weaDat.weaBus, AWHP_2.weaBus) annotation (Line(
      points={{-90,200},{-80,200},{-80,80},{-60,80},{-60,70}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus, AWHP_1.weaBus) annotation (Line(
      points={{-90,200},{-80,200},{-80,-60},{-60,-60},{-60,-70}},
      color={255,204,51},
      thickness=0.5));
  connect(tru.y, AWHP_1.y1) annotation (Line(points={{-278,-140},{-40,-140},{-40,
          -72},{-48,-72}}, color={255,0,255}));
  connect(tru.y, AWHP_1.yHea) annotation (Line(points={{-278,-140},{-40,-140},{-40,
          -76},{-48,-76}}, color={255,0,255}));
  connect(fal.y, AWHP_2.yHea) annotation (Line(points={{-278,20},{-40,20},{-40,64},
          {-48,64}}, color={255,0,255}));
  connect(booTimTab.y[1], booToRea.u) annotation (Line(points={{-278,160},{-260,
          160},{-260,180},{-252,180}}, color={255,0,255}));
  connect(booToRea.y, P_2.y)
    annotation (Line(points={{-228,180},{30,180},{30,72}}, color={0,0,127}));
  connect(booTimTab.y[1], AWHP_2.y1) annotation (Line(points={{-278,160},{-40,160},
          {-40,68},{-48,68}}, color={255,0,255}));
  connect(tru.y, booToRea1.u) annotation (Line(points={{-278,-140},{-260,-140},{
          -260,-160},{-252,-160}}, color={255,0,255}));
  connect(booToRea1.y, P_1.y) annotation (Line(points={{-228,-160},{0,-160},{0,-60},
          {30,-60},{30,-68}},      color={0,0,127}));
  connect(TChiWatSupSet.y, AWHP_2.TSet) annotation (Line(points={{-278,-20},{
          -44,-20},{-44,54},{-48,54}}, color={0,0,127}));
  connect(THeaWatSupSet.y, AWHP_1.TSet) annotation (Line(points={{-278,-60},{
          -260,-60},{-260,-120},{-44,-120},{-44,-86},{-48,-86}}, color={0,0,127}));
  connect(EXP.ports[1], P_1.port_a)
    annotation (Line(points={{50,-102},{50,-80},{40,-80}}, color={0,127,255}));
  connect(jun1.port_2, P_1.port_a)
    annotation (Line(points={{70,-80},{40,-80}}, color={238,46,47},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(AWHP_1.port_b, TE_2.port_a)
    annotation (Line(points={{-70,-80},{-90,-80}}, color={238,46,47},
      thickness=1));
  connect(TE_2.port_b, V_1.port_a) annotation (Line(points={{-110,-80},{-120,-80},
          {-120,-100},{-130,-100}}, color={0,127,255}));
  connect(TE_2.port_b, V_2.port_a) annotation (Line(points={{-110,-80},{-120,-80},
          {-120,-60},{-130,-60}}, color={238,46,47},
      thickness=1));
  connect(che1.port_b, TE_1.port_a)
    annotation (Line(points={{0,-80},{-10,-80}}, color={238,46,47},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(TE_1.port_b, AWHP_1.port_a)
    annotation (Line(points={{-30,-80},{-50,-80}}, color={238,46,47},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(che2.port_b, TE_3.port_a)
    annotation (Line(points={{0,60},{-10,60}}, color={0,127,255},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(TE_3.port_b, AWHP_2.port_a)
    annotation (Line(points={{-30,60},{-50,60}}, color={0,127,255},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(jun2.port_2, P_2.port_a)
    annotation (Line(points={{70,60},{40,60}}, color={0,127,255},
      pattern=LinePattern.Dash,
      thickness=1));
  connect(P_2.port_b, che2.port_a)
    annotation (Line(points={{20,60},{20,60}}, color={0,127,255}));
  connect(AWHP_2.port_b, TE_4.port_a)
    annotation (Line(points={{-70,60},{-90,60}}, color={0,127,255},
      thickness=1));
  connect(TE_4.port_b, V_4.port_a) annotation (Line(points={{-110,60},{-120,60},
          {-120,80},{-130,80}}, color={0,127,255}));
  connect(TE_4.port_b, V_3.port_a) annotation (Line(points={{-110,60},{-120,60},
          {-120,40},{-130,40}}, color={0,127,255},
      thickness=1));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-220,-220},{220,
            220}}),     graphics={
    Bitmap(extent={{222,-286},{878,218}}, fileName="modelica://Buildings/Resources/Images/Fluid/Movers/Validation/TestPumpTwoLoops.png")}),
experiment(Tolerance=1e-06, StopTime=10000.0),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatPumps/Examples/TwoUnitsTwoLoops.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>This model reproduces the standard configuration from TRANE (2022).
The simulation illustrates the faulty hydronics that yield uncontrolled mixing
between the primary CHW and HHW loops.
</p>
<h4>Details</h4>
<p>
The model only represents the primary CHW and HHW loops, up to the decoupler.
The plant is composed of two identical reversible air-to-water heat pumps.
A pair of two-way two-position valves are used at the outlet of
each unit to switch over between the CHW loop and the HHW loop.
Only one operating mode is simulated, with
<code>AWHP_1</code> operating in heating mode and 
<code>AWHP_2</code> operating in cooling mode.
Due to the absence of switching valves at the heat pump inlet,
mixing occurs at the junction of the return pipes of the
primary CHW and HHW loops 
(components <code>jun1</code> and <code>jun2</code> in the model).
In this configuration, the unit in cooling mode practically cools the 
primary HHW loop and prevents the unit in heating mode from meeting setpoint.
Without any load on the plant, <code>AWHP_1</code> operates at
<i>100&nbsp;%</i> PLR while <code>AWHP_2</code> operates at
<i>57&nbsp;%</i>PLR, with a total input power of around <i>440</i>&nbsp;kW.
</p>
<h4>References</h4>
<p>
TRANE (2022).
<a href=https://www.trane.com/content/dam/Trane/Commercial/global/products-systems/equipment/chillers/air-cooled/ascend/SYS-APG003A-EN_04252022.pdf>
Application Guide – ACX Comprehensive Chiller-Heater System</a>. SYS-APG003A-EN, April, 2022. 
</p>
</html>"));
end TwoUnitsTwoLoops;
