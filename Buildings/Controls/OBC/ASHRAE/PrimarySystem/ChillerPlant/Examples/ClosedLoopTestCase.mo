within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Examples;
model ClosedLoopTestCase
  "Simple closed loop model for testing primary control sequences"
  extends Modelica.Icons.Example;

  replaceable package MediumA = Buildings.Media.Air "Medium model";
  replaceable package MediumW = Buildings.Media.Water "Medium model";

  parameter Modelica.SIunits.TemperatureDifference dTEva_nominal=5
    "Temperature difference evaporator inlet-outlet";
  parameter Modelica.SIunits.TemperatureDifference dTCon_nominal=5
    "Temperature difference condenser outlet-inlet";
  parameter Modelica.SIunits.HeatFlowRate q_flowEva_nominal = 742E3 "Chiller nominal capacity";
  parameter Real EER_nominal = 5.42 "Chiller EER nominal value";
  parameter Modelica.SIunits.SpecificHeatCapacity cpLiq = 4186 "Specific heat capacity of water";
  parameter Modelica.SIunits.MassFlowRate m_flowCHW_nominal=q_flowEva_nominal / cpLiq / dTEva_nominal
   "Nominal mass flow rate at chilled water";
  parameter Modelica.SIunits.MassFlowRate m_flowCW_nominal=m_flowCHW_nominal* (1 + 1 / EER_nominal)
   "Nominal mass flow rate at condenser water";
  parameter Modelica.SIunits.PressureDifference dp_nominal=500
    "Nominal pressure difference";
  parameter Modelica.SIunits.PressureDifference dpCHW_nominal=125412
    "CHW loop nominal pressure difference";
  parameter Modelica.SIunits.PressureDifference dpCW_nominal=214992
    "CW loop nominal pressure difference";

  Fluid.Movers.SpeedControlled_y pumCW2(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_flowCW_nominal*{0.5,1.0,1.5}, dp=dpCW_nominal*{1.2,1.0,
            0.2})))
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={362,74})));
  Fluid.HeatExchangers.CoolingTowers.YorkCalc cooTow1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_flowCW_nominal,
    PFan_nominal=6000,
    TAirInWB_nominal(displayUnit="degC") = 283.15,
    TApp_nominal=6,
    dp_nominal=14930 + 14930 + 74650,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling tower" annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          origin={229,271})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_flowCW_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    use_inputFilter=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={88,144})));
  Fluid.Chillers.ElectricEIR chi1(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=m_flowCW_nominal,
    m2_flow_nominal=m_flowCHW_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{146,129},{126,149}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_flowCHW_nominal,
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
      m_flow_nominal=2*m_flowCHW_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={-86,30})));
  Fluid.Sensors.TemperatureTwoPort           TCWLvgTow(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_flowCW_nominal)
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
    m1_flow_nominal=m_flowCW_nominal,
    m2_flow_nominal=m_flowCHW_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{154,59},{134,79}})));
  Fluid.MixingVolumes.MixingVolume ctrVolLoa(nPorts=3,
    redeclare package Medium = MediumW,
    V=12,
    m_flow_nominal=2*m_flowCHW_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{56,-42},{76,-22}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_flowCHW_nominal,
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
    m_flow_nominal=m_flowCW_nominal,
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
    m_flow_nominal=m_flowCW_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    use_inputFilter=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={104,74})));
  Fluid.Sensors.TemperatureTwoPort TCHWSup(redeclare package Medium = MediumW,
      m_flow_nominal=2*m_flowCHW_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={230,16})));
  Modelica.Blocks.Sources.Constant cooTowFanCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        origin={-390,365})));
  Modelica.Blocks.Sources.Constant valIsoCWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-390,327})));
  Modelica.Blocks.Sources.Constant valIsoCHWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-392,201})));
  Modelica.Blocks.Sources.Trapezoid load(
    rising=6*3600,
    width=3600,
    falling=5*3600,
    period=24*3600,
    offset=0.05*1.5E6,
    startTime=7*3600,
    amplitude=0.95*1.5E6)
    annotation (Placement(transformation(extent={{-656,-42},{-636,-22}})));
  HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
    annotation (Placement(transformation(extent={{20,-42},{40,-22}})));
  Fluid.Sensors.TemperatureTwoPort TCHWEntEva(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_flowCHW_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={6,102})));
  Fluid.Sensors.TemperatureTwoPort TCWLvgCon(redeclare package Medium = MediumW,
      m_flow_nominal=2*m_flowCW_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,10},{-10,-10}},
        rotation=-90,
        origin={52,182})));
  Fluid.Sensors.TemperatureTwoPort TCWEntCon(redeclare package Medium = MediumW,
      m_flow_nominal=2*m_flowCW_nominal)
    "Temperature of chilled water entering chiller" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={282,74})));
  CDL.Continuous.Sources.Constant TSetCHWSup(k=7)
    annotation (Placement(transformation(extent={{-654,402},{-634,422}})));
  Staging.Subsequences.CapacityRequirement capReq
    annotation (Placement(transformation(extent={{-564,294},{-544,314}})));
  Fluid.Sensors.VolumeFlowRate senVolFlo(redeclare package Medium = MediumW,
      m_flow_nominal=2*m_flowCHW_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-86,60})));
  Modelica.Blocks.Sources.RealExpression chi1PLR(y=chi1.PLR1)
    annotation (Placement(transformation(extent={{-548,140},{-528,160}})));
  UnitConversions.From_degC from_degC
    annotation (Placement(transformation(extent={{-616,402},{-596,422}})));
  Modelica.Blocks.Sources.RealExpression chi2PLR1(y=chi2.PLR1)
    annotation (Placement(transformation(extent={{-548,112},{-528,132}})));
  Fluid.Movers.SpeedControlled_y     pumCW1(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_flowCW_nominal*{0.5,1.0,1.5}, dp=dpCW_nominal*{1.2,1.0,
            0.2})))
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={362,116})));
  Modelica.Blocks.Sources.BooleanExpression pumCW1On(y=pumCW1.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-402,424},{-382,444}})));
  Modelica.Blocks.Sources.BooleanExpression pumCW2On(y=pumCW2.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-402,396},{-382,416}})));
  Modelica.Blocks.Sources.RealExpression cooTow1FanSpe(y=cooTow1.y)
    annotation (Placement(transformation(extent={{-402,380},{-382,400}})));
  Tower.Fan tow1FanCtr(
    minFanSpe=0.1,
    dTAboSet=0.55,
    TiFan=300,
    controllerTypeFan=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    kFan=0.5)
    annotation (Placement(transformation(extent={{-288,334},{-268,354}})));
  CDL.Continuous.Sources.Constant dTSetLifChi(k=11) "Chiller lift setpoint"
    annotation (Placement(transformation(extent={{-654,338},{-634,358}})));
  Fluid.Movers.SpeedControlled_y pumCHW2(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_flowCHW_nominal*{0.5,1.0,1.5}, dp=dpCHW_nominal*{1.2,1.0,
            0.2})))
    "Chilled water pump" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-60,102})));
  Fluid.Movers.SpeedControlled_y           pumCHW1(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_flowCHW_nominal*{0.5,1.0,1.5}, dp=dpCHW_nominal*{1.2,1.0,
            0.2})))
    "Chilled water pump" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-64,142})));
  Modelica.Blocks.Sources.Constant pumCHWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-392,157})));
  Fluid.Sources.Boundary_pT expCW(redeclare package Medium = MediumW, nPorts=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={416,92})));
  Fluid.Sources.Boundary_pT expCHW(redeclare package Medium = MediumW, nPorts=1)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={96,-10})));
  Modelica.Blocks.Sources.Constant pumCWCtr(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-390,281})));
  Generic.EquipmentRotationTwo equRot
    annotation (Placement(transformation(extent={{-440,192},{-420,212}})));
  Modelica.Blocks.Sources.BooleanExpression chi1On(y=chi1.on)
    annotation (Placement(transformation(extent={{-654,246},{-634,266}})));
  Modelica.Blocks.Sources.BooleanExpression chi2On(y=chi2.on)
    annotation (Placement(transformation(extent={{-654,222},{-634,242}})));
  CDL.Logical.Sources.Constant con(k=true)
    annotation (Placement(transformation(extent={{-506,198},{-486,218}})));
  Staging.Subsequences.Capacities staCap(staNomCap=q_flowEva_nominal*{1,2})
    annotation (Placement(transformation(extent={{-520,234},{-500,254}})));
  CDL.Conversions.BooleanToInteger booToInt
    annotation (Placement(transformation(extent={{-618,246},{-598,266}})));
  CDL.Conversions.BooleanToInteger booToInt1
    annotation (Placement(transformation(extent={{-618,222},{-598,242}})));
  CDL.Integers.MultiSum mulSumInt(nin=2)
    annotation (Placement(transformation(extent={{-562,234},{-542,254}})));
