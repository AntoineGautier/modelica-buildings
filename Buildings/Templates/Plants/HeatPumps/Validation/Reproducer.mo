within Buildings.Templates.Plants.HeatPumps.Validation;
model Reproducer
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Water
    constrainedby Modelica.Media.Interfaces.PartialMedium
    "Main medium (common for CHW and HW)";

  parameter Boolean use_cpl = false
    "Set to true to use compliance components"
    annotation(Evaluate=true);
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
    annotation(Placement(transformation(extent={{10,-90},{30,-70}})));
  Fluid.FixedResistances.CheckValve cheValHw(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,-90},{60,-70}})));
  Fluid.Actuators.Valves.TwoWayLinear valHw(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,-90},{-90,-70}})));
  Fluid.Actuators.Valves.TwoWayLinear valChw(
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,-50},{-90,-30}})));
  Fluid.FixedResistances.PressureDrop hp0dp(
    m_flow_nominal=pumHw.m_flow_nominal,
    dp_nominal=0,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-60,-90},{-40,-70}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumChw(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaChw.dpTer_nominal + loaChw.dpValve_nominal +
      valChw.dpFixed_nominal + valChw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,-50},{30,-30}})));
  Fluid.FixedResistances.CheckValve cheValChw(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,-50},{60,-30}})));
  Buildings.Templates.Components.Loads.LoadTwoWayValve loaHw(
    redeclare package MediumLiq=Medium,
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Heating,
    mLiq_flow_nominal=sum({pumHw.m_flow_nominal, pumHw1.m_flow_nominal}))
    annotation(Placement(transformation(extent={{140,-90},{160,-70}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumHw1(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaHw.dpTer_nominal + loaHw.dpValve_nominal +
      valHw.dpFixed_nominal + valHw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,-10},{30,10}})));
  Fluid.FixedResistances.CheckValve cheValHw1(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,-10},{60,10}})));
  Fluid.Actuators.Valves.TwoWayLinear valHw1(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    dpFixed_nominal=Buildings.Templates.Data.Defaults.dpHeaWatHp,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Fluid.Actuators.Valves.TwoWayLinear valChw1(
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValIso,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-110,30},{-90,50}})));
  Fluid.FixedResistances.PressureDrop hp0dp1(
    m_flow_nominal=pumHw.m_flow_nominal,
    dp_nominal=0,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-60,-10},{-40,10}})));
  Fluid.Movers.Preconfigured.FlowControlled_m_flow pumChw1(
    redeclare final package Medium=Medium,
    final allowFlowReversal=allowFlowReversal,
    final energyDynamics=energyDynamics,
    m_flow_nominal=20,
    dp_nominal=loaChw.dpTer_nominal + loaChw.dpValve_nominal +
      valChw.dpFixed_nominal + valChw.dpValve_nominal)
    annotation(Placement(transformation(extent={{10,30},{30,50}})));
  Fluid.FixedResistances.CheckValve cheValChw1(
    redeclare package Medium=Medium,
    final m_flow_nominal=pumChw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValChe)
    annotation(Placement(transformation(extent={{40,30},{60,50}})));
  Fluid.Actuators.Valves.TwoWayLinear valHwBypMin(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValBypMin,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{-10,10},{10,-10}},
      rotation=-90,
      origin={100,-120})));
  Buildings.Templates.Components.Loads.LoadTwoWayValve loaChw(
    redeclare package MediumLiq=Medium,
    typ=Buildings.Fluid.HydronicConfigurations.Types.Control.Cooling,
    mLiq_flow_nominal=sum({pumChw.m_flow_nominal, pumChw1.m_flow_nominal}))
    annotation(Placement(transformation(extent={{140,-50},{160,-30}})));
  Fluid.Actuators.Valves.TwoWayLinear valChwBypMin(
    final m_flow_nominal=pumHw.m_flow_nominal,
    dpValve_nominal=Buildings.Templates.Data.Defaults.dpValBypMin,
    redeclare package Medium=Medium)
    annotation(Placement(transformation(extent={{10,10},{-10,-10}},
      rotation=-90,
      origin={100,10})));
  Fluid.Sources.Boundary_pT bou(
    p=Buildings.Templates.Data.Defaults.pHeaWat_rel_nominal,
    redeclare package Medium=Medium,
    nPorts=1)
    annotation(Placement(transformation(extent={{10,-10},{-10,10}},
      rotation=90,
      origin={-100,-120})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Pulse one(period=1200)
    annotation(Placement(transformation(extent={{-192,110},{-172,130}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant zer(k=0)
    annotation(Placement(transformation(extent={{-192,70},{-172,90}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant p5(k=1)
    annotation(Placement(transformation(extent={{-160,90},{-140,110}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant tru(k=true)
    annotation (Placement(transformation(extent={{-160,130},{-140,150}})));
  Buildings.Controls.OBC.CDL.Logical.Sources.Constant fal(k=false)
    annotation (Placement(transformation(extent={{-130,150},{-110,170}})));
  Buildings.Templates.Components.Routing.Compliance com(redeclare package
      Medium = Medium, p_start=bou.p) if use_cpl
    annotation (Placement(transformation(extent={{80,-30},{100,-10}})));
  Buildings.Templates.Components.Routing.Compliance com1(redeclare package
      Medium = Medium, p_start=bou.p) if use_cpl
    annotation (Placement(transformation(extent={{80,-70},{100,-50}})));
equation
  connect(pumHw.port_b, cheValHw.port_a)
    annotation(Line(points={{30,-80},{40,-80}},
      color={0,127,255}));
  connect(hp0dp.port_b, pumHw.port_a)
    annotation(Line(points={{-40,-80},{10,-80}},
      color={0,127,255}));
  connect(valHw.port_b, hp0dp.port_a)
    annotation(Line(points={{-90,-80},{-60,-80}},
      color={0,127,255}));
  connect(valChw.port_b, hp0dp.port_a)
    annotation(Line(points={{-90,-40},{-80,-40},{-80,-80},{-60,-80}},
      color={0,127,255}));
  connect(pumChw.port_b, cheValChw.port_a)
    annotation(Line(points={{30,-40},{40,-40}},
      color={0,127,255}));
  connect(hp0dp.port_b, pumChw.port_a)
    annotation(Line(points={{-40,-80},{0,-80},{0,-40},{10,-40}},
      color={0,127,255}));
  connect(pumHw1.port_b, cheValHw1.port_a)
    annotation(Line(points={{30,0},{40,0}},
      color={0,127,255}));
  connect(hp0dp1.port_b, pumHw1.port_a)
    annotation(Line(points={{-40,0},{10,0}},
      color={0,127,255}));
  connect(valHw1.port_b, hp0dp1.port_a)
    annotation(Line(points={{-90,0},{-60,0}},
      color={0,127,255}));
  connect(valChw1.port_b, hp0dp1.port_a)
    annotation(Line(points={{-90,40},{-80,40},{-80,0},{-60,0}},
      color={0,127,255}));
  connect(pumChw1.port_b, cheValChw1.port_a)
    annotation(Line(points={{30,40},{40,40}},
      color={0,127,255}));
  connect(hp0dp1.port_b, pumChw1.port_a)
    annotation(Line(points={{-40,0},{0,0},{0,40},{10,40}},
      color={0,127,255}));
  connect(cheValHw.port_b, valHwBypMin.port_a)
    annotation(Line(points={{60,-80},{100,-80},{100,-110}},
      color={0,127,255}));
  connect(cheValHw.port_b, loaHw.port_a)
    annotation(Line(points={{60,-80},{140,-80}},
      color={0,127,255}));
  connect(cheValHw1.port_b, cheValHw.port_b)
    annotation(Line(points={{60,0},{80,0},{80,-80},{60,-80}},
      color={0,127,255}));
  connect(cheValChw.port_b, loaChw.port_a)
    annotation(Line(points={{60,-40},{140,-40}},
      color={0,127,255}));
  connect(cheValChw1.port_b, cheValChw.port_b)
    annotation(Line(points={{60,40},{68,40},{68,-40},{60,-40}},
      color={0,127,255}));
  connect(loaChw.port_b, valChw.port_a)
    annotation(Line(
      points={{160,-40},{180,-40},{180,60},{-140,60},{-140,-40},{-110,-40}},
      color={0,127,255}));
  connect(valChw.port_a, valChw1.port_a)
    annotation(Line(points={{-110,-40},{-140,-40},{-140,40},{-110,40}},
      color={0,127,255}));
  connect(loaHw.port_b, valHw.port_a)
    annotation(Line(
      points={{160,-80},{180,-80},{180,-160},{-150,-160},{-150,-80},{-110,-80}},
      color={0,127,255}));
  connect(valHw.port_a, valHw1.port_a)
    annotation(Line(points={{-110,-80},{-150,-80},{-150,0},{-110,0}},
      color={0,127,255}));
  connect(valHwBypMin.port_b, valHw.port_a)
    annotation(Line(
      points={{100,-130},{100,-160},{-150,-160},{-150,-80},{-110,-80}},
      color={0,127,255}));
  connect(cheValChw.port_b,valChwBypMin. port_a)
    annotation(Line(points={{60,-40},{100,-40},{100,0}},
      color={0,127,255}));
  connect(valChwBypMin.port_b, valChw.port_a)
    annotation(Line(points={{100,20},{100,60},{-140,60},{-140,-40},{-110,-40}},
      color={0,127,255}));
  connect(zer.y, valHwBypMin.y)
    annotation(Line(points={{-170,80},{-20,80},{-20,-120},{88,-120}},
      color={0,0,127}));
  connect(zer.y, valChw.y)
    annotation(Line(points={{-170,80},{-20,80},{-20,-20},{-100,-20},{-100,-28}},
      color={0,0,127}));
  connect(zer.y, pumChw.m_flow_in)
    annotation(Line(points={{-170,80},{-20,80},{-20,-20},{20,-20},{20,-28}},
      color={0,0,127}));
  connect(p5.y, loaHw.u)
    annotation(Line(points={{-138,100},{120,100},{120,-72},{138,-72}},
      color={0,0,127}));
  connect(tru.y, loaHw.u1) annotation (Line(points={{-138,140},{128,140},{128,
          -76},{138,-76}}, color={255,0,255}));
  connect(zer.y, pumChw1.m_flow_in) annotation (Line(points={{-170,80},{-20,80},
          {-20,66},{20,66},{20,52}}, color={0,0,127}));
  connect(zer.y, valChw1.y) annotation (Line(points={{-170,80},{-20,80},{-20,66},
          {-100,66},{-100,52}}, color={0,0,127}));
  connect(fal.y, loaChw.u1) annotation (Line(points={{-108,160},{126,160},{126,
          -36},{138,-36}}, color={255,0,255}));
  connect(zer.y, loaChw.u) annotation (Line(points={{-170,80},{124,80},{124,-32},
          {138,-32}}, color={0,0,127}));
  connect(p5.y, valChwBypMin.y) annotation (Line(points={{-138,100},{80,100},{
          80,10},{88,10}}, color={0,0,127}));
  connect(one.y, valHw1.y) annotation (Line(points={{-170,120},{-12,120},{-12,
          20},{-100,20},{-100,12}}, color={0,0,127}));
  connect(one.y, pumHw1.m_flow_in) annotation (Line(points={{-170,120},{-12,120},
          {-12,20},{20,20},{20,12}}, color={0,0,127}));
  connect(zer.y, pumHw.m_flow_in) annotation (Line(points={{-170,80},{-20,80},{
          -20,-60},{20,-60},{20,-68}}, color={0,0,127}));
  connect(zer.y, valHw.y) annotation (Line(points={{-170,80},{-20,80},{-20,-60},
          {-100,-60},{-100,-68}}, color={0,0,127}));
  connect(bou.ports[1], valHwBypMin.port_b) annotation (Line(points={{-100,-130},
          {-100,-160},{100,-160},{100,-130}}, color={0,127,255}));
  connect(com.port_a, cheValChw.port_b)
    annotation (Line(points={{90,-30},{90,-40},{60,-40}}, color={0,127,255}));
  connect(com1.port_a, cheValHw.port_b)
    annotation (Line(points={{90,-70},{90,-80},{60,-80}}, color={0,127,255}));
annotation(experiment(StopTime=10000,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"),
  Diagram(coordinateSystem(extent={{-200,-180},{200,180}})));
end Reproducer;
