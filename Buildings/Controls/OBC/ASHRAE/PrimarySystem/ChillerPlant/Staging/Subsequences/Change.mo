within Buildings.Controls.OBC.ASHRAE.PrimarySystem.ChillerPlant.Staging.Subsequences;
block Change "Calculates the chiller stage signal"

  parameter Integer numSta = 2
  "Number of stages";

  parameter Modelica.SIunits.Time delayStaCha = 15*60
  "Minimum chiller load time below or above current stage before a change is enabled";

  Buildings.Controls.OBC.CDL.Interfaces.IntegerInput uChiSta "Chiller stage"
    annotation (Placement(transformation(extent={{-220,160},{-180,200}}),
        iconTransformation(extent={{-120,90},{-100,110}})));

  Buildings.Controls.OBC.CDL.Interfaces.IntegerOutput y(
    final max=1,
    final min=-1)
    "fixme change to chiller stage and loop back as input to up and down seq"
    annotation (Placement(transformation(extent=
    {{180,-10},{200,10}}), iconTransformation(extent={{100,-10},{120,10}})));

  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt
    "Boolean to integer conversion"
    annotation (Placement(transformation(extent={{110,0},{130,20}})));

  Buildings.Controls.OBC.CDL.Conversions.BooleanToInteger booToInt1
    "Boolean to integer conversion"
    annotation (Placement(transformation(extent={{110,-40},{130,-20}})));

  Buildings.Controls.OBC.CDL.Integers.Add addInt(
    final k2=-1)
    "Adder"
    annotation (Placement(transformation(extent={{150,-10},{170,10}})));

  CDL.Logical.Or  andStaDow "And for staging down"
    annotation (Placement(transformation(extent={{80,-40},{100,-20}})));
  CDL.Logical.Or3  andStaUp
                           "And for staging up"
    annotation (Placement(transformation(extent={{80,0},{100,20}})));

  CDL.Interfaces.RealInput uOplrUp(final unit="1")
    "Operating part load ratio of the next higher stage"
    annotation (Placement(transformation(extent={{-220,-90},{-180,-50}}),
        iconTransformation(extent={{-120,70},{-100,90}})));
  CDL.Interfaces.RealInput uOplrUpMin(final unit="1")
    "Minimum operating part load ratio at the next stage up"
    annotation (Placement(transformation(extent={{-220,-130},{-180,-90}}),
        iconTransformation(extent={{-120,30},{-100,50}})));
  CDL.Interfaces.RealInput dpChiWatPumSet(final unit="Pa", final quantity="PressureDifference")
    "Chilled water pump differential static pressure setpoint"
    annotation (Placement(transformation(extent={{-220,-260},{-180,-220}}),
      iconTransformation(extent={{-120,-80},{-100,-60}})));
  CDL.Interfaces.RealInput dpChiWatPum(final unit="Pa", final quantity="PressureDifference")
    "Chilled water pump differential static pressure"
    annotation (Placement(
    transformation(extent={{-220,-300},{-180,-260}}), iconTransformation(
     extent={{-120,-100},{-100,-80}})));
  CDL.Interfaces.RealInput TChiWatSupSet(final unit="K", final quantity="ThermodynamicTemperature")
    "Chilled water supply temperature setpoint"
    annotation (Placement(transformation(extent={{-220,-180},{-180,-140}}),
    iconTransformation(extent={{-120,-20},{-100,0}})));
  CDL.Interfaces.RealInput TChiWatSup(final unit="K", final quantity="ThermodynamicTemperature")
    "Chilled water return temperature"
    annotation (Placement(transformation(
      extent={{-220,-220},{-180,-180}}), iconTransformation(extent={{-120,-40},{
            -100,-20}})));
  CDL.Interfaces.RealInput uOplr(final unit="1")
    "Operating part load ratio of the current stage" annotation (Placement(
        transformation(extent={{-220,120},{-180,160}}),iconTransformation(
          extent={{-120,70},{-100,90}})));
  CDL.Interfaces.RealInput uSplrUp(final unit="1")
    "Staging part load ratio of the next stage up" annotation (Placement(
        transformation(extent={{-220,90},{-180,130}}),iconTransformation(extent=
           {{-120,70},{-100,90}})));
  CDL.Interfaces.RealInput uOplrDow(final unit="1")
    "Operating part load ratio of the next stage down" annotation (Placement(
        transformation(extent={{-220,0},{-180,40}}),  iconTransformation(extent=
           {{-120,70},{-100,90}})));
  CDL.Interfaces.RealInput uSplrDow(final unit="1")
    "Staging part load ratio of the next stage down"
                                                   annotation (Placement(
        transformation(extent={{-220,-40},{-180,0}}), iconTransformation(extent=
           {{-120,70},{-100,90}})));
  CDL.Interfaces.RealInput uOplrMin(final unit="1")
    "Minimum operating part load ratio at the current stage" annotation (
      Placement(transformation(extent={{-220,60},{-180,100}}),
        iconTransformation(extent={{-120,30},{-100,50}})));
  Up staUp annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
  CDL.Integers.GreaterThreshold intGreThr "Switches staging up rules"
    annotation (Placement(transformation(extent={{-40,-120},{-20,-100}})));
  Down staDown annotation (Placement(transformation(extent={{-40,0},{-20,20}})));
equation
  connect(booToInt.y, addInt.u1) annotation (Line(points={{131,10},{134,10},{134,
          6},{148,6}}, color={255,127,0}));
  connect(booToInt1.y, addInt.u2) annotation (Line(points={{131,-30},{134,-30},{
          134,-6},{148,-6}}, color={255,127,0}));
  connect(addInt.y, y)
    annotation (Line(points={{171,0},{190,0}}, color={255,127,0}));
  connect(booToInt.u, andStaUp.y)
    annotation (Line(points={{108,10},{101,10}}, color={255,0,255}));
  connect(booToInt1.u, andStaDow.y)
    annotation (Line(points={{108,-30},{101,-30}}, color={255,0,255}));
  annotation (defaultComponentName = "staChaPosDis",
        Icon(graphics={
        Rectangle(
        extent={{-100,-100},{100,100}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-120,146},{100,108}},
          lineColor={0,0,255},
          textString="%name")}),          Diagram(
        coordinateSystem(preserveAspectRatio=false,
        extent={{-180,-280},{180,200}})),
Documentation(info="<html>
<p>
Outputs the chiller stage change signal

fixme: add a stage availability input signal, which will
remove the stage change delay if the stage is unavailable, to
allow for a change to the next available stage at the next instant.

add WSE enable at plant enable part (input, output, predicted temperature) and at staging down from 1.
</p>
</html>",
revisions="<html>
<ul>
<li>
January xx, 2019, by Milica Grahovac:<br/>
First implementation.
</li>
</ul>
</html>"));
end Change;
