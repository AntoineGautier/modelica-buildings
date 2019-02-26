within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Examples;
model ClosedLoopTestCaseTmp
  "Simple closed loop model for testing primary control sequences"
  extends Modelica.Icons.Example;

  replaceable package MediumA = Buildings.Media.Air "Medium model";
  replaceable package MediumW = Buildings.Media.Water "Medium model";

  parameter Modelica.SIunits.TemperatureDifference dTEva_nominal=5
    "Temperature difference evaporator inlet-outlet";
  parameter Modelica.SIunits.TemperatureDifference dTCon_nominal=5
    "Temperature difference condenser outlet-inlet";
  parameter Modelica.SIunits.HeatFlowRate q_floEva_nominal = 742E3 "Chiller nominal capacity";
  parameter Real EER_nominal = 5.42 "Chiller EER nominal value";
  parameter Modelica.SIunits.SpecificHeatCapacity cpLiq = 4186 "Specific heat capacity of water";
  parameter Modelica.SIunits.MassFlowRate m_floCHW_nominal=q_floEva_nominal / cpLiq / dTEva_nominal
   "Nominal mass flow rate at chilled water";
  parameter Modelica.SIunits.MassFlowRate m_floCW_nominal=m_floCHW_nominal* (1 + 1 / EER_nominal)
   "Nominal mass flow rate at condenser water";
  parameter Modelica.SIunits.PressureDifference dp_nominal=500
    "Nominal pressure difference";
  parameter Modelica.SIunits.PressureDifference dpCHW_nominal=125412
    "CHW loop nominal pressure difference";
  parameter Modelica.SIunits.PressureDifference dpCW_nominal=214992
    "CW loop nominal pressure difference";

  Fluid.Movers.FlowControlled_m_flow
                                 pumCW2(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_floCW_nominal*{0.5,1.0,1.5}, dp=dpCW_nominal*{1.2,1.0,
            0.2})),
    m_flow_nominal=m_floCW_nominal,
    dp_nominal=dpCW_nominal)
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={312,110})));
  Fluid.HeatExchangers.CoolingTowers.YorkCalc cooTow1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCW_nominal,
    PFan_nominal=6000,
    TAirInWB_nominal(displayUnit="degC") = 283.15,
    TApp_nominal=6,
    dp_nominal=14930 + 14930 + 74650,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    "Cooling tower" annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          origin={229,271})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCW_nominal,
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
    m1_flow_nominal=m_floCW_nominal,
    m2_flow_nominal=m_floCHW_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{146,129},{126,149}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW1(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCHW_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=14930 + 89580,
    y_start=1,
    use_inputFilter=false,
    from_dp=true) "Control valve for chilled water leaving from chiller"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={186,130})));
  Fluid.Sensors.TemperatureTwoPort sen_TCHWRet(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCHW_nominal)
    "Temperature of chilled water return" annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=270,
        origin={-86,-8})));
  Fluid.Sensors.TemperatureTwoPort sen_TCWLvgTow(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCW_nominal)
    "Temperature of condenser water leaving the cooling tower" annotation (
      Placement(transformation(
        extent={{10,10},{-10,-10}},
        origin={328,235},
        rotation=180)));
  BoundaryConditions.WeatherData.ReaderTMY3           weaData(filNam=
        Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos"))
    annotation (Placement(transformation(extent={{-224,420},{-204,440}})));
  BoundaryConditions.WeatherData.Bus weaBus
    annotation (Placement(transformation(extent={{-166,418},{-146,438}})));
  Fluid.Chillers.ElectricEIR           chi2(
    redeclare package Medium1 = MediumW,
    redeclare package Medium2 = MediumW,
    m1_flow_nominal=m_floCW_nominal,
    m2_flow_nominal=m_floCHW_nominal,
    dp2_nominal=0,
    dp1_nominal=0,
    per=Buildings.Fluid.Chillers.Data.ElectricEIR.ElectricEIRChiller_Carrier_19XR_742kW_5_42COP_VSD(),
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
    annotation (Placement(transformation(extent={{154,59},{134,79}})));
  Fluid.MixingVolumes.MixingVolume volCHWLoa(nPorts=3,
    redeclare package Medium = MediumW,
    m_flow_nominal=2*m_floCHW_nominal,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial,
    V=15) "Volume of chilled water receiving cooling load"
    annotation (Placement(transformation(extent={{56,-42},{76,-22}})));
  Fluid.Actuators.Valves.TwoWayLinear valIsoCHW2(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCHW_nominal,
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
    m_flow_nominal=m_floCW_nominal,
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
    m_flow_nominal=m_floCW_nominal,
    dpValve_nominal=20902,
    dpFixed_nominal=89580,
    y_start=1,
    use_inputFilter=false) "Control valve for condenser water loop of chiller"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={104,74})));
  Modelica.Blocks.Sources.Constant con_valIsoCW(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-272,317})));
  Modelica.Blocks.Sources.Constant con_valIsoCHW(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-272,163})));
  Modelica.Blocks.Sources.Trapezoid load(
    rising=6*3600,
    width=3600,
    falling=5*3600,
    period=24*3600,
    startTime=7*3600,
    amplitude=2*q_floEva_nominal,
    offset=0)
    annotation (Placement(transformation(extent={{-656,-42},{-636,-22}})));
  HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
    annotation (Placement(transformation(extent={{20,-42},{40,-22}})));
  Fluid.Sensors.TemperatureTwoPort sen_TCHWEntEva(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCHW_nominal)
    "Temperature of chilled water entering evaporator" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={0,64})));
  Fluid.Sensors.TemperatureTwoPort sen_TCWLvgCon(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCW_nominal)
    "Temperature of chilled water leaving condenser" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={40,144})));
  Fluid.Sensors.TemperatureTwoPort sen_TCWEntCon(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCW_nominal)
    "Temperature of chilled water entering condenser" annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={252,144})));
  CDL.Continuous.Sources.Constant set_TCHWSup(k=7)
    "Setpoint for chilled water supply temperature (C)"
    annotation (Placement(transformation(extent={{-654,410},{-634,430}})));
  Staging.Subsequences.CapacityRequirement capReq(water_spec_heat=cpLiq)
    annotation (Placement(transformation(extent={{-564,208},{-544,228}})));
  Fluid.Sensors.VolumeFlowRate sen_V_floCHW(redeclare package Medium = MediumW,
      m_flow_nominal=2*m_floCHW_nominal) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-86,22})));
  Modelica.Blocks.Sources.RealExpression chi1PLR(y=chi1.PLR1)
    annotation (Placement(transformation(extent={{-564,106},{-544,126}})));
  UnitConversions.From_degC from_degC
    annotation (Placement(transformation(extent={{-616,410},{-596,430}})));
  Modelica.Blocks.Sources.RealExpression chi2PLR1(y=chi2.PLR1)
    annotation (Placement(transformation(extent={{-564,88},{-544,108}})));
  Fluid.Movers.FlowControlled_m_flow pumCW1(
    use_inputFilter=false,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    per(pressure(V_flow=m_floCW_nominal*{0.5,1.0,1.5}, dp=dpCW_nominal*{1.2,1.0,
            0.2})),
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCW_nominal,
    dp_nominal=dpCW_nominal)
    "Condenser water pump" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={312,144})));
  Modelica.Blocks.Sources.BooleanExpression pumCW1On(y=pumCW1.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-400,424},{-380,444}})));
  Modelica.Blocks.Sources.BooleanExpression pumCW2On(y=pumCW2.y_actual > 1e-4)
    annotation (Placement(transformation(extent={{-400,400},{-380,420}})));
  Modelica.Blocks.Sources.RealExpression cooTow1FanSpe(y=cooTow1.y)
    annotation (Placement(transformation(extent={{-400,378},{-380,398}})));
  Tower.Fan con_cooTowFan(
    minFanSpe=0.1,
    dTAboSet=0.55,
    TiFan=1000,
    controllerTypeFan=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    kFan=0.3)
    annotation (Placement(transformation(extent={{-282,340},{-262,360}})));
  CDL.Continuous.Sources.Constant set_dTLifChi(k=13)
    "Setpoint for chiller lift (K)"
    annotation (Placement(transformation(extent={{-654,338},{-634,358}})));
  Fluid.Movers.SpeedControlled_y pumCHW2(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    per(pressure(V_flow=m_floCHW_nominal*{0.5,1.0,1.5}, dp=dpCHW_nominal*{1.2,1.0,
            0.2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Evaporator water pump"
                         annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-62,64})));
  Fluid.Movers.SpeedControlled_y           pumCHW1(
    redeclare package Medium = MediumW,
    use_inputFilter=false,
    per(pressure(V_flow=m_floCHW_nominal*{0.5,1.0,1.5}, dp=dpCHW_nominal*{1.2,1.0,
            0.2})),
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    "Evaporator water pump"
                         annotation (Placement(transformation(
        extent={{10,10},{-10,-10}},
        rotation=180,
        origin={-66,104})));
  Modelica.Blocks.Sources.Constant con_pumCHW(k=1)
    "Control singal for cooling tower fan" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}}, origin={-272,129})));
  Fluid.Sources.Boundary_pT expCW(redeclare package Medium = MediumW, nPorts=1)
    "Expansion device on condenser water loop"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={372,110})));
  Fluid.Sources.Boundary_pT expCHW(redeclare package Medium = MediumW, nPorts=1)
    "Expansion device on chilled water loop"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={96,-10})));
  Generic.EquipmentRotationTwo equRot
    annotation (Placement(transformation(extent={{-440,192},{-420,212}})));
  Modelica.Blocks.Sources.BooleanExpression chi1On(y=chi1.on) "Chiller status"
    annotation (Placement(transformation(extent={{-566,272},{-546,292}})));
  Modelica.Blocks.Sources.BooleanExpression chi2On(y=chi2.on) "Chiller status"
    annotation (Placement(transformation(extent={{-566,248},{-546,268}})));
  CDL.Logical.Sources.Constant con(k=true)
    annotation (Placement(transformation(extent={{-494,198},{-474,218}})));
  CDL.Conversions.BooleanToInteger booToInt
    annotation (Placement(transformation(extent={{-530,272},{-510,292}})));
  CDL.Conversions.BooleanToInteger booToInt1
    annotation (Placement(transformation(extent={{-530,248},{-510,268}})));
  CDL.Logical.Sources.Constant chi1Ava(k=true) "Chiller availability "
    annotation (Placement(transformation(extent={{-566,166},{-546,186}})));
  CDL.Logical.Sources.Constant chi2Ava(k=true) "Chiller availability "
    annotation (Placement(transformation(extent={{-566,134},{-546,154}})));
  CDL.Integers.MultiSum mulSumInt(nin=2)
    annotation (Placement(transformation(extent={{-472,260},{-452,280}})));
  Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valTowByp(
    redeclare package Medium = MediumW,
    m_flow_nominal=m_floCW_nominal,
    dpValve_nominal=10000,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial,
    from_dp=false,
    use_inputFilter=false) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={344,194})));
  CDL.Continuous.LimPID con_valTowByp(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    Ti=300,
    yMax=1,
    yMin=0,
    k=1,
    reverseAction=true)
    annotation (Placement(transformation(extent={{-282,268},{-262,288}})));
  CDL.Continuous.Sources.Constant set_TMinCWEntCon(k=20)
    "Setpoint for minimum entering condenser water temperature (C)"
    annotation (Placement(transformation(extent={{-654,302},{-634,322}})));
  Fluid.Sensors.TemperatureTwoPort sen_TCWEntTow(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCW_nominal)
    "Temperature of condenser water entering the cooling tower" annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        origin={80,235},
        rotation=180)));
  UnitConversions.From_degC from_degC1
    annotation (Placement(transformation(extent={{-618,302},{-598,322}})));
  CDL.Continuous.Sources.Constant set_m_floPumCW(k=m_floCW_nominal)
    "Setpoint for condenser pump flow rate (kg/s)"
    annotation (Placement(transformation(extent={{-654,376},{-634,396}})));
  Fluid.Sensors.TemperatureTwoPort sen_TCHWSup(redeclare package Medium =
        MediumW, m_flow_nominal=2*m_floCHW_nominal)
    "Temperature of chilled water supply" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={232,62})));
  Staging.Subsequences.PartLoadRatios PLRs
    annotation (Placement(transformation(extent={{-374,238},{-354,258}})));
  Staging.Subsequences.Capacities staCap(nSta=2, staNomCap=q_floEva_nominal*{1,
        2})
    annotation (Placement(transformation(extent={{-442,236},{-422,256}})));
  Staging.Subsequences.Change staChaPosDis(nPosDis=2, staNomCap=
        q_floEva_nominal*{1,2})
    annotation (Placement(transformation(extent={{-372,102},{-352,122}})));
  Modelica.Blocks.Sources.RealExpression dumCHWdP(y=dpCHW_nominal)
    "Dummy value (CHW pumps not controlled yet)"
    annotation (Placement(transformation(extent={{-564,68},{-544,88}})));
  Modelica.Blocks.Sources.RealExpression dumCooTowFanMax(y=1) "Dummy value"
    annotation (Placement(transformation(extent={{-564,50},{-544,70}})));
  Modelica.Blocks.Sources.BooleanExpression WSEOn(y=false)
    "Water side economizer status"
    annotation (Placement(transformation(extent={{-564,30},{-544,50}})));
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
  connect(sen_TCHWSup.port_b, volCHWLoa.ports[1]) annotation (Line(points={{242,62},
          {242,-42},{63.3333,-42}},     color={0,127,255}));
  connect(con_valIsoCW.y, valIsoCW2.y) annotation (Line(
      points={{-261,317},{104.5,317},{104.5,86},{104,86}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(volCHWLoa.heatPort, prescribedHeatFlow.port)
    annotation (Line(points={{56,-32},{40,-32}}, color={191,0,0}));
  connect(con_valIsoCHW.y, valIsoCHW1.y) annotation (Line(
      points={{-261,163},{184.5,163},{184.5,142},{186,142}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(con_valIsoCHW.y, valIsoCHW2.y) annotation (Line(
      points={{-261,163},{194.5,163},{194.5,74},{196,74}},
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
  connect(volCHWLoa.ports[2], sen_TCHWRet.port_a) annotation (Line(points={{66,-42},
          {-86,-42},{-86,-18}}, color={0,127,255}));
  connect(sen_TCHWEntEva.port_b, chi2.port_a2)
    annotation (Line(points={{10,64},{134,64},{134,63}}, color={0,127,255}));
  connect(valIsoCW1.port_b, sen_TCWLvgCon.port_a)
    annotation (Line(points={{78,144},{50,144}}, color={0,127,255}));
  connect(sen_TCWEntCon.port_b, chi2.port_a1)
    annotation (Line(points={{242,144},{242,75},{154,75}}, color={0,127,255}));
  connect(sen_TCWEntCon.port_b, chi1.port_a1) annotation (Line(points={{242,144},
          {146,144},{146,145}}, color={0,127,255}));
  connect(cooTow2.port_b, sen_TCWLvgTow.port_a)
    annotation (Line(points={{239,235},{318,235}}, color={0,127,255}));
  connect(cooTow1.port_b, sen_TCWLvgTow.port_a) annotation (Line(points={{239,271},
          {290,271},{290,235},{318,235}}, color={0,127,255}));
  connect(sen_TCHWEntEva.port_b, chi1.port_a2) annotation (Line(points={{10,64},
          {30,64},{30,133},{126,133}}, color={0,127,255}));
  connect(con_valIsoCW.y, valIsoCW1.y) annotation (Line(
      points={{-261,317},{88,317},{88,156}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCHW2.port_b, sen_TCHWSup.port_a)
    annotation (Line(points={{206,62},{222,62}}, color={0,127,255}));
  connect(valIsoCHW1.port_b, sen_TCHWSup.port_a) annotation (Line(points={{196,130},
          {222,130},{222,62}}, color={0,127,255}));
  connect(sen_TCHWRet.T, capReq.TChiWatRet) annotation (Line(
      points={{-97,-8},{-586,-8},{-586,218},{-565,218}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(sen_TCHWRet.port_b, sen_V_floCHW.port_a)
    annotation (Line(points={{-86,2},{-86,12}}, color={0,127,255}));
  connect(sen_V_floCHW.V_flow, capReq.VChiWat_flow) annotation (Line(
      points={{-97,22},{-580,22},{-580,213},{-565,213}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(set_TCHWSup.y, from_degC.u)
    annotation (Line(points={{-633,420},{-618,420}}, color={0,0,127}));
  connect(from_degC.y, capReq.TChiWatSupSet) annotation (Line(
      points={{-595,420},{-586,420},{-586,223},{-565,223}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(from_degC.y, chi1.TSet) annotation (Line(
      points={{-595,420},{172,420},{172,136},{148,136}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(from_degC.y, chi2.TSet) annotation (Line(
      points={{-595,420},{171.5,420},{171.5,66},{156,66}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(load.y, prescribedHeatFlow.Q_flow)
    annotation (Line(points={{-635,-32},{20,-32}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valIsoCW2.port_b, sen_TCWLvgCon.port_a)
    annotation (Line(points={{94,74},{50,74},{50,144}}, color={0,127,255}));
  connect(pumCW1On.y, con_cooTowFan.uConWatPum[1]) annotation (Line(
      points={{-379,434},{-344,434},{-344,358},{-284,358}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(pumCW2On.y, con_cooTowFan.uConWatPum[2]) annotation (Line(
      points={{-379,410},{-344.5,410},{-344.5,358},{-284,358}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(cooTow1FanSpe.y, con_cooTowFan.uFanSpe) annotation (Line(
      points={{-379,388},{-356,388},{-356,342},{-284,342}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(set_dTLifChi.y, con_cooTowFan.dTRef) annotation (Line(
      points={{-633,348},{-460,348},{-460,354},{-284,354}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(sen_TCHWSup.T, con_cooTowFan.TChiWatSup) annotation (Line(
      points={{232,51},{232,40},{-314,40},{-314,350},{-284,350}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(con_cooTowFan.yFanSpe, cooTow1.y) annotation (Line(
      points={{-261,345},{186.5,345},{186.5,279},{217,279}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(con_cooTowFan.yFanSpe, cooTow2.y) annotation (Line(
      points={{-261,345},{186.5,345},{186.5,243},{217,243}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(sen_V_floCHW.port_b, pumCHW2.port_a)
    annotation (Line(points={{-86,32},{-86,64},{-72,64}}, color={0,127,255}));
  connect(sen_V_floCHW.port_b, pumCHW1.port_a) annotation (Line(points={{-86,32},
          {-86,104},{-76,104}}, color={0,127,255}));
  connect(con_pumCHW.y, pumCHW1.y) annotation (Line(
      points={{-261,129},{-64.5,129},{-64.5,116},{-66,116}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(con_pumCHW.y, pumCHW2.y) annotation (Line(
      points={{-261,129},{-59.5,129},{-59.5,76},{-62,76}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(expCHW.ports[1],volCHWLoa. ports[3]) annotation (Line(points={{96,-20},
          {96,-42},{68.6667,-42}},          color={0,127,255}));
  connect(pumCHW1.port_b, sen_TCHWEntEva.port_a) annotation (Line(points={{-56,104},
          {-30,104},{-30,64},{-10,64}}, color={0,127,255}));
  connect(pumCHW2.port_b, sen_TCHWEntEva.port_a)
    annotation (Line(points={{-52,64},{-10,64}}, color={0,127,255}));
  connect(equRot.uLeaSta, con.y)
    annotation (Line(points={{-442,208},{-473,208}}, color={255,0,255}));
  connect(con.y, equRot.uLagSta) annotation (Line(points={{-473,208},{-463.5,
          208},{-463.5,196},{-442,196}}, color={255,0,255}));
  connect(equRot.yDevSta[1], chi1.on) annotation (Line(
      points={{-419,208},{206,208},{206,142},{148,142}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(equRot.yDevSta[2], chi2.on) annotation (Line(
      points={{-419,208},{205.5,208},{205.5,72},{156,72}},
      color={255,0,255},
      pattern=LinePattern.Dash));
  connect(chi1On.y, booToInt.u)
    annotation (Line(points={{-545,282},{-532,282}}, color={255,0,255}));
  connect(chi2On.y, booToInt1.u)
    annotation (Line(points={{-545,258},{-532,258}}, color={255,0,255}));
  connect(booToInt.y, mulSumInt.u[1]) annotation (Line(points={{-509,282},{-494,
          282},{-494,273.5},{-474,273.5}}, color={255,127,0}));
  connect(booToInt1.y, mulSumInt.u[2]) annotation (Line(points={{-509,258},{
          -494,258},{-494,266.5},{-474,266.5}}, color={255,127,0}));
  connect(sen_TCWLvgTow.port_b, valTowByp.port_1) annotation (Line(points={{338,
          235},{344,235},{344,204}}, color={0,127,255}));
  connect(con_valTowByp.y, valTowByp.y) annotation (Line(
      points={{-261,278},{368,278},{368,194},{356,194}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(sen_TCWEntTow.port_b, cooTow1.port_a) annotation (Line(points={{90,235},
          {156,235},{156,271},{219,271}}, color={0,127,255}));
  connect(sen_TCWEntTow.port_b, cooTow2.port_a)
    annotation (Line(points={{90,235},{219,235}}, color={0,127,255}));
  connect(sen_TCWLvgCon.port_b, sen_TCWEntTow.port_a)
    annotation (Line(points={{30,144},{30,235},{70,235}}, color={0,127,255}));
  connect(valTowByp.port_2, pumCW1.port_a) annotation (Line(points={{344,184},{
          344,144},{322,144}},
                           color={0,127,255}));
  connect(valTowByp.port_2, pumCW2.port_a) annotation (Line(points={{344,184},{344,
          110},{322,110}}, color={0,127,255}));
  connect(expCW.ports[1], pumCW2.port_a)
    annotation (Line(points={{362,110},{322,110}}, color={0,127,255}));
  connect(sen_TCWLvgTow.T, con_cooTowFan.TConWatRet) annotation (Line(
      points={{328,246},{328,304},{-304,304},{-304,346},{-284,346}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(set_TMinCWEntCon.y, from_degC1.u)
    annotation (Line(points={{-633,312},{-620,312}}, color={0,0,127}));
  connect(from_degC1.y, con_valTowByp.u_s)
    annotation (Line(points={{-597,312},{-426,312},{-426,278},{-284,278}},
                                                     color={0,0,127}));
  connect(pumCW1.port_b, sen_TCWEntCon.port_a)
    annotation (Line(points={{302,144},{262,144}}, color={0,127,255}));
  connect(set_m_floPumCW.y, pumCW1.m_flow_in) annotation (Line(
      points={{-633,386},{312,386},{312,156}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(set_m_floPumCW.y, pumCW2.m_flow_in) annotation (Line(
      points={{-633,386},{311.5,386},{311.5,122},{312,122}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(valTowByp.port_3, sen_TCWEntTow.port_a) annotation (Line(points={{334,
          194},{30,194},{30,235},{70,235}}, color={0,127,255}));
  connect(pumCW2.port_b, sen_TCWEntCon.port_a) annotation (Line(points={{302,110},
          {282,110},{282,144},{262,144}}, color={0,127,255}));
  connect(sen_TCWEntCon.T, con_valTowByp.u_m) annotation (Line(
      points={{252,155},{252,188},{-272,188},{-272,266}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(mulSumInt.y, staCap.uSta) annotation (Line(points={{-450.3,270},{-448,
          270},{-448,246},{-444,246}}, color={255,127,0}));
  connect(chi1Ava.y, staCap.uStaAva[1]) annotation (Line(points={{-545,176},{
          -456,176},{-456,239},{-444,239}}, color={255,0,255}));
  connect(chi2Ava.y, staCap.uStaAva[2]) annotation (Line(points={{-545,144},{
          -491.5,144},{-491.5,241},{-444,241}}, color={255,0,255}));
  connect(capReq.y, PLRs.uCapReq) annotation (Line(points={{-543,218},{-410,218},
          {-410,255},{-375,255}}, color={0,0,127}));
  connect(staCap.yStaNom, PLRs.uStaCapNom)
    annotation (Line(points={{-421,253},{-375,253}}, color={0,0,127}));
  connect(staCap.yStaUpNom, PLRs.uStaUpCapNom) annotation (Line(points={{-421,
          249},{-401.5,249},{-401.5,251},{-375,251}}, color={0,0,127}));
  connect(staCap.yStaMin, PLRs.uStaCapMin) annotation (Line(points={{-421,238},
          {-388,238},{-388,245},{-375,245}}, color={0,0,127}));
  connect(mulSumInt.y, PLRs.uSta) annotation (Line(points={{-450.3,270},{-410,
          270},{-410,257},{-375,257}}, color={255,127,0}));
  connect(staCap.yStaDowNom, PLRs.uStaDowCapNom) annotation (Line(points={{-421,
          245},{-398.5,245},{-398.5,249},{-375,249}}, color={0,0,127}));
  connect(staCap.yStaUpMin, PLRs.uStaUpCapMin) annotation (Line(points={{-421,
          240},{-390,240},{-390,247},{-375,247}}, color={0,0,127}));
  connect(mulSumInt.y, staChaPosDis.uSta) annotation (Line(points={{-450.3,270},
          {-442,270},{-442,123},{-373,123}}, color={255,127,0}));
  connect(chi1Ava.y, staChaPosDis.uStaAva[1]) annotation (Line(points={{-545,
          176},{-518,176},{-518,106},{-374,106}}, color={255,0,255}));
  connect(chi2Ava.y, staChaPosDis.uStaAva[2]) annotation (Line(points={{-545,
          144},{-528,144},{-528,106},{-374,106}}, color={255,0,255}));
  connect(sen_TCHWRet.T, staChaPosDis.TChiWatRet) annotation (Line(points={{-97,
          -8},{-532,-8},{-532,119},{-373,119}}, color={0,0,127}));
  connect(sen_TCHWSup.T, staChaPosDis.TChiWatSup) annotation (Line(points={{232,
          51},{-528,51},{-528,114},{-373,114}}, color={0,0,127}));
  connect(sen_V_floCHW.V_flow, staChaPosDis.VChiWat_flow) annotation (Line(
        points={{-97,22},{-530,22},{-530,117},{-373,117}}, color={0,0,127}));
  connect(dumCHWdP.y, staChaPosDis.dpChiWatPum) annotation (Line(points={{-543,
          78},{-516,78},{-516,109},{-373,109}}, color={0,0,127}));
  connect(dumCHWdP.y, staChaPosDis.dpChiWatPumSet) annotation (Line(points={{
          -543,78},{-514,78},{-514,111},{-373,111}}, color={0,0,127}));
  connect(dumCooTowFanMax.y, staChaPosDis.uTowFanSpeMax) annotation (Line(
        points={{-543,60},{-512,60},{-512,104},{-373,104}}, color={0,0,127}));
  connect(WSEOn.y, staChaPosDis.uWseSta) annotation (Line(points={{-543,40},{
          -510,40},{-510,102},{-373,102}}, color={255,0,255}));
  connect(from_degC.y, staChaPosDis.TChiWatSupSet) annotation (Line(points={{
          -595,420},{-586,420},{-586,121},{-373,121}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-700,-120},{400,460}}), graphics={
        Text(
          extent={{-700,460},{-586,444}},
          lineColor={28,108,200},
          textString="Setpoints"),
        Text(
          extent={{-700,10},{-586,-6}},
          lineColor={28,108,200},
          textString="Loads"),
        Text(
          extent={{-566,460},{-452,444}},
          lineColor={28,108,200},
          textString="Controls")}),
    __Dymola_Commands(file="Resources/Scripts/Dymola/Controls/OBC/ASHRAE/PrimarySystem/ChillerPlant/Examples/ClosedLoopTestCase.mos"
        "Simulate and plot"));
end ClosedLoopTestCaseTmp;
