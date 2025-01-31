within Buildings.Fluid.HydronicConfigurations.Examples;
model LaBrulatteSub "Substation"
  extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
    redeclare final package Medium1=Medium,
    redeclare final package Medium2=Medium,
    final m1_flow_nominal=m_flow_nominal,
    final m2_flow_nominal=m_flow_nominal);
  replaceable package Medium = Buildings.Media.Water
    "Medium model for hot water";
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal;
  parameter Modelica.Units.SI.PressureDifference dpTan_nominal;
  parameter Modelica.Units.SI.PressureDifference dp_nominal
    "Primary pump Δp";
  parameter Modelica.Units.SI.Length dhPip;
  parameter Modelica.Units.SI.Length lPip;
  parameter Modelica.Units.SI.Volume VTan;
  parameter Modelica.Units.SI.Length hTan = (16 * VTan / Modelica.Constants.pi)^(1/3);

  Movers.Preconfigured.SpeedControlled_y pum(
    redeclare final package Medium = Medium,
    addPowerToMedium=false,
    final m_flow_nominal=m_flow_nominal,
    dp_nominal=dp_nominal)
    annotation (Placement(transformation(extent={{-10,50},{10,70}})));
  Storage.StratifiedEnhanced tan(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    VTan=VTan,
    hTan=hTan,
    dIns=0.1) annotation (Placement(transformation(extent={{70,-10},{90,10}})));
  FixedResistances.PressureDrop resTan(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dpTan_nominal)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={80,-30})));
  FixedResistances.HydraulicDiameter pipSup(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dh=dhPip,
    length=lPip)
    annotation (Placement(transformation(extent={{-70,50},{-50,70}})));
  FixedResistances.HydraulicDiameter pipRet(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dh=dhPip,
    length=lPip)
    annotation (Placement(transformation(extent={{-50,-70},{-70,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput y annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,120}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-60,120})));
equation
  connect(tan.port_b, resTan.port_a)
    annotation (Line(points={{80,-10},{80,-20}},
                                               color={0,127,255}));
  connect(pipSup.port_b, pum.port_a)
    annotation (Line(points={{-50,60},{-10,60}}, color={0,127,255}));
  connect(pum.port_b, tan.port_a) annotation (Line(points={{10,60},{40,60},{40,
          20},{80,20},{80,10}}, color={0,127,255}));
  connect(resTan.port_b, pipRet.port_a)
    annotation (Line(points={{80,-40},{40,-40},{40,-60},{-50,-60}},
                                                  color={0,127,255}));
  connect(port_a1, pipSup.port_a)
    annotation (Line(points={{-100,60},{-70,60}}, color={0,127,255}));
  connect(pipRet.port_b, port_b2)
    annotation (Line(points={{-70,-60},{-100,-60}}, color={0,127,255}));
  connect(port_a2, pipRet.port_a)
    annotation (Line(points={{100,-60},{-50,-60}}, color={0,127,255}));
  connect(y, pum.y) annotation (Line(points={{0,120},{0,72}}, color={0,0,127}));
  connect(pum.port_b, port_b1)
    annotation (Line(points={{10,60},{100,60}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={175,175,175},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-100,60},{100,60}},
          color={0,0,0},
          thickness=0.5),
        Ellipse(
          extent={{-20,20},{20,-20}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          origin={-40,60},
          rotation=-90),
        Polygon(
          points={{-20,60},{-50,78},{-50,42},{-20,60}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{20,28},{60,-32}},
          lineColor={0,0,0},
          lineThickness=0.5),
        Line(
          points={{-100,-60},{100,-60}},
          color={0,0,0},
          thickness=0.5),
        Line(
          points={{0,60},{0,20},{20,20}},
          color={0,0,0},
          thickness=0.5),
        Line(
          points={{20,-20},{0,-20},{0,-60}},
          color={0,0,0},
          thickness=0.5)}),                                      Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end LaBrulatteSub;
