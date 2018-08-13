model To_inH2O "Test pressure unit conversion from inch of water gauge (at 60 degF) to pascal"
  import Buildings.Controls.OBC.CDL.Conversions.UnitConverters;
  extends Modelica.Icons.Example;

  Buildings.Controls.OBC.CDL.Continuous.Add add(k2=-1)
    "Difference between the calculated and expected conversion output"
    annotation (Placement(transformation(extent={{20,40},{40,60}})));
  Buildings.Controls.OBC.CDL.Continuous.Add add1(k2=-1)
    "Difference between the calculated and expected conversion output"
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));

protected
  parameter Real kin = 25. "Validation input";
  parameter Real kin1 = 100000. "Validation input 1";
  parameter Real kout = 25./248.84 "Validation output";
  parameter Real kout1 = 100000./248.84 "Validation output 1";

  Buildings.Controls.OBC.CDL.Conversions.UnitConverters.To_inH2O To_inH2O
  "Unit converter from inch of water gauge (at 60 degF) to pascal "
    annotation (Placement(transformation(extent={{-20,40},{0,60}})));
  Buildings.Controls.OBC.CDL.Conversions.UnitConverters.To_inH2O To_inH2O1
  "Unit converter from inch of water gauge (at 60 degF) to pascal "
    annotation (Placement(transformation(extent={{-20,-40},{0,-20}})));

  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant value(
    final k=kin)
    "Value to convert"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant value1(
    final k=kin1)
    "Value to convert"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant result(
    final k=kout)
    "Expected converted value"
    annotation (Placement(transformation(extent={{-20,10},{0,30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant result1(
    final k=kout1)
    "Expected converted value"
    annotation (Placement(transformation(extent={{-20,-70},{0,-50}})));

equation
  connect(result.y, add.u2)
    annotation (Line(points={{1,20},{10,20},{10,44},{18,44}}, color={0,0,127}));
  connect(result1.y, add1.u2)
    annotation (Line(points={{1,-60},{10,-60},{10,-36},{18,-36}}, color={0,0,127}));
  connect(value1.y,To_inH2O1.u)
    annotation (Line(points={{-39,-30},{-22,-30}}, color={0,0,127}));
  connect(To_inH2O1.y, add1.u1)
    annotation (Line(points={{1,-30},{8,-30},{8,-24},{18,-24}}, color={0,0,127}));
  connect(To_inH2O.y, add.u1)
    annotation (Line(points={{1,50},{10,50},{10,56},{18,56}}, color={0,0,127}));
  connect(value.y,To_inH2O.u)
    annotation (Line(points={{-39,50}, {-22,50}}, color={0,0,127}));
  annotation (Icon(graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent = {{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points = {{-36,60},{64,0},{-36,-60},{-36,60}})}),
                Diagram(coordinateSystem( preserveAspectRatio=false)),
            experiment(StopTime=10.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/CDL/Conversions/UnitConverters/Validation/To_inH2O.mos"
    "Simulate and plot"),
    Documentation(
    info="<html>
<p>
This model validates pressure unit conversion from inch of water gauge (at 60 degF) to pascal.
</p>
</html>",
revisions="<html>
<ul>
<li>
July 05, Milica Grahovac<br/>
First implementation.
</li>
</ul>
</html>"));
end To_inH2O;
