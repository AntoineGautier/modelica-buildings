within Buildings.Fluid.HeatPumps.Examples;
model OneUnitReset
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
    final min=0)=50 + 273.15
    "Design HW supply temperature"
    annotation(Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature THeaWatRet_nominal(
    final min=0)=42 + 273.15
    "Design HW return temperature"
    annotation(Dialog(group="Nominal condition"));

  parameter HeatPumps.Data.EquationFitReversible.Generic dat(
    dpHeaLoa_nominal=40000,
    dpHeaSou_nominal=100,
    hea(
      mLoa_flow=dat.hea.Q_flow/abs(THeaWatSup_nominal-THeaWatRet_nominal)/4186,
      mSou_flow=1E-4*dat.hea.Q_flow,
      Q_flow=1E6,
      P=dat.hea.Q_flow/2.2,
      coeQ={-4.3120835191,-0.756614628,6.0736234165,0,0},
      coeP={-5.4389220207,5.8414519231,0.592420928,0,0},
      TRefLoa=313.15,
      TRefSou=280.15),
    coo(
      mLoa_flow=0,
      mSou_flow=0,
      Q_flow=-1,
      P=0,
      coeQ={-2.2545246871,6.9089257665,-3.6548225094,0,0},
      coeP={-5.808601045,1.6894933909,5.1167787434,0,0},
      TRefLoa=285.15,
      TRefSou=308.15))
    "Heat pump parameters"
    annotation (Placement(transformation(extent={{-300,200},{-280,220}})));

  Movers.Preconfigured.SpeedControlled_y P_2(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal(displayUnit="Pa") = dat.dpHeaLoa_nominal + 1E4)
    annotation (Placement(transformation(extent={{40,50},{20,70}})));
  Controls.OBC.CDL.Logical.Sources.TimeTable booTimTab(
    table=[0,0; 1,0; 1,1; 10,1],
    timeScale=1000,
    period=10000)
    annotation (Placement(transformation(extent={{-300,150},{-280,170}})));
  FixedResistances.CheckValve che2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=P_2.m_flow_nominal,
    dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{20,50},{0,70}})));
  FixedResistances.PressureDrop decHeaWat(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal=3000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={200,100})));
  Sources.Boundary_pT    BUFFER_HHW(
    redeclare final package Medium = Buildings.Media.Water,
    T=THeaWatRet_nominal,
    nPorts=2) "HHW buffer tank" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={140,150})));
  BaseClasses.AirToWaterHeatPump AWHP_2(redeclare package Medium =
        Buildings.Media.Water, dat=dat) "AWHP"
    annotation (Placement(transformation(extent={{-50,50},{-70,70}})));
  Controls.OBC.CDL.Reals.Sources.Constant THeaWatSupSet(k=THeaWatSup_nominal)
    "HWST setpoint"
    annotation (Placement(transformation(extent={{-300,-50},{-280,-30}})));
  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    "Outdoor conditions"
    annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-100,200})));
  Controls.OBC.CDL.Logical.Sources.Constant fal(k=true)
    annotation (Placement(transformation(extent={{-300,10},{-280,30}})));
  Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-250,170},{-230,190}})));
  Sensors.TemperatureTwoPort TE_3(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-10,50},{-30,70}})));
  Sensors.TemperatureTwoPort TE_4(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-90,50},{-110,70}})));
  Movers.Preconfigured.SpeedControlled_y P_1(
    redeclare package Medium = Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal(displayUnit="Pa") = dat.dpHeaLoa_nominal + 1E4)
    annotation (Placement(transformation(extent={{40,-150},{20,-130}})));
  FixedResistances.CheckValve che1(
    redeclare package Medium = Media.Water,
    m_flow_nominal=P_2.m_flow_nominal,
    dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{20,-150},{0,-130}})));
  FixedResistances.PressureDrop decHeaWat1(
    redeclare package Medium = Media.Water,
    m_flow_nominal=dat.hea.mLoa_flow,
    dp_nominal=3000) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={200,-100})));
  Sources.Boundary_pT    BUFFER_HHW1(
    redeclare final package Medium = Media.Water,
    T=THeaWatRet_nominal,
    nPorts=2) "HHW buffer tank" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=270,
        origin={140,-50})));
  BaseClasses.AirToWaterHeatPump AWHP_1(redeclare package Medium = Media.Water,
      dat=dat)                          "AWHP"
    annotation (Placement(transformation(extent={{-50,-150},{-70,-130}})));
  Sensors.TemperatureTwoPort TE_1(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-10,-150},{-30,-130}})));
  Sensors.TemperatureTwoPort TE_2(redeclare package Medium = Media.Water,
      m_flow_nominal=dat.hea.mLoa_flow)
    annotation (Placement(transformation(extent={{-90,-150},{-110,-130}})));
  Controls.OBC.CDL.Reals.AddParameter addPar(p=-5)
    annotation (Placement(transformation(extent={{-250,-30},{-230,-10}})));
