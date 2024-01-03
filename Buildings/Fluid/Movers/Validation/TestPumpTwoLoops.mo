within Buildings.Fluid.Movers.Validation;
model TestPumpTwoLoops
  FixedResistances.PressureDrop hp1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dp_nominal=4E4)
    annotation (Placement(transformation(extent={{-30,90},{-10,110}})));
  Preconfigured.SpeedControlled_y pmp1(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=5,
    dp_nominal(displayUnit="Pa") = hp1.dp_nominal + hex1.dp_nominal + cheVal1.dpValve_nominal)
    annotation (Placement(transformation(extent={{10,90},{30,110}})));
  Preconfigured.SpeedControlled_y pmp2(
    redeclare package Medium = Buildings.Media.Water,
    addPowerToMedium=false,
    m_flow_nominal=5,
    dp_nominal(displayUnit="Pa") = hp2.dp_nominal + hex1.dp_nominal + cheVal2.dpValve_nominal)
    annotation (Placement(transformation(extent={{10,10},{30,30}})));
  FixedResistances.PressureDrop hex1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal + pmp2.m_flow_nominal,
    dp_nominal=3E4) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={100,0})));
  FixedResistances.PressureDrop hp2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
    dp_nominal=hp1.dp_nominal)
    annotation (Placement(transformation(extent={{-30,10},{-10,30}})));
  Controls.OBC.CDL.Reals.Sources.TimeTable timTab(table=[0,0; 1,0; 1,1; 2,1],
      timeScale=1000)
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  Sources.Boundary_pT bou(redeclare package Medium = Buildings.Media.Water,
      nPorts=1) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={20,150})));
  FixedResistances.CheckValve cheVal1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
      dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{60,90},{80,110}})));
  FixedResistances.CheckValve cheVal2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
      dpValve_nominal=1E4)
    annotation (Placement(transformation(extent={{60,10},{80,30}})));
  FixedResistances.PressureDrop hex2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal + pmp2.m_flow_nominal,
    dp_nominal=3E4) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={180,0})));
  Controls.OBC.CDL.Reals.Sources.Constant con1(k=1)
    annotation (Placement(transformation(extent={{-140,120},{-120,140}})));
  FixedResistances.PressureDrop res2to2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
    dp_nominal=300) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-100,-90})));
  FixedResistances.PressureDrop res2to1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dp_nominal=300) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-140,-90})));
  FixedResistances.PressureDrop res1to1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dp_nominal=300) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-70,-30})));
  FixedResistances.PressureDrop res1to2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
    dp_nominal=300) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={-40,-30})));
  FixedResistances.PressureDrop ret2(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dp_nominal=1)
    annotation (Placement(transformation(extent={{-80,-130},{-100,-110}})));
  FixedResistances.PressureDrop ret1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp2.m_flow_nominal,
    dp_nominal=1)
    annotation (Placement(transformation(extent={{-20,-90},{-40,-70}})));
  Actuators.Valves.TwoWayLinear val1(
    redeclare package Medium = Buildings.Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=-90,
        origin={100,40})));
  Controls.OBC.CDL.Reals.Sources.Constant con2(k=0)
    annotation (Placement(transformation(extent={{40,50},{60,70}})));
  Actuators.Valves.TwoWayLinear val2(
    redeclare package Medium = Media.Water,
    m_flow_nominal=pmp1.m_flow_nominal,
    dpValve_nominal=5000) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={140,20})));
equation
  connect(hp2.port_b, pmp2.port_a)
    annotation (Line(points={{-10,20},{10,20}},    color={0,127,255}));
  connect(bou.ports[1], pmp1.port_a) annotation (Line(points={{20,140},{0,140},
          {0,100},{10,100}},
                           color={0,127,255}));
  connect(pmp1.port_b, cheVal1.port_a)
    annotation (Line(points={{30,100},{60,100}},
                                               color={0,127,255}));
  connect(pmp2.port_b, cheVal2.port_a)
    annotation (Line(points={{30,20},{60,20}},   color={0,127,255}));
  connect(cheVal2.port_b, hex1.port_a)
    annotation (Line(points={{80,20},{100,20},{100,10}}, color={0,127,255}));
  connect(timTab.y[1], pmp2.y)
    annotation (Line(points={{12,60},{20,60},{20,32}}, color={0,0,127}));
  connect(cheVal1.port_b, hex2.port_a)
    annotation (Line(points={{80,100},{180,100},{180,10}}, color={0,127,255}));
  connect(hp1.port_b, pmp1.port_a)
    annotation (Line(points={{-10,100},{10,100}}, color={0,127,255}));
  connect(con1.y, pmp1.y)
    annotation (Line(points={{-118,130},{20,130},{20,112}}, color={0,0,127}));
  connect(res2to1.port_b, hp1.port_a) annotation (Line(points={{-140,-80},{-140,
          100},{-30,100}}, color={0,127,255}));
  connect(hex2.port_b, ret2.port_a) annotation (Line(points={{180,-10},{180,
          -120},{-80,-120}}, color={0,127,255}));
  connect(ret2.port_b, res2to1.port_a) annotation (Line(points={{-100,-120},{
          -140,-120},{-140,-100}}, color={0,127,255}));
  connect(ret2.port_b, res2to2.port_a)
    annotation (Line(points={{-100,-120},{-100,-100}}, color={0,127,255}));
  connect(hex1.port_b, ret1.port_a) annotation (Line(points={{100,-10},{100,-80},
          {-20,-80}}, color={0,127,255}));
  connect(ret1.port_b, res1to2.port_a)
    annotation (Line(points={{-40,-80},{-40,-40}}, color={0,127,255}));
  connect(res1to2.port_b, hp2.port_a)
    annotation (Line(points={{-40,-20},{-40,20},{-30,20}}, color={0,127,255}));
  connect(ret1.port_b, res1to1.port_a) annotation (Line(points={{-40,-80},{-70,
          -80},{-70,-40}}, color={0,127,255}));
  connect(res1to1.port_b, hp1.port_a) annotation (Line(points={{-70,-20},{-70,
          100},{-30,100}}, color={0,127,255}));
  connect(res2to2.port_b, hp2.port_a) annotation (Line(points={{-100,-80},{-100,
          20},{-30,20}}, color={0,127,255}));
  connect(cheVal1.port_b, val1.port_a)
    annotation (Line(points={{80,100},{100,100},{100,50}}, color={0,127,255}));
  connect(con2.y, val1.y) annotation (Line(points={{62,60},{76,60},{76,40},{88,
          40}}, color={0,0,127}));
  connect(val1.port_b, hex1.port_a)
    annotation (Line(points={{100,30},{100,10}}, color={0,127,255}));
  connect(cheVal2.port_b, val2.port_a)
    annotation (Line(points={{80,20},{130,20}}, color={0,127,255}));
  connect(val2.port_b, hex2.port_a)
    annotation (Line(points={{150,20},{180,20},{180,10}}, color={0,127,255}));
  connect(con2.y, val2.y)
    annotation (Line(points={{62,60},{140,60},{140,32}}, color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,-180},{220,
            180}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-160,-180},{
            220,180}})),
    experiment(StopTime=2000, __Dymola_Algorithm="Dassl"));
end TestPumpTwoLoops;
