within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Examples;
model ClosedLoopTestCase
  "Simple closed loop model for testing primary control sequences"
  extends Modelica.Icons.Example;

  replaceable package MediumA = Buildings.Media.Air "Medium model";
  replaceable package MediumW = Buildings.Media.Water "Medium model";
  parameter Modelica.SIunits.Power P_nominal=80E3
    "Nominal compressor power (at y=1)";
  parameter Modelica.SIunits.TemperatureDifference dTEva_nominal=10
    "Temperature difference evaporator inlet-outlet";
  parameter Modelica.SIunits.TemperatureDifference dTCon_nominal=10
    "Temperature difference condenser outlet-inlet";
  parameter Real COPc_nominal=3 "Chiller COP";
  parameter Modelica.SIunits.MassFlowRate mCHW_flow_nominal=35
   "Nominal mass flow rate at chilled water";
  parameter Modelica.SIunits.MassFlowRate mCW_flow_nominal=mCHW_flow_nominal * 20 / 6
   "Nominal mass flow rate at condenser water";
  parameter Modelica.SIunits.PressureDifference dp_nominal=500
    "Nominal pressure difference";
  parameter Modelica.SIunits.PressureDifference dpCHW_nominal=125412
    "CHW loop nominal pressure difference";

  Fluid.Movers.FlowControlled_m_flow pumCW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    dp(start=214992),
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nominalValuesDefineDefaultPressureCurve=true)
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={372,74})));

  Fluid.Movers.FlowControlled_dp pumCHW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCHW_flow_nominal,
    m_flow(start=mCHW_flow_nominal),
    dp(start=325474),
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nominalValuesDefineDefaultPressureCurve=true)
    "Chilled water pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-64,136})));
  Fluid.HeatExchangers.CoolingTowers.YorkCalc cooTow1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    PFan_nominal=6000,
    TAirInWB_nominal(displayUnit="degC") = 283.15,
    TApp_nominal=6,
    dp_nominal=14930 + 14930 + 74650,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling tower" annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          origin={229,271})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    use_inputFilter=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={88,144})));
  Fluid.Storage.ExpansionVessel expVesCW(redeclare package Medium = MediumW,
      V_start=1)
    annotation (Placement(transformation(extent={{406,107},{426,127}})));
  Fluid.Chillers.ElectricEIR chi1(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=mCW_flow_nominal,
    m2_flow_nominal=mCHW_flow_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{146,129},{126,149}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=14930 + 89580,
    y_start=1,
    use_inputFilter=false,
    from_dp=true) "Control valve for chilled water leaving from chiller"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={186,130})));
  Fluid.Sensors.TemperatureTwoPort TCHWRet(redeclare package Medium = MediumW,
      m_flow_nominal=2*mCHW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={-86,6})));
  Fluid.Sensors.TemperatureTwoPort           TCWLvgTow(redeclare package Medium =
        MediumW, m_flow_nominal=2*mCW_flow_nominal)
    "Temperature of condenser water leaving the cooling tower"      annotation (
     Placement(transformation(
        extent={{10,-10},{-10,10}},
        origin={378,235},
        rotation=180)));
  BoundaryConditions.WeatherData.ReaderTMY3           weaData(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    annotation (Placement(transformation(extent={{-224,420},{-204,440}})));
  BoundaryConditions.WeatherData.Bus weaBus
    annotation (Placement(transformation(extent={{-166,418},{-146,438}})));
  Fluid.Chillers.ElectricEIR           chi2(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=mCW_flow_nominal,
    m2_flow_nominal=mCHW_flow_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{154,59},{134,79}})));
  Fluid.MixingVolumes.MixingVolume ctrVolLoa(nPorts=3,
    redeclare package Medium = MediumW,
    V=12,
    m_flow_nominal=2*mCHW_flow_nominal)
    annotation (Placement(transformation(extent={{56,-42},{76,-22}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCHW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=14930 + 89580,
    y_start=1,
    use_inputFilter=false,
    from_dp=true) "Control valve for chilled water leaving from chiller"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={196,62})));
  Fluid.HeatExchangers.CoolingTowers.YorkCalc           cooTow2(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    PFan_nominal=6000,
    TAirInWB_nominal(displayUnit="degC") = 283.15,
    TApp_nominal=6,
    dp_nominal=14930 + 14930 + 74650,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling tower"                                   annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        origin={229,235})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    use_inputFilter=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={104,74})));
  Fluid.Movers.FlowControlled_dp pumCHW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCHW_flow_nominal,
    m_flow(start=mCHW_flow_nominal),
    dp(start=325474),
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nominalValuesDefineDefaultPressureCurve=true)
    "Chilled water pump" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-66,102})));
  Fluid.Sensors.TemperatureTwoPort TCHWSup(redeclare package Medium = MediumW,
      m_flow_nominal=2*mCHW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=90,
        origin={230,4})));
  Modelica.Blocks.Sources.Constant cooTowFanCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-390,365})));
  Modelica.Blocks.Sources.Constant valIsoCWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-390,327})));
  Modelica.Blocks.Sources.Constant valIsoCHWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-390,225})));
  CDL.Logical.Sources.Constant chiOn(k=true)
    annotation (Placement(transformation(extent={{-408,104},{-388,124}})));
  Modelica.Blocks.Sources.Trapezoid load(
    rising=6*3600,
    width=3600,
    falling=5*3600,
    period=24*3600,
    offset=0.05*1.5E6,
    startTime=7*3600,
    amplitude=0.95*1.5E6)
    annotation (Placement(transformation(extent={{-642,-88},{-622,-68}})));
  HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
    annotation (Placement(transformation(extent={{20,-42},{40,-22}})));
  Fluid.Storage.ExpansionVessel           expVesCHW(redeclare package Medium =
        MediumW, V_start=1) "Expansion vessel"
    annotation (Placement(transformation(extent={{82,-71},{102,-51}})));
  Fluid.FixedResistances.PressureDrop res(
    redeclare package Medium = MediumW,
    dp_nominal=1000,
    m_flow_nominal=mCHW_flow_nominal)
    annotation (Placement(transformation(extent={{-42,126},{-22,146}})));
  Fluid.FixedResistances.PressureDrop res1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCHW_flow_nominal,
    dp_nominal=1000)
    annotation (Placement(transformation(extent={{-42,92},{-22,112}})));
  Fluid.FixedResistances.PressureDrop res2(
    redeclare package Medium = MediumW,
    dp_nominal=1000,
    m_flow_nominal=mCW_flow_nominal)
    annotation (Placement(transformation(extent={{350,108},{330,128}})));
  Fluid.FixedResistances.PressureDrop res3(
    redeclare package Medium = MediumW,
    dp_nominal=1000,
    m_flow_nominal=mCW_flow_nominal)
    annotation (Placement(transformation(extent={{350,64},{330,84}})));
  Fluid.Sensors.TemperatureTwoPort TCHWEntEva(redeclare package Medium =
        MediumW, m_flow_nominal=2*mCHW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={6,102})));
  Fluid.Sensors.TemperatureTwoPort TCWLvgCon(redeclare package Medium = MediumW,
      m_flow_nominal=2*mCW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={52,182})));
  Fluid.Sensors.TemperatureTwoPort TCWEntCon(redeclare package Medium = MediumW,
      m_flow_nominal=2*mCW_flow_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={282,74})));
  Modelica.Blocks.Math.BooleanToReal mCWFloCtr(realTrue=mCW_flow_nominal)
    "Mass flow rate of condenser loop"
    annotation (Placement(transformation(extent={{-400,272},{-380,292}})));
  CDL.Logical.Sources.Constant pumCWOn(k=true)
    annotation (Placement(transformation(extent={{-450,272},{-430,292}})));
  CDL.Logical.Sources.Constant chiOn1(k=true)
    annotation (Placement(transformation(extent={{-452,172},{-432,192}})));
  Modelica.Blocks.Math.BooleanToReal dpCHWCtr(realTrue=dpCHW_nominal)
    "Mass flow rate of condenser loop"
    annotation (Placement(transformation(extent={{-400,172},{-380,192}})));
  CDL.Continuous.Sources.Constant TSetCHWSup(k=7)
    annotation (Placement(transformation(extent={{-654,402},{-634,422}})));
  Staging.Subsequences.CapacityRequirement capReq
    annotation (Placement(transformation(extent={{-594,278},{-574,298}})));
  Fluid.Sensors.VolumeFlowRate senVolFlo(redeclare package Medium = MediumW,
      m_flow_nominal=2*mCHW_flow_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-86,36})));
  Modelica.Blocks.Sources.RealExpression chi1PLR(y=chi1.PLR1)
    annotation (Placement(transformation(extent={{-646,120},{-626,140}})));
  UnitConversions.From_degC from_degC
    annotation (Placement(transformation(extent={{-616,402},{-596,422}})));
  Modelica.Blocks.Sources.RealExpression chi2PLR1(y=chi2.PLR1)
    annotation (Placement(transformation(extent={{-644,92},{-624,112}})));
  Fluid.Movers.FlowControlled_m_flow pumCW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=mCW_flow_nominal,
    dp(start=214992),
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    nominalValuesDefineDefaultPressureCurve=true)
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={370,118})));
  Modelica.Blocks.Sources.BooleanExpression pumCW1On(y=pumCW1.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-402,424},{-382,444}})));
  Modelica.Blocks.Sources.BooleanExpression pumCW2On(y=pumCW2.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-402,396},{-382,416}})));
  Modelica.Blocks.Sources.RealExpression cooTow1FanSpe(y=cooTow1.y)
    annotation (Placement(transformation(extent={{-402,380},{-382,400}})));
  Tower.Fan tow1FanCtr(
    minFanSpe=0.1,
    controllerTypeFan=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    kFan=0.1,
    TiFan=300,
    dTAboSet=0.55)
    annotation (Placement(transformation(extent={{-288,334},{-268,354}})));
  CDL.Continuous.Sources.Constant dTSetLifChi(k=11) "Chiller lift setpoint"
    annotation (Placement(transformation(extent={{-652,356},{-632,376}})));