equation
  connect(weaDat.weaBus, AWHP_2.weaBus) annotation (Line(
      points={{-90,200},{-80,200},{-80,80},{-60,80},{-60,70}},
      color={255,204,51},
      thickness=0.5));
  connect(fal.y, AWHP_2.yHea) annotation (Line(points={{-278,20},{-40,20},{-40,64},
          {-48,64}}, color={255,0,255}));
  connect(booTimTab.y[1], booToRea.u) annotation (Line(points={{-278,160},{-260,
          160},{-260,180},{-252,180}}, color={255,0,255}));
  connect(booToRea.y, P_2.y)
    annotation (Line(points={{-228,180},{30,180},{30,72}}, color={0,0,127}));
  connect(booTimTab.y[1], AWHP_2.y1) annotation (Line(points={{-278,160},{-40,160},
          {-40,68},{-48,68}}, color={255,0,255}));
  connect(P_2.port_b, che2.port_a)
    annotation (Line(points={{20,60},{20,60}}, color={0,127,255}));
  connect(TE_4.port_b, BUFFER_HHW.ports[1]) annotation (Line(points={{-110,60},{
          -160,60},{-160,140},{141,140}}, color={0,127,255}));
  connect(decHeaWat.port_b, P_2.port_a)
    annotation (Line(points={{200,90},{200,60},{40,60}}, color={0,127,255}));
  connect(che2.port_b, TE_3.port_a)
    annotation (Line(points={{0,60},{-10,60}}, color={0,127,255}));
  connect(TE_3.port_b, AWHP_2.port_a)
    annotation (Line(points={{-30,60},{-50,60}}, color={0,127,255}));
  connect(AWHP_2.port_b, TE_4.port_a) annotation (Line(points={{-70,60},{-80,60},
          {-80,60},{-90,60}}, color={0,127,255}));
  connect(weaDat.weaBus,AWHP_1. weaBus) annotation (Line(
      points={{-90,200},{-80,200},{-80,-120},{-60,-120},{-60,-130}},
      color={255,204,51},
      thickness=0.5));
  connect(fal.y,AWHP_1. yHea) annotation (Line(points={{-278,20},{-40,20},{-40,-136},
          {-48,-136}},
                     color={255,0,255}));
  connect(booToRea.y,P_1. y)
    annotation (Line(points={{-228,180},{30,180},{30,-128}},
                                                           color={0,0,127}));
  connect(booTimTab.y[1],AWHP_1. y1) annotation (Line(points={{-278,160},{-40,160},
          {-40,-132},{-48,-132}},
                              color={255,0,255}));
  connect(P_1.port_b,che1. port_a)
    annotation (Line(points={{20,-140},{20,-140}},
                                               color={0,127,255}));
  connect(TE_2.port_b, BUFFER_HHW1.ports[1]) annotation (Line(points={{-110,-140},
          {-160,-140},{-160,-60},{141,-60}}, color={0,127,255}));
  connect(decHeaWat1.port_b, P_1.port_a) annotation (Line(points={{200,-110},{200,
          -140},{40,-140}}, color={0,127,255}));
  connect(che1.port_b, TE_1.port_a)
    annotation (Line(points={{0,-140},{-10,-140}}, color={0,127,255}));
  connect(TE_1.port_b, AWHP_1.port_a)
    annotation (Line(points={{-30,-140},{-50,-140}}, color={0,127,255}));
  connect(AWHP_1.port_b, TE_2.port_a)
    annotation (Line(points={{-70,-140},{-90,-140}}, color={0,127,255}));
  connect(THeaWatSupSet.y, AWHP_1.TSet) annotation (Line(points={{-278,-40},{-36,
          -40},{-36,-146},{-48,-146}}, color={0,0,127}));
  connect(THeaWatSupSet.y, addPar.u) annotation (Line(points={{-278,-40},{-260,-40},
          {-260,-20},{-252,-20}}, color={0,0,127}));
  connect(addPar.y, AWHP_2.TSet) annotation (Line(points={{-228,-20},{-36,-20},{
          -36,54},{-48,54}}, color={0,0,127}));
  connect(BUFFER_HHW.ports[2], decHeaWat.port_a) annotation (Line(points={{139,140},
          {200,140},{200,110}}, color={0,127,255}));
  connect(BUFFER_HHW1.ports[2], decHeaWat1.port_a) annotation (Line(points={{139,
          -60},{200,-60},{200,-90}}, color={0,127,255}));
  annotation (
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-220,-220},{220,
            220}})),
experiment(Tolerance=1e-06, StopTime=10000.0),
__Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Fluid/HeatPumps/Examples/TwoUnitsTwoLoops.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This model illustrates the impact of the HW supply temperature reset
on the HP COP as computed by
Buildings.Fluid.HeatPumps.EquationFitReversible.
We can observe that a change of <i>5</i>&nbsp;K in the supply temperature 
setpoint does not impact the computed <i>COP</i>.
The HP model only captures the impact of the condenser entering 
HW temperature on COP. The impact of both the part load ratio 
and the condenser leaving temperature are disregarded.
</p>
</html>"));
end OneUnitReset;
