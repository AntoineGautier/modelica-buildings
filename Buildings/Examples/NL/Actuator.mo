within Buildings.Examples.NL;
model Actuator
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium";

  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal = 30;
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
  Fluid.FixedResistances.PressureDrop res(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal,
    final dp_nominal=Buildings.Templates.Data.Defaults.dpHeaWatRemSet_max)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=-90,
      origin={120,-60})));
  Fluid.Movers.Preconfigured.SpeedControlled_y pum(
    redeclare final package Medium=Medium,
    final energyDynamics=energyDynamics,
    final m_flow_nominal=m_flow_nominal / 2,
    final dp_nominal=cheVal.dpValve_nominal + valIso1.dpValve_nominal +
      valIso1.dpFixed_nominal + res.dp_nominal)
    annotation(Placement(transformation(extent={{-110,-50},{-90,-30}})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage valByp(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal * 0.3,
    from_dp=true,
    final dpValve_nominal=Buildings.Templates.Data.Defaults.dpValBypMin)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=-90,
      origin={60,-60})));
  Fluid.Sources.Boundary_pT bou(
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal,
    nPorts=1,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=0,
      origin={-160,-40})));
  Controls.OBC.CDL.Reals.Sources.Pulse pul(period=600, shift=100)
    annotation(Placement(transformation(extent={{-168,70},{-148,90}})));
  Controls.OBC.CDL.Reals.Sources.Constant con(k=0)
    annotation(Placement(transformation(extent={{-130,50},{-110,70}})));
  Fluid.FixedResistances.CheckValve cheVal(
    redeclare final package Medium=Medium,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe,
    final m_flow_nominal=pum.m_flow_nominal)
    annotation(Placement(transformation(extent={{-80,-50},{-60,-30}})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage valIso1(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal / 2,
    from_dp=true,
    final dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=0,
      origin={0,-40})));
  Controls.OBC.CDL.Reals.Sources.Constant con1(k=1)
    annotation(Placement(transformation(extent={{-170,30},{-150,50}})));
  Fluid.Actuators.Valves.TwoWayEqualPercentage valIso2(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal / 2,
    from_dp=true,
    final dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp)
    annotation(Placement(transformation(extent={{-10,-10},{10,10}},
      rotation=0)));
  Fluid.Movers.Preconfigured.SpeedControlled_y pum1(
    redeclare final package Medium=Medium,
    final energyDynamics=energyDynamics,
    final m_flow_nominal=m_flow_nominal / 2,
    final dp_nominal=cheVal.dpValve_nominal + valIso1.dpValve_nominal +
      valIso1.dpFixed_nominal + res.dp_nominal)
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Fluid.FixedResistances.CheckValve cheVal1(
    redeclare final package Medium=Medium,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe,
    final m_flow_nominal=pum1.m_flow_nominal)
    annotation(Placement(transformation(extent={{-80,-10},{-60,10}})));
equation
  connect(bou.ports[1], pum.port_a)
    annotation(Line(points={{-150,-40},{-110,-40}},
      color={0,127,255}));
  connect(con.y, valByp.y)
    annotation(Line(points={{-108,60},{100,60},{100,-60},{72,-60}},
      color={0,0,127}));
  connect(pul.y, pum.y)
    annotation(Line(
      points={{-146,80},{-140,80},{-140,-20},{-100,-20},{-100,-28}},
      color={0,0,127}));
  connect(pum.port_b, cheVal.port_a)
    annotation(Line(points={{-90,-40},{-80,-40}},
      color={0,127,255}));
  connect(valIso1.port_b, valByp.port_a)
    annotation(Line(points={{10,-40},{60,-40},{60,-50}},
      color={0,127,255}));
  connect(valIso1.port_b, res.port_a)
    annotation(Line(points={{10,-40},{120,-40},{120,-50}},
      color={0,127,255}));
  connect(con1.y, valIso1.y)
    annotation(Line(points={{-148,40},{-20,40},{-20,-20},{0,-20},{0,-28}},
      color={0,0,127}));
  connect(cheVal.port_b, valIso2.port_a)
    annotation(Line(points={{-60,-40},{-40,-40},{-40,0},{-10,0}},
      color={0,127,255}));
  connect(cheVal.port_b, valIso1.port_a)
    annotation(Line(points={{-60,-40},{-10,-40}},
      color={0,127,255}));
  connect(con.y, valIso2.y)
    annotation(Line(points={{-108,60},{0,60},{0,12}},
      color={0,0,127}));
  connect(valIso2.port_b, valIso1.port_b)
    annotation(Line(points={{10,0},{40,0},{40,-40},{10,-40}},
      color={0,127,255}));
  connect(valByp.port_b, res.port_b)
    annotation(Line(points={{60,-70},{60,-80},{120,-80},{120,-70}},
      color={0,127,255}));
  connect(res.port_b, pum.port_a)
    annotation(Line(
      points={{120,-70},{120,-80},{-120,-80},{-120,-40},{-110,-40}},
      color={0,127,255}));
  connect(res.port_b, pum1.port_a)
    annotation(Line(points={{120,-70},{120,-80},{-120,-80},{-120,0},{-110,0}},
      color={0,127,255}));
  connect(pum1.port_b, cheVal1.port_a)
    annotation(Line(points={{-90,0},{-80,0}},
      color={0,127,255}));
  connect(cheVal1.port_b, cheVal.port_b)
    annotation(Line(points={{-60,0},{-60,-40}},
      color={0,127,255}));
  connect(con.y, pum1.y)
    annotation(Line(points={{-108,60},{-100,60},{-100,12}},
      color={0,0,127}));
annotation(experiment(Tolerance=1e-6,
  StopTime=600.0),
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false,
    extent={{-180,-100},{180,100}})));
end Actuator;