equation
  connect(mCWFloCtr.y, pumCW2.m_flow_in)
    annotation (Line(
      points={{-379,282},{372,282},{372,86}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCW1.port_a, chi1.port_b1) annotation (Line(
      points={{98,144},{98,145},{126,145}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(chi1.port_b2, valIsoCHW1.port_a) annotation (Line(
      points={{146,133},{176,133},{176,130}},
      color={0,127,255},
      smooth=Smooth.None,
      thickness=0.5));
  connect(weaData.weaBus,weaBus)  annotation (Line(
      points={{-204,430},{-204,428},{-156,428}},
      color={255,204,51},
      thickness=0.5,
      smooth=Smooth.None), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(cooTow1.TAir, weaBus.TWetBul) annotation (Line(
      points={{217,275},{217,429},{-156,429},{-156,428}},
      color={0,0,127},
      smooth=Smooth.None,
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(chi2.port_b1, valIsoCW2.port_a)
    annotation (Line(points={{134,75},{114,75},{114,74}}, color={0,127,255}));
  connect(chi2.port_b2, valIsoCHW2.port_a) annotation (Line(points={{154,63},{186,
          63},{186,62}},          color={0,127,255}));
  connect(TCHWSup.port_b, ctrVolLoa.ports[1]) annotation (Line(points={{230,-6},
          {230,-42},{63.3333,-42}},
                               color={0,127,255}));
  connect(valIsoCWCtr.y, valIsoCW2.y) annotation (Line(
      points={{-379,327},{104.5,327},{104.5,86},{104,86}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(chiOn.y, chi1.on) annotation (Line(points={{-387,114},{162,114},{162,
          142},{148,142}},
                      color={255,0,255}));
  connect(chiOn.y, chi2.on) annotation (Line(points={{-387,114},{162,114},{162,
          72},{156,72}},
                     color={255,0,255}));
  connect(ctrVolLoa.heatPort, prescribedHeatFlow.port)
    annotation (Line(points={{56,-32},{40,-32}}, color={191,0,0}));
  connect(valIsoCHWCtr.y, valIsoCHW1.y) annotation (Line(
      points={{-379,225},{186.5,225},{186.5,142},{186,142}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCHWCtr.y, valIsoCHW2.y) annotation (Line(
      points={{-379,225},{196.5,225},{196.5,74},{196,74}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(expVesCW.port_a, pumCW2.port_a)
    annotation (Line(points={{416,107},{416,74},{382,74}}, color={0,127,255}));
  connect(weaBus.TWetBul, cooTow2.TAir) annotation (Line(
      points={{-156,428},{-156,429},{217,429},{217,239}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(pumCHW1.port_b, res.port_a)
    annotation (Line(points={{-54,136},{-42,136}},
                                                 color={0,127,255}));
  connect(pumCHW2.port_b, res1.port_a)
    annotation (Line(points={{-56,102},{-42,102}},
                                                 color={0,127,255}));
  connect(pumCW1.port_b, res2.port_a)
    annotation (Line(points={{360,118},{350,118}}, color={0,127,255}));
  connect(pumCW2.port_b, res3.port_a)
    annotation (Line(points={{362,74},{350,74}}, color={0,127,255}));
  connect(expVesCHW.port_a, ctrVolLoa.ports[2]) annotation (Line(points={{92,-71},
          {66,-71},{66,-42}},           color={0,127,255}));
  connect(ctrVolLoa.ports[3], TCHWRet.port_a) annotation (Line(points={{68.6667,
          -42},{-86,-42},{-86,-4}},  color={0,127,255}));
  connect(res1.port_b, TCHWEntEva.port_a)
    annotation (Line(points={{-22,102},{-4,102}},
                                                color={0,127,255}));
  connect(res.port_b, TCHWEntEva.port_a) annotation (Line(points={{-22,136},{-16,
          136},{-16,102},{-4,102}},
                                 color={0,127,255}));
  connect(TCHWEntEva.port_b, chi2.port_a2) annotation (Line(points={{16,102},{30,
          102},{30,63},{134,63}},color={0,127,255}));
  connect(valIsoCW1.port_b, TCWLvgCon.port_a)
    annotation (Line(points={{78,144},{52,144},{52,172}},
                                                 color={0,127,255}));
  connect(TCWLvgCon.port_b, cooTow2.port_a) annotation (Line(points={{52,192},{52,
          235},{219,235}},           color={0,127,255}));
  connect(TCWLvgCon.port_b, cooTow1.port_a) annotation (Line(points={{52,192},{52,
          271},{219,271}}, color={0,127,255}));
  connect(res3.port_b, TCWEntCon.port_a)
    annotation (Line(points={{330,74},{292,74}}, color={0,127,255}));
  connect(res2.port_b, TCWEntCon.port_a) annotation (Line(points={{330,118},{318,
          118},{318,74},{292,74}}, color={0,127,255}));
  connect(TCWEntCon.port_b, chi2.port_a1) annotation (Line(points={{272,74},{154,
          74},{154,75}},          color={0,127,255}));
  connect(TCWEntCon.port_b, chi1.port_a1) annotation (Line(points={{272,74},{246,
          74},{246,145},{146,145}}, color={0,127,255}));
  connect(cooTow2.port_b, TCWLvgTow.port_a)
    annotation (Line(points={{239,235},{368,235}}, color={0,127,255}));
  connect(TCWLvgTow.port_b, pumCW2.port_a)
    annotation (Line(points={{388,235},{388,74},{382,74}}, color={0,127,255}));
  connect(TCWLvgTow.port_b, pumCW1.port_a) annotation (Line(points={{388,235},{388,
          118},{380,118}}, color={0,127,255}));
  connect(cooTow1.port_b, TCWLvgTow.port_a) annotation (Line(points={{239,271},{
          340,271},{340,235},{368,235}}, color={0,127,255}));
  connect(TCHWEntEva.port_b, chi1.port_a2) annotation (Line(points={{16,102},{30,
          102},{30,133},{126,133}},color={0,127,255}));
  connect(mCWFloCtr.y, pumCW1.m_flow_in) annotation (Line(
      points={{-379,282},{369.5,282},{369.5,130},{370,130}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(mCWFloCtr.u, pumCWOn.y)
    annotation (Line(points={{-402,282},{-429,282}}, color={255,0,255}));
  connect(chiOn1.y, dpCHWCtr.u)
    annotation (Line(points={{-431,182},{-402,182}}, color={255,0,255}));
  connect(dpCHWCtr.y, pumCHW1.dp_in) annotation (Line(
      points={{-379,182},{-64,182},{-64,148}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(dpCHWCtr.y, pumCHW2.dp_in) annotation (Line(
      points={{-379,182},{-66,182},{-66,114}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCWCtr.y, valIsoCW1.y) annotation (Line(
      points={{-379,327},{88,327},{88,156}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCHW2.port_b, TCHWSup.port_a)
    annotation (Line(points={{206,62},{230,62},{230,14}},  color={0,127,255}));
  connect(valIsoCHW1.port_b, TCHWSup.port_a) annotation (Line(points={{196,130},
          {230,130},{230,14}},  color={0,127,255}));
  connect(TCHWRet.T, capReq.TChiWatRet) annotation (Line(points={{-97,6},{-656,6},
          {-656,288},{-595,288}},           color={0,0,127}));
  connect(TCHWRet.port_b, senVolFlo.port_a)
    annotation (Line(points={{-86,16},{-86,26}},   color={0,127,255}));
  connect(senVolFlo.port_b, pumCHW2.port_a)
    annotation (Line(points={{-86,46},{-86,102},{-76,102}},
                                                         color={0,127,255}));
  connect(senVolFlo.port_b, pumCHW1.port_a)
    annotation (Line(points={{-86,46},{-86,136},{-74,136}},
                                                         color={0,127,255}));
  connect(senVolFlo.V_flow, capReq.VChiWat_flow) annotation (Line(points={{-97,36},
          {-608,36},{-608,283},{-595,283}},       color={0,0,127}));
  connect(TSetCHWSup.y, from_degC.u)
    annotation (Line(points={{-633,412},{-618,412}}, color={0,0,127}));
  connect(from_degC.y, capReq.TChiWatSupSet) annotation (Line(points={{-595,412},
          {-550,412},{-550,327},{-595,327},{-595,293}}, color={0,0,127}));
  connect(from_degC.y, chi1.TSet) annotation (Line(
      points={{-595,412},{172,412},{172,136},{148,136}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(from_degC.y, chi2.TSet) annotation (Line(
      points={{-595,412},{171.5,412},{171.5,66},{156,66}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(load.y, prescribedHeatFlow.Q_flow)
    annotation (Line(points={{-621,-78},{-300,-78},{-300,-32},{20,-32}},
                                                   color={0,0,127}));
  connect(valIsoCW2.port_b, TCWLvgCon.port_a)
    annotation (Line(points={{94,74},{52,74},{52,172}}, color={0,127,255}));
  connect(pumCW1On.y, tow1FanCtr.uConWatPum[1]) annotation (Line(points={{-381,434},
          {-344,434},{-344,352},{-290,352}}, color={255,0,255}));
  connect(pumCW2On.y, tow1FanCtr.uConWatPum[2]) annotation (Line(points={{-381,406},
          {-344.5,406},{-344.5,352},{-290,352}}, color={255,0,255}));
  connect(cooTow1FanSpe.y, tow1FanCtr.uFanSpe) annotation (Line(points={{-381,390},
          {-356,390},{-356,336},{-290,336}}, color={0,0,127}));
  connect(dTSetLifChi.y, tow1FanCtr.dTRef) annotation (Line(points={{-631,366},{
          -144,366},{-144,348},{-290,348}}, color={0,0,127}));
  connect(TCWEntCon.T, tow1FanCtr.TConWatRet) annotation (Line(points={{282,85},
          {312,85},{312,340},{-290,340}}, color={0,0,127}));
  connect(TCHWSup.T, tow1FanCtr.TChiWatSup) annotation (Line(points={{241,4},{292,
          4},{292,344},{-290,344}}, color={0,0,127}));
  connect(tow1FanCtr.yFanSpe, cooTow1.y) annotation (Line(points={{-267,339},{186.5,
          339},{186.5,279},{217,279}}, color={0,0,127}));
  connect(tow1FanCtr.yFanSpe, cooTow2.y) annotation (Line(points={{-267,339},{186.5,
          339},{186.5,243},{217,243}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-700,
            -260},{660,460}})),
                          Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-700,-260},{660,460}}), graphics={
        Text(
          extent={{-700,460},{-586,444}},
          lineColor={28,108,200},
          textString="Setpoints"),
        Text(
          extent={{-700,-20},{-586,-36}},
          lineColor={28,108,200},
          textString="Loads"),
        Text(
          extent={{-566,460},{-452,444}},
          lineColor={28,108,200},
          textString="Controls")}));
end ClosedLoopTestCase;
