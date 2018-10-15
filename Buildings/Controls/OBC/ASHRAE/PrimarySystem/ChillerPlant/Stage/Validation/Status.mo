within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Stage.Validation;
model Status
  "Validates stage status for positive displacement chillers (screw, scroll)"

  parameter Modelica.SIunits.Temperature TChiWatSupSet = 285.15
  "Chilled water supply set temperature";

  parameter Modelica.SIunits.Temperature aveTChiWatRet = 288.15
  "Average measured chilled water return temperature";

  parameter Real aveVChiWat_flow(
    final quantity="VolumeFlowRate",
    final unit="m3/s") = 0.05
    "Average measured chilled water flow rate";

  CDL.Continuous.Sources.Constant TCWSupSet(k=TChiWatSupSet)
    "Chilled water supply temperature"
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  CDL.Continuous.Sources.Sine TChiWatRet(
    freqHz=1/300,
    amplitude=4,
    offset=aveTChiWatRet + 2)
                          "Chiller water return temeprature"
    annotation (Placement(transformation(extent={{-80,10},{-60,30}})));
  CDL.Continuous.Sources.Sine chiWatFlow(
    offset=aveVChiWat_flow/2,
    amplitude=0.03,
    freqHz=1/1200)          "Chilled water flow"
    annotation (Placement(transformation(extent={{-80,-40},{-60,-20}})));
  Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Stage.Status chiSta(
      minPlrSta1=10/310)
    "Determines chiller stage based on the current load and stage"
    annotation (Placement(transformation(extent={{40,0},{60,20}})));
equation

  connect(TCWSupSet.y, chiSta.TChiWatSupSet) annotation (Line(points={{-59,60},
          {0,60},{0,15},{39,15}}, color={0,0,127}));
  connect(TChiWatRet.y, chiSta.TChiWatRet) annotation (Line(points={{-59,20},{
          -10,20},{-10,11},{39,11}}, color={0,0,127}));
  connect(chiWatFlow.y, chiSta.VChiWat_flow) annotation (Line(points={{-59,-30},
          {0,-30},{0,3},{39,3}}, color={0,0,127}));
  connect(chiSta.yChiSta, chiSta.uChiSta) annotation (Line(points={{61,10},{70,
          10},{70,30},{30,30},{30,19},{39,19}}, color={255,127,0}));
annotation (
 experiment(StopTime=3600.0, Tolerance=1e-06),
  __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/Controls/OBC/ASHRAE/PrimarySystem/ChillerPlant/Stage/Validation/CapacityRequirement.mos"
    "Simulate and plot"),
  Documentation(info="<html>
<p>
This example validates
<a href=\"modelica://Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.TowerWaterLevel\">
Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.TowerWaterLevel</a>.
</p>
</html>", revisions="<html>
<ul>
<li>
October 13, by Milica Grahovac:<br/>
First implementation.
</li>
</ul>
</html>"),
Icon(graphics={
        Ellipse(lineColor = {75,138,73},
                fillColor={255,255,255},
                fillPattern = FillPattern.Solid,
                extent = {{-100,-100},{100,100}}),
        Polygon(lineColor = {0,0,255},
                fillColor = {75,138,73},
                pattern = LinePattern.None,
                fillPattern = FillPattern.Solid,
                points = {{-36,60},{64,0},{-36,-60},{-36,60}})}),Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end Status;