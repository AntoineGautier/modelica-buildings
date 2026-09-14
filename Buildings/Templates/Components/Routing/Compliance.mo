within Buildings.Templates.Components.Routing;
model Compliance
  "Hydraulic compliance providing a pressure state at the connected node"
  replaceable package Medium=Modelica.Media.Interfaces.PartialMedium
    "Medium in the component"
    annotation(choices(
      choice(redeclare package Medium=Buildings.Media.Water "Water"),
      choice(redeclare package Medium=
        Buildings.Media.Antifreeze.PropyleneGlycolWater(property_T=293.15, X_a=0.40)
        "Propylene glycol water, 40% mass fraction")));
  parameter Real C(final unit="kg/Pa", final min=0) = 1E-5
    "Hydraulic capacitance dm/dp";
  parameter Modelica.Fluid.Types.Dynamics massDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of mass balance: dynamic (3 initialization options) or steady state"
    annotation(Evaluate=true,
      Dialog(tab="Dynamics",
        group="Conservation equations"));
  parameter Medium.AbsolutePressure p_start = Medium.p_default
    "Start value of pressure"
    annotation(Dialog(tab="Initialization"));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium=Medium,
    p(start=p_start),
    h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid connector"
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}}),
      iconTransformation(extent={{-10,-110},{10,-90}})));
  Medium.AbsolutePressure p(start=p_start)
    "Pressure at the connected node";
initial equation
  if massDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
    p = p_start;
  elseif massDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
    der(p) = 0;
  end if;
equation
  port_a.p = p;
  if massDynamics == Modelica.Fluid.Types.Dynamics.SteadyState then
    port_a.m_flow = 0;
  else
    C * der(p) = port_a.m_flow;
  end if;
  // The stored mass is negligible: no energy or species storage.
  port_a.h_outflow = inStream(port_a.h_outflow);
  port_a.Xi_outflow = inStream(port_a.Xi_outflow);
  port_a.C_outflow = inStream(port_a.C_outflow);
  annotation(
    defaultComponentName="com",
    Icon(coordinateSystem(preserveAspectRatio=false),
      graphics={
        Rectangle(
          extent={{-60,80},{60,-60}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-60,10},{60,10}},
          color={0,0,0},
          pattern=LinePattern.Dash),
        Line(
          points={{0,-60},{0,-90}},
          color={0,127,255},
          thickness=1)}),
    Documentation(info="<html>
<p>
This model provides a pressure state to the node it is connected to,
with <i>C dp/dt = m&#775;</i>.
It is intended for nodes that may be isolated from any pressure boundary
condition by closed valves, in which case the node pressure would
otherwise be determined only by the leakage through those valves,
which yields an ill-conditioned system of equations.
</p>
<p>
The stored mass is negligible, so no energy or species balance is
implemented.
With <code>massDynamics=SteadyState</code> the component imposes zero
mass flow rate and has no effect.
</p>
</html>", revisions="<html>
<ul>
<li>
September 14, 2026, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end Compliance;
