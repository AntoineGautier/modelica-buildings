within Buildings.Experimental.OpenBuildingControl.CDL.Discrete.Examples;
model Sampler "Example model for the Sampler block"
  extends Modelica.Icons.Example;

  Buildings.Experimental.OpenBuildingControl.CDL.Discrete.Sampler sampler1(
    samplePeriod = 0.2)
    "Ideal sampler of a continuous signal"
    annotation (Placement(transformation(extent={{30,-10},{50,10}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Ramp ramp1(
    duration=1,
    offset=0,
    height=6.2831852) "Block that generates ramp signal"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));

  Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Sin sin1
    "Block that outputs the sine of the input"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));

equation
  connect(ramp1.y, sin1.u)
    annotation (Line(points={{-39,0},{-12,0},{-12,0}}, color={0,0,127}));
  connect(sin1.y, sampler1.u)
    annotation (Line(points={{11,0},{20,0},{28,0}}, color={0,0,127}));
  annotation (
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/Discrete/Examples/Sampler.mos"
        "Simulate and plot"),
    Documentation(
    info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.CDL.Discrete.Sampler\">
Buildings.Experimental.OpenBuildingControl.CDL.Discrete.Sampler</a>.
</p>
</html>",
revisions="<html>
<ul>
<li>
March 31, 2017 by Jianjun Hu:<br/>
First implementation.
</li>
</ul>
</html>"));
end Sampler;
