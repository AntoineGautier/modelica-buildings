within Buildings.Experimental.OpenBuildingControl.CDL.Integers.Validation;
model OnCounter "Validation model for the OnCounter block"
extends Modelica.Icons.Example;

  Buildings.Experimental.OpenBuildingControl.CDL.Integers.OnCounter onCounter1
    "Block that outputs increment if the input switches to true"
    annotation (Placement(transformation(extent={{16,-10},{36,10}})));

  Buildings.Experimental.OpenBuildingControl.CDL.Sources.DutyCycle dutyCyc1(
    CycleOn = true,
    period = 0.1)
    "Block that output cyclc on and off"
    annotation (Placement(transformation(extent={{-26,-10},{-6,10}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Constant cons1(k=50) "Constant as source term"
    annotation (Placement(transformation(extent={{-72,-10},{-52,10}})));

  Buildings.Experimental.OpenBuildingControl.CDL.Sources.DutyCycle reset(
    CycleOn = true,
    period = 1.0)
    "Block that output cyclc on and off"
    annotation (Placement(transformation(extent={{-26,-50},{-6,-30}})));
  Buildings.Experimental.OpenBuildingControl.CDL.Continuous.Constant cons2(k=50) "Constant as source term"
    annotation (Placement(transformation(extent={{-72,-50},{-52,-30}})));

equation
  connect(cons2.y, reset.u) annotation (Line(points={{-51,-40},{-39.5,-40},{-28,
          -40}}, color={0,0,127}));
  connect(reset.y, onCounter1.reset) annotation (Line(points={{-5,-40},{10,-40},
          {10,-12},{26,-12}}, color={255,0,255}));
  connect(cons1.y, dutyCyc1.u)
    annotation (Line(points={{-51,0},{-28,0}}, color={0,0,127}));
  connect(dutyCyc1.y, onCounter1.trigger)
    annotation (Line(points={{-5,0},{4,0},{14,0}}, color={255,0,255}));
  annotation (
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Experimental/OpenBuildingControl/CDL/Integers/Validation/OnCounter.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
Validation test for the block
<a href=\"modelica://Buildings.Experimental.OpenBuildingControl.CDL.Integers.OnCounter\">
Buildings.Experimental.OpenBuildingControl.CDL.Integers.OnCounter</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
April 1, 2017, by Jianjun Hu:<br/>
First implementation.
</li>
</ul>

</html>"));
end OnCounter;
