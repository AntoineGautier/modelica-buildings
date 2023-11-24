within Buildings.Fluid.Movers.Validation;
model TestPump
  FixedResistances.PressureDrop hp1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dp_nominal=3E4)
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Preconfigured.SpeedControlled_y pmp1(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=5,
    dp_nominal(displayUnit="Pa") = hp1.dp_nominal + hex.dp_nominal + val.dp_nominal)
    annotation (Placement(transformation(extent={{30,30},{50,50}})));
  Preconfigured.SpeedControlled_y pmp2(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=5,
    dp_nominal(displayUnit="Pa") = hp2.dp_nominal + hex.dp_nominal)
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  FixedResistances.PressureDrop hex(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal + pmp2.m_flow_nominal,
    dp_nominal=5E4) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,-60})));
  FixedResistances.PressureDrop hp2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
    dp_nominal=hp1.dp_nominal)
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Controls.OBC.CDL.Reals.Sources.TimeTable timTab(table=[0,0; 1,0; 1,1; 2,1],
      timeScale=1000)
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Sources.Boundary_pT bou(redeclare package Medium = Buildings.Media.Water,
      nPorts=1) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={40,88})));
  Sensors.RelativePressure senRelPre(redeclare package Medium =
        Buildings.Media.Water)
    annotation (Placement(transformation(extent={{-60,82},{-40,62}})));
  Controls.OBC.CDL.Reals.PID conPID(
    k=0.1,
    Ti=10,
    r=hp1.dp_nominal,
    reverseActing=true)
    annotation (Placement(transformation(extent={{-60,90},{-40,110}})));
  Controls.OBC.CDL.Reals.Sources.Constant con(k=hp1.dp_nominal)
    annotation (Placement(transformation(extent={{-100,90},{-80,110}})));
  Controls.OBC.CDL.Reals.Sources.Constant con1(k=1)
    annotation (Placement(transformation(extent={{-140,50},{-120,70}})));
  Actuators.Valves.TwoWayLinear val(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dpValve_nominal=5000)
    annotation (Placement(transformation(extent={{-10,30},{10,50}})));
equation
  connect(hp2.port_b, pmp2.port_a)
    annotation (Line(points={{-40,-40},{-10,-40}}, color={0,127,255}));
  connect(pmp2.port_b, hex.port_a)
    annotation (Line(points={{10,-40},{80,-40},{80,-50}}, color={0,127,255}));
  connect(hex.port_b, hp2.port_a) annotation (Line(points={{80,-70},{80,-80},{
          -80,-80},{-80,-40},{-60,-40}}, color={0,127,255}));
  connect(hex.port_b, hp1.port_a) annotation (Line(points={{80,-70},{80,-80},{
          -80,-80},{-80,40},{-60,40}}, color={0,127,255}));
  connect(timTab.y[1], pmp2.y)
    annotation (Line(points={{-38,0},{0,0},{0,-28}}, color={0,0,127}));
  connect(hp1.port_a, senRelPre.port_a)
    annotation (Line(points={{-60,40},{-60,72}}, color={0,127,255}));
  connect(senRelPre.p_rel, conPID.u_m)
    annotation (Line(points={{-50,81},{-50,88}}, color={0,0,127}));
  connect(con.y, conPID.u_s) annotation (Line(points={{-78,100},{-68,100},{-68,
          100},{-62,100}}, color={0,0,127}));
  connect(con1.y, pmp1.y)
    annotation (Line(points={{-118,60},{40,60},{40,52}}, color={0,0,127}));
  connect(conPID.y, val.y)
    annotation (Line(points={{-38,100},{0,100},{0,52}}, color={0,0,127}));
  connect(senRelPre.port_b, hp1.port_b)
    annotation (Line(points={{-40,72},{-40,40},{-40,40}}, color={0,127,255}));
  connect(hp1.port_b, val.port_a)
    annotation (Line(points={{-40,40},{-10,40}}, color={0,127,255}));
  connect(val.port_b, pmp1.port_a)
    annotation (Line(points={{10,40},{30,40}}, color={0,127,255}));
  connect(bou.ports[1], pmp1.port_a) annotation (Line(points={{40,78},{34,78},{
          34,40},{30,40}}, color={0,127,255}));
  connect(pmp1.port_b, hex.port_a)
    annotation (Line(points={{50,40},{80,40},{80,-50}}, color={0,127,255}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=2000, __Dymola_Algorithm="Dassl"));
end TestPump;
