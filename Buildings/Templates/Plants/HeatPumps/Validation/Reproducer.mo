within Buildings.Templates.Plants.HeatPumps.Validation;
model Reproducer
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";

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
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHw(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaHw.dpTer_nominal + loaHw.dpValve_nominal +
      valHw.dpFixed_nominal + valHw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,-70},{30,-50}})));
  Fluid.FixedResistances.CheckValve cheValHw(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,-70},{60,-50}})));
  Fluid.Actuators.Valves.TwoWayLinear valHw(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,-70},{-90,-50}})));
  Fluid.Actuators.Valves.TwoWayLinear valChw(
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,-30},{-90,-10}})));
  Fluid.FixedResistances.PressureDrop hp0dp(
    m_flow_nominal=pumHw.m_flow_nominal,
    dp_nominal=0,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-60,-70},{-40,-50}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumChw(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaChw.dpTer_nominal + loaChw.dpValve_nominal +
      valChw.dpFixed_nominal + valChw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,-30},{30,-10}})));
  Fluid.FixedResistances.CheckValve cheValChw(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,-30},{60,-10}})));
  Buildings.Templates.Components.Loads.LoadTwoWayValve loaHw(
    redeclare package MediumLiq=Medium,
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=sum({pumHw.m_flow_nominal, pumHw1.m_flow_nominal}))
    annotation(Placement(transformation(extent={{140,-70},{160,-50}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHw1(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaHw.dpTer_nominal + loaHw.dpValve_nominal +
      valHw.dpFixed_nominal + valHw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,10},{30,30}})));
  Fluid.FixedResistances.CheckValve cheValHw1(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,10},{60,30}})));
  Fluid.Actuators.Valves.TwoWayLinear valHw1(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,10},{-90,30}})));
  Fluid.Actuators.Valves.TwoWayLinear valChw1(
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,50},{-90,70}})));
  Fluid.FixedResistances.PressureDrop hp0dp1(
    m_flow_nominal=pumHw.m_flow_nominal,
    dp_nominal=0,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-60,10},{-40,30}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumChw1(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaChw.dpTer_nominal + loaChw.dpValve_nominal +
      valChw.dpFixed_nominal + valChw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,50},{30,70}})));
  Fluid.FixedResistances.CheckValve cheValChw1(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,50},{60,70}})));
  Fluid.Actuators.Valves.TwoWayLinear valHwBypMin(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValBypMin,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-10,10},{10,-10}},
      rotation=-90,
      origin={100,-100})));
  Buildings.Templates.Components.Loads.LoadTwoWayValve loaChw(
    redeclare package MediumLiq=Medium,
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Cooling,
    mLiq_flow_nominal=sum({pumChw.m_flow_nominal, pumChw1.m_flow_nominal}))
    annotation(Placement(transformation(extent={{140,-30},{160,-10}})));
  Fluid.Actuators.Valves.TwoWayLinear valHwBypMin1(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValBypMin,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{10,10},{-10,-10}},
      rotation=-90,
      origin={100,30})));
  Fluid.Sources.Boundary_pT bou(
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal,
    redeclare package Medium=Medium,
    nPorts=1)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=90,
      origin={-60,-100})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Pulse one(period=1200)
    annotation(Placement(transformation(extent={{-192,130},{-172,150}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(k=0)
    annotation(Placement(transformation(extent={{-192,90},{-172,110}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant p5(k=0.5)
    annotation(Placement(transformation(extent={{-160,110},{-140,130}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant one1(k=true)
    annotation(Placement(transformation(extent={{-160,148},{-140,168}})));
  Buildings.Templates.Components.Routing.Compliance com(
    redeclare package Medium=Medium,
    p_start=bou.p)
    annotation(Placement(transformation(extent={{80,-50},{100,-30}})));
  Buildings.Templates.Components.Routing.Compliance com1(
    redeclare package Medium=Medium,
    p_start=bou.p)
    annotation(Placement(transformation(extent={{80,-10},{100,10}})));
equation
  connect(pumHw.port_b, cheValHw.port_a)
    annotation(Line(points={{30,-60},{40,-60}},
      color={0,127,255}));
  connect(hp0dp.port_b, pumHw.port_a)
    annotation(Line(points={{-40,-60},{10,-60}},
      color={0,127,255}));
  connect(valHw.port_b, hp0dp.port_a)
    annotation(Line(points={{-90,-60},{-60,-60}},
      color={0,127,255}));
  connect(valChw.port_b, hp0dp.port_a)
    annotation(Line(points={{-90,-20},{-80,-20},{-80,-60},{-60,-60}},
      color={0,127,255}));
  connect(pumChw.port_b, cheValChw.port_a)
    annotation(Line(points={{30,-20},{40,-20}},
      color={0,127,255}));
  connect(hp0dp.port_b, pumChw.port_a)
    annotation(Line(points={{-40,-60},{0,-60},{0,-20},{10,-20}},
      color={0,127,255}));
  connect(pumHw1.port_b, cheValHw1.port_a)
    annotation(Line(points={{30,20},{40,20}},
      color={0,127,255}));
  connect(hp0dp1.port_b, pumHw1.port_a)
    annotation(Line(points={{-40,20},{10,20}},
      color={0,127,255}));
  connect(valHw1.port_b, hp0dp1.port_a)
    annotation(Line(points={{-90,20},{-60,20}},
      color={0,127,255}));
  connect(valChw1.port_b, hp0dp1.port_a)
    annotation(Line(points={{-90,60},{-80,60},{-80,20},{-60,20}},
      color={0,127,255}));
  connect(pumChw1.port_b, cheValChw1.port_a)
    annotation(Line(points={{30,60},{40,60}},
      color={0,127,255}));
  connect(hp0dp1.port_b, pumChw1.port_a)
    annotation(Line(points={{-40,20},{0,20},{0,60},{10,60}},
      color={0,127,255}));
  connect(cheValHw.port_b, valHwBypMin.port_a)
    annotation(Line(points={{60,-60},{100,-60},{100,-90}},
      color={0,127,255}));
  connect(cheValHw.port_b, loaHw.port_a)
    annotation(Line(points={{60,-60},{140,-60}},
      color={0,127,255}));
  connect(cheValHw1.port_b, cheValHw.port_b)
    annotation(Line(points={{60,20},{80,20},{80,-60},{60,-60}},
      color={0,127,255}));
  connect(cheValChw.port_b, loaChw.port_a)
    annotation(Line(points={{60,-20},{140,-20}},
      color={0,127,255}));
  connect(cheValChw1.port_b, cheValChw.port_b)
    annotation(Line(points={{60,60},{68,60},{68,-20},{60,-20}},
      color={0,127,255}));
  connect(loaChw.port_b, valChw.port_a)
    annotation(Line(
      points={{160,-20},{180,-20},{180,80},{-140,80},{-140,-20},{-110,-20}},
      color={0,127,255}));
  connect(valChw.port_a, valChw1.port_a)
    annotation(Line(points={{-110,-20},{-140,-20},{-140,60},{-110,60}},
      color={0,127,255}));
  connect(loaHw.port_b, valHw.port_a)
    annotation(Line(
      points={{160,-60},{180,-60},{180,-140},{-150,-140},{-150,-60},{-110,-60}},
      color={0,127,255}));
  connect(valHw.port_a, valHw1.port_a)
    annotation(Line(points={{-110,-60},{-150,-60},{-150,20},{-110,20}},
      color={0,127,255}));
  connect(valHwBypMin.port_b, valHw.port_a)
    annotation(Line(
      points={{100,-110},{100,-140},{-150,-140},{-150,-60},{-110,-60}},
      color={0,127,255}));
  connect(cheValChw.port_b, valHwBypMin1.port_a)
    annotation(Line(points={{60,-20},{100,-20},{100,20}},
      color={0,127,255}));
  connect(valHwBypMin1.port_b, valChw.port_a)
    annotation(Line(points={{100,40},{100,80},{-140,80},{-140,-20},{-110,-20}},
      color={0,127,255}));
  connect(one.y, pumChw1.m_flow_in)
    annotation(Line(points={{-170,140},{-12,140},{-12,76},{20,76},{20,72}},
      color={0,0,127}));
  connect(one.y, valChw1.y)
    annotation(Line(
      points={{-170,140},{-124,140},{-124,76},{-100,76},{-100,72}},
      color={0,0,127}));
  connect(zer.y, valHwBypMin1.y)
    annotation(Line(
      points={{-170,100},{-20,100},{-20,40},{80,40},{80,30},{88,30}},
      color={0,0,127}));
  connect(zer.y, valHwBypMin.y)
    annotation(Line(points={{-170,100},{-20,100},{-20,-100},{88,-100}},
      color={0,0,127}));
  connect(zer.y, valHw1.y)
    annotation(Line(
      points={{-170,100},{-118,100},{-118,40},{-100,40},{-100,32}},
      color={0,0,127}));
  connect(zer.y, valChw.y)
    annotation(Line(points={{-170,100},{-118,100},{-118,0},{-100,0},{-100,-8}},
      color={0,0,127}));
  connect(one.y, valHw.y)
    annotation(Line(
      points={{-170,140},{-124,140},{-124,-40},{-100,-40},{-100,-48}},
      color={0,0,127}));
  connect(one.y, pumHw.m_flow_in)
    annotation(Line(points={{-170,140},{-12,140},{-12,-40},{20,-40},{20,-48}},
      color={0,0,127}));
  connect(zer.y, pumHw1.m_flow_in)
    annotation(Line(points={{-170,100},{-20,100},{-20,40},{20,40},{20,32}},
      color={0,0,127}));
  connect(zer.y, pumChw.m_flow_in)
    annotation(Line(points={{-170,100},{-20,100},{-20,0},{20,0},{20,-8}},
      color={0,0,127}));
  connect(p5.y, loaChw.u)
    annotation(Line(points={{-138,120},{120,120},{120,-12},{138,-12}},
      color={0,0,127}));
  connect(p5.y, loaHw.u)
    annotation(Line(points={{-138,120},{120,120},{120,-52},{138,-52}},
      color={0,0,127}));
  connect(one1.y, loaChw.u1)
    annotation(Line(points={{-138,158},{128,158},{128,-16},{138,-16}},
      color={255,0,255}));
  connect(one1.y, loaHw.u1)
    annotation(Line(points={{-138,158},{128,158},{128,-56},{138,-56}},
      color={255,0,255}));
  connect(bou.ports[1], hp0dp.port_a)
    annotation(Line(points={{-60,-90},{-60,-60}},
      color={0,127,255}));
  connect(com.port_a, cheValHw.port_b)
    annotation(Line(points={{90,-50},{90,-60},{60,-60}},
      color={0,127,255}));
  connect(com1.port_a, cheValChw.port_b)
    annotation(Line(points={{90,-10},{90,-20},{60,-20}},
      color={0,127,255}));
annotation(experiment(StopTime=10000,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"),
  Diagram(coordinateSystem(extent={{-200,-180},{200,180}})));
end Reproducer;