equation
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
  connect(TCHWSup.port_b, ctrVolLoa.ports[1]) annotation (Line(points={{230,6},
          {230,-42},{63.3333,-42}}, color={0,127,255}));
  connect(valIsoCWCtr.y, valIsoCW2.y) annotation (Line(
      points={{-379,327},{104.5,327},{104.5,86},{104,86}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(ctrVolLoa.heatPort, prescribedHeatFlow.port)
    annotation (Line(points={{56,-32},{40,-32}}, color={191,0,0}));
  connect(valIsoCHWCtr.y, valIsoCHW1.y) annotation (Line(
      points={{-381,201},{184.5,201},{184.5,142},{186,142}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCHWCtr.y, valIsoCHW2.y) annotation (Line(
      points={{-381,201},{194.5,201},{194.5,74},{196,74}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(weaBus.TWetBul, cooTow2.TAir) annotation (Line(
      points={{-156,428},{-156,429},{217,429},{217,239}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(ctrVolLoa.ports[2], TCHWRet.port_a) annotation (Line(points={{66,-42},
          {-86,-42},{-86,20}},       color={0,127,255}));
  connect(TCHWEntEva.port_b, chi2.port_a2) annotation (Line(points={{16,102},{30,
          102},{30,63},{134,63}},color={0,127,255}));
  connect(valIsoCW1.port_b, TCWLvgCon.port_a)
    annotation (Line(points={{78,144},{52,144},{52,172}},
                                                 color={0,127,255}));
  connect(TCWLvgCon.port_b, cooTow2.port_a) annotation (Line(points={{52,192},{52,
          235},{219,235}},           color={0,127,255}));
  connect(TCWLvgCon.port_b, cooTow1.port_a) annotation (Line(points={{52,192},{52,
          271},{219,271}}, color={0,127,255}));
  connect(TCWEntCon.port_b, chi2.port_a1) annotation (Line(points={{272,74},{154,
          74},{154,75}},          color={0,127,255}));
  connect(TCWEntCon.port_b, chi1.port_a1) annotation (Line(points={{272,74},{246,
          74},{246,145},{146,145}}, color={0,127,255}));
  connect(cooTow2.port_b, TCWLvgTow.port_a)
    annotation (Line(points={{239,235},{368,235}}, color={0,127,255}));
  connect(TCWLvgTow.port_b, pumCW2.port_a)
    annotation (Line(points={{388,235},{388,74},{372,74}}, color={0,127,255}));
  connect(TCWLvgTow.port_b, pumCW1.port_a) annotation (Line(points={{388,235},{388,
          116},{372,116}}, color={0,127,255}));
  connect(cooTow1.port_b, TCWLvgTow.port_a) annotation (Line(points={{239,271},{
          340,271},{340,235},{368,235}}, color={0,127,255}));
  connect(TCHWEntEva.port_b, chi1.port_a2) annotation (Line(points={{16,102},{30,
          102},{30,133},{126,133}},color={0,127,255}));
  connect(valIsoCWCtr.y, valIsoCW1.y) annotation (Line(
      points={{-379,327},{88,327},{88,156}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCHW2.port_b, TCHWSup.port_a)
    annotation (Line(points={{206,62},{230,62},{230,26}},  color={0,127,255}));
  connect(valIsoCHW1.port_b, TCHWSup.port_a) annotation (Line(points={{196,130},
          {230,130},{230,26}},  color={0,127,255}));
  connect(TCHWRet.T, capReq.TChiWatRet) annotation (Line(points={{-97,30},{-586,
          30},{-586,304},{-565,304}},       color={0,0,127}));
  connect(TCHWRet.port_b, senVolFlo.port_a)
    annotation (Line(points={{-86,40},{-86,50}},   color={0,127,255}));
  connect(senVolFlo.V_flow, capReq.VChiWat_flow) annotation (Line(points={{-97,60},
          {-580,60},{-580,299},{-565,299}},       color={0,0,127}));
  connect(TSetCHWSup.y, from_degC.u)
    annotation (Line(points={{-633,412},{-618,412}}, color={0,0,127}));
  connect(from_degC.y, capReq.TChiWatSupSet) annotation (Line(points={{-595,412},
          {-586,412},{-586,309},{-565,309}},            color={0,0,127}));
  connect(from_degC.y, chi1.TSet) annotation (Line(
      points={{-595,412},{172,412},{172,136},{148,136}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(from_degC.y, chi2.TSet) annotation (Line(
      points={{-595,412},{171.5,412},{171.5,66},{156,66}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(load.y, prescribedHeatFlow.Q_flow)
    annotation (Line(points={{-635,-32},{20,-32}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCW2.port_b, TCWLvgCon.port_a)
    annotation (Line(points={{94,74},{52,74},{52,172}}, color={0,127,255}));
  connect(pumCW1On.y, tow1FanCtr.uConWatPum[1]) annotation (Line(points={{-381,434},
          {-344,434},{-344,352},{-290,352}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(pumCW2On.y, tow1FanCtr.uConWatPum[2]) annotation (Line(points={{-381,406},
          {-344.5,406},{-344.5,352},{-290,352}}, color={255,0,255},
      pattern=LinePattern.Dash));
  connect(cooTow1FanSpe.y, tow1FanCtr.uFanSpe) annotation (Line(points={{-381,390},
          {-356,390},{-356,336},{-290,336}}, color={0,0,127}));
  connect(dTSetLifChi.y, tow1FanCtr.dTRef) annotation (Line(points={{-633,348},{
          -290,348}},                       color={0,0,127}));
  connect(TCWEntCon.T, tow1FanCtr.TConWatRet) annotation (Line(
      points={{282,85},{-344,85},{-344,340},{-290,340}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TCHWSup.T, tow1FanCtr.TChiWatSup) annotation (Line(
      points={{219,16},{-350,16},{-350,344},{-290,344}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(tow1FanCtr.yFanSpe, cooTow1.y) annotation (Line(
      points={{-267,339},{186.5,339},{186.5,279},{217,279}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(tow1FanCtr.yFanSpe, cooTow2.y) annotation (Line(
      points={{-267,339},{186.5,339},{186.5,243},{217,243}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(senVolFlo.port_b, pumCHW2.port_a) annotation (Line(points={{-86,70},{-86,
          102},{-70,102}}, color={0,127,255}));
  connect(senVolFlo.port_b, pumCHW1.port_a) annotation (Line(points={{-86,70},{-86,
          142},{-74,142}},     color={0,127,255}));
  connect(pumCHWCtr.y, pumCHW1.y) annotation (Line(points={{-381,157},{-64.5,
          157},{-64.5,154},{-64,154}},
                                   color={0,0,127},
      pattern=LinePattern.Dash));
  connect(pumCHWCtr.y, pumCHW2.y) annotation (Line(points={{-381,157},{-59.5,
          157},{-59.5,114},{-60,114}},
                                  color={0,0,127},
      pattern=LinePattern.Dash));
  connect(expCW.ports[1], pumCW2.port_a)
    annotation (Line(points={{416,82},{416,74},{372,74}}, color={0,127,255}));
  connect(expCHW.ports[1], ctrVolLoa.ports[3]) annotation (Line(points={{96,-20},
          {96,-42},{68.6667,-42}},          color={0,127,255}));
  connect(pumCHW1.port_b, TCHWEntEva.port_a) annotation (Line(points={{-54,142},
          {-30,142},{-30,102},{-4,102}}, color={0,127,255}));
  connect(pumCHW2.port_b, TCHWEntEva.port_a)
    annotation (Line(points={{-50,102},{-4,102}}, color={0,127,255}));
  connect(pumCW1.port_b, TCWEntCon.port_a) annotation (Line(points={{352,116},{326,
          116},{326,74},{292,74}}, color={0,127,255}));
  connect(pumCW2.port_b, TCWEntCon.port_a)
    annotation (Line(points={{352,74},{292,74}}, color={0,127,255}));
  connect(pumCWCtr.y, pumCW1.y) annotation (Line(points={{-379,281},{362.5,281},
          {362.5,128},{362,128}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(pumCWCtr.y, pumCW2.y) annotation (Line(points={{-379,281},{371.5,281},
          {371.5,86},{362,86}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(equRot.uLeaSta, con.y)
    annotation (Line(points={{-442,208},{-485,208}}, color={255,0,255}));
  connect(con.y, equRot.uLagSta) annotation (Line(points={{-485,208},{-463.5,
          208},{-463.5,196},{-442,196}}, color={255,0,255}));
  connect(equRot.yDevSta[1], chi1.on) annotation (Line(
      points={{-419,208},{256,208},{256,142},{148,142}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(equRot.yDevSta[2], chi2.on) annotation (Line(
      points={{-419,208},{255.5,208},{255.5,72},{156,72}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(chi1On.y, booToInt.u)
    annotation (Line(points={{-633,256},{-620,256}}, color={255,0,255}));
  connect(chi2On.y, booToInt1.u)
    annotation (Line(points={{-633,232},{-620,232}}, color={255,0,255}));
  connect(booToInt.y, mulSumInt.u[1]) annotation (Line(points={{-597,256},{-582,
          256},{-582,247.5},{-564,247.5}}, color={255,127,0}));
  connect(booToInt1.y, mulSumInt.u[2]) annotation (Line(points={{-597,232},{
          -582,232},{-582,240.5},{-564,240.5}}, color={255,127,0}));
  connect(mulSumInt.y, staCap.uSta)
    annotation (Line(points={{-540.3,244},{-522,244}}, color={255,127,0}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-700,-120},{440,460}}), graphics={
        Text(
          extent={{-700,460},{-586,444}},
          lineColor={28,108,200},
          textString="Setpoints"),
        Text(
          extent={{-700,26},{-586,10}},
          lineColor={28,108,200},
          textString="Loads"),
        Text(
          extent={{-566,460},{-452,444}},
          lineColor={28,108,200},
          textString="Controls")}),
    __Dymola_Commands(file="Resources/Scripts/Dymola/Controls/OBC/ASHRAE/PrimarySystem/ChillerPlant/Examples/ClosedLoopTestCase.mos"
        "Simulate and plot"));
end ClosedLoopTestCase;
