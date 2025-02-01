within Buildings.Fluid.HydronicConfigurations.Examples;
model LaBrulatteSub "Substation"
  extends Buildings.Fluid.Interfaces.PartialFourPortInterface(
    redeclare final package Medium1=Medium,
    redeclare final package Medium2=Medium,
    final m1_flow_nominal=m_flow_nominal,
    final m2_flow_nominal=m_flow_nominal);
  replaceable package Medium = Buildings.Media.Water
    "Medium model for hot water";

  parameter Boolean have_val = false
    annotation(Evaluate=true);
  parameter Boolean have_tan = true
    annotation(Evaluate=true);
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
    dIns=50E-3) if have_tan
              annotation (Placement(transformation(extent={{70,-10},{90,10}})));
  FixedResistances.PressureDrop resTan(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=dpTan_nominal) if have_tan
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
  Buildings.Controls.OBC.CDL.Interfaces.RealInput y
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,120}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-60,120})));
  ActiveNetworks.Diversion con(
    redeclare final package Medium = Medium,
    m2_flow_nominal=m_flow_nominal,
    dp2_nominal=dpTan_nominal,
    dpBal3_nominal=dpTan_nominal)
    if have_val
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={50,-34})));
  Templates.Plants.Controls.Utilities.PIDWithEnable conPID(
    k=0.1,
    Ti=60,
    reverseActing=false)
    if have_val
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Sensors.TemperatureTwoPort TRet(
    redeclare final package Medium = Medium,
    m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{10,-70},{-10,-50}})));
  Buildings.Controls.OBC.CDL.Reals.GreaterThreshold greThr(t=1E-2, h=1E-3)
    annotation (Placement(transformation(extent={{-14,70},{-34,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet
    if have_val
    annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,0}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-120,0})));
  Templates.Components.Routing.PassThroughFluid pas(
    redeclare final package Medium = Medium) if not have_val
    annotation (Placement(transformation(extent={{50,30},{70,50}})));
  Templates.Components.Routing.PassThroughFluid pas1(
    redeclare final package Medium = Medium) if not have_val
    annotation (Placement(transformation(extent={{70,-64},{50,-44}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPor if have_tan
    "Heat port tank (outside insulation)" annotation (Placement(transformation(
          extent={{94,-6},{106,6}}), iconTransformation(extent={{94,-6},{106,6}})));
equation
  connect(tan.port_b, resTan.port_a)
    annotation (Line(points={{80,-10},{80,-20}},
                                               color={0,127,255}));
  connect(pipSup.port_b, pum.port_a)
    annotation (Line(points={{-50,60},{-10,60}}, color={0,127,255}));
  connect(port_a1, pipSup.port_a)
    annotation (Line(points={{-100,60},{-70,60}}, color={0,127,255}));
  connect(pipRet.port_b, port_b2)
    annotation (Line(points={{-70,-60},{-100,-60}}, color={0,127,255}));
  connect(y, pum.y) annotation (Line(points={{0,120},{0,72}}, color={0,0,127}));
  connect(pum.port_b, port_b1)
    annotation (Line(points={{10,60},{100,60}}, color={0,127,255}));
  connect(resTan.port_b, con.port_a2)
    annotation (Line(points={{80,-40},{60,-40}}, color={0,127,255}));
  connect(pum.port_b, con.port_a1)
    annotation (Line(points={{10,60},{40,60},{40,-28}}, color={0,127,255}));
  connect(con.port_b2, tan.port_a) annotation (Line(points={{60,-28},{60,20},{80,
          20},{80,10}}, color={0,127,255}));
  connect(TRet.port_b, pipRet.port_a)
    annotation (Line(points={{-10,-60},{-50,-60}}, color={0,127,255}));
  connect(TRet.T, conPID.u_m)
    annotation (Line(points={{0,-49},{0,-12}}, color={0,0,127}));
  connect(port_a2, TRet.port_a)
    annotation (Line(points={{100,-60},{10,-60}}, color={0,127,255}));
  connect(greThr.y, conPID.uEna) annotation (Line(points={{-36,80},{-40,80},{-40,
          -20},{-4,-20},{-4,-12}}, color={255,0,255}));
  connect(conPID.y, con.yVal)
    annotation (Line(points={{12,0},{50,0},{50,-22}}, color={0,0,127}));
  connect(con.port_b1, TRet.port_a)
    annotation (Line(points={{40,-40},{40,-60},{10,-60}}, color={0,127,255}));
  connect(TSet, conPID.u_s)
    annotation (Line(points={{-120,0},{-12,0}}, color={0,0,127}));
  connect(y, greThr.u)
    annotation (Line(points={{0,120},{0,80},{-12,80}}, color={0,0,127}));
  connect(pum.port_b, pas.port_a) annotation (Line(points={{10,60},{40,60},{40,40},
          {50,40}}, color={0,127,255}));
  connect(pas.port_b, tan.port_a)
    annotation (Line(points={{70,40},{80,40},{80,10}}, color={0,127,255}));
  connect(resTan.port_b, pas1.port_a)
    annotation (Line(points={{80,-40},{80,-54},{70,-54}}, color={0,127,255}));
  connect(pas1.port_b, TRet.port_a) annotation (Line(points={{50,-54},{40,-54},{
          40,-60},{10,-60}}, color={0,127,255}));
  connect(tan.heaPorTop, heaPor) annotation (Line(points={{82,7.4},{94,7.4},{94,
          0},{100,0}}, color={191,0,0}));
  connect(tan.heaPorSid, heaPor)
    annotation (Line(points={{85.6,0},{100,0}}, color={191,0,0}));
  connect(tan.heaPorBot, heaPor) annotation (Line(points={{82,-7.4},{94,-7.4},{
          94,0},{100,0}}, color={191,0,0}));
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
