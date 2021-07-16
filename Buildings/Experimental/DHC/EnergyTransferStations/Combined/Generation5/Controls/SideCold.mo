within Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls;
model SideCold
  "Control block for cold side"
  extends Modelica.Blocks.Icons.Block;
  parameter Integer nSouAmb=1
    "Number of ambient sources to control"
    annotation (Evaluate=true);
  parameter Modelica.SIunits.TemperatureDifference dT12Hex_nominal
    "Difference between primary and secondary entering temperature in cold rejection";
  parameter Modelica.SIunits.Temperature TChiWatSupSetMin(displayUnit="degC")
    "Minimum value of chilled water supply temperature set point";
  parameter Buildings.Controls.OBC.CDL.Types.SimpleController controllerType=
    Buildings.Controls.OBC.CDL.Types.SimpleController.PI
    "Type of controller"
    annotation (choices(choice=Buildings.Controls.OBC.CDL.Types.SimpleController.P,
    choice=Buildings.Controls.OBC.CDL.Types.SimpleController.PI));
  parameter Real k(
    min=0)=0.1
    "Gain of controller";
  parameter Modelica.SIunits.Time Ti(
    min=Buildings.Controls.OBC.CDL.Constants.small)=120
    "Time constant of integrator block"
    annotation (Dialog(enable=
    controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PI or
    controllerType == Buildings.Controls.OBC.CDL.Types.SimpleController.PID));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput uCol
    "Cold rejection control signal"
    annotation (Placement(transformation(extent={{-220,-20},{-180,20}}),
    iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput TChiWatSupSet(
    final unit="K",
    displayUnit="degC")
    "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{180,60},{220,100}}),
    iconTransformation(extent={{100,-60},{140,-20}})));
  Buildings.Controls.OBC.CDL.Continuous.Line mapFun[nSouAmb]
    "Mapping functions for ambient source control"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant x1[nSouAmb](
    final k={(i-1) for i in 1:nSouAmb})
    "x1"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));
  Buildings.Controls.OBC.CDL.Routing.RealReplicator rep(
    final nout=nSouAmb)
    "Replicate control signal"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,origin={-20,0})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant f1[nSouAmb](
    each final k=0)
    "f1"
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant f2[nSouAmb](
    each final k=1)
    "f2"
    annotation (Placement(transformation(extent={{60,-50},{80,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant x2[nSouAmb](
    final k={(i) for i in 1:nSouAmb})
    "x2"
    annotation (Placement(transformation(extent={{0,-70},{20,-50}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant minTChiWatSup(
    y(final unit="K",
      displayUnit="degC"),
    final k=TChiWatSupSetMin)
    "Minimum value of chilled water supply temperature"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
  Buildings.Controls.OBC.CDL.Continuous.SlewRateLimiter ramLimHea(
    raisingSlewRate=0.1)
    "Limit the rate of change"
    annotation (Placement(transformation(extent={{140,70},{160,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHeaCoo
    "Enable signal for heating or cooling"
    annotation (Placement(transformation(extent={{-220,100},{-180,140}}),
    iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet(
    final unit="K",
    displayUnit="degC")
    "Supply temperature set point (heating or chilled water)"
    annotation (Placement(transformation(extent={{-220,20},{-180,60}}),
    iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T1HexWatEnt(final unit="K",
      displayUnit="degC") "Heat exchanger primary water entering temperature"
    annotation (Placement(transformation(extent={{-220,60},{-180,100}}),
        iconTransformation(extent={{-140,-62},{-100,-22}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yAmb[nSouAmb](
    each final unit="1")
    "Control signal for ambient sources"
    annotation (Placement(transformation(extent={{180,20},{220,60}}),
    iconTransformation(extent={{100,20},{140,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yValIso(
    final unit="1")
    "Ambient loop isolation valve control signal"
    annotation (Placement(transformation(extent={{180,-20},{220,20}}),
    iconTransformation(extent={{100,-20},{140,20}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    "Convert DO to AO signal"
    annotation (Placement(transformation(extent={{40,-110},{60,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold greThr(
    t=0.01)
    "Control signal is non zero (with 1% tolerance)"
    annotation (Placement(transformation(extent={{-140,-110},{-120,-90}})));
  Modelica.Blocks.Discrete.ZeroOrderHold zeroOrderHold(
    samplePeriod=60)
    annotation (Placement(transformation(extent={{80,-110},{100,-90}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter
                                            addPar(p=-dT12Hex_nominal, k=1)
    "Substract temperature difference for cold rejection"
    annotation (Placement(transformation(extent={{-140,70},{-120,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Max max2 "Max with CHWSTSP min"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Min min1 "Reset CHWST"
    annotation (Placement(transformation(extent={{-10,70},{10,90}})));
  LDRD.EnergyTransferStations.Combined.Generation5.Controls.PIDWithEnable
                conTChiWatSup(
    final k=k,
    final Ti=Ti,
    final controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    final yMin=0,
    final yMax=1,
    final reverseActing=false)
    "Controller for CHWST"
    annotation (Placement(transformation(extent={{-130,-30},{-110,-10}})));
  Buildings.Controls.OBC.CDL.Continuous.Min          min2
    "One minus control loop output"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TBot(final unit="K",
      displayUnit="degC")
    "Temperature at bottom of tank"
    annotation (Placement(transformation(extent={{-220,-60},{-180,-20}}),
    iconTransformation(extent={{-140,-104},{-100,-64}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addPar1(p=nSouAmb, k=-
        nSouAmb)
    "One minus control loop output"
    annotation (Placement(transformation(extent={{-100,-30},{-80,-10}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swi
    "Substract temperature difference for cold rejection"
    annotation (Placement(transformation(extent={{-60,50},{-40,70}})));
  Buildings.Controls.OBC.CDL.Continuous.GreaterThreshold
                                                       greThr1(t=0.5)
    "Convert DO to AO signal"
    annotation (Placement(transformation(extent={{-30,-90},{-50,-70}})));
equation
  connect(x1.y,mapFun.x1)
    annotation (Line(points={{22,20},{36,20},{36,8},{98,8}},color={0,0,127}));
  connect(rep.y,mapFun.u)
    annotation (Line(points={{-8,0},{98,0}},color={0,0,127}));
  connect(f1.y,mapFun.f1)
    annotation (Line(points={{22,-20},{36,-20},{36,4},{98,4}},color={0,0,127}));
  connect(f2.y,mapFun.f2)
    annotation (Line(points={{82,-40},{90,-40},{90,-8},{98,-8}},color={0,0,127}));
  connect(x2.y,mapFun.x2)
    annotation (Line(points={{22,-60},{40,-60},{40,-4},{98,-4}},color={0,0,127}));
  connect(mapFun.y,yAmb)
    annotation (Line(points={{122,0},{140,0},{140,40},{200,40}},color={0,0,127}));
  connect(ramLimHea.y,TChiWatSupSet)
    annotation (Line(points={{162,80},{200,80}},color={0,0,127}));
  connect(uCol,greThr.u)
    annotation (Line(points={{-200,0},{-170,0},{-170,-100},{-142,-100}},
                                                                      color={0,0,127}));
  connect(greThr.y,booToRea.u)
    annotation (Line(points={{-118,-100},{38,-100}},
                                                  color={255,0,255}));
  connect(booToRea.y,zeroOrderHold.u)
    annotation (Line(points={{62,-100},{78,-100}},color={0,0,127}));
  connect(zeroOrderHold.y,yValIso)
    annotation (Line(points={{101,-100},{160,-100},{160,0},{200,0}},color={0,0,127}));
  connect(T1HexWatEnt, addPar.u)
    annotation (Line(points={{-200,80},{-142,80}}, color={0,0,127}));
  connect(minTChiWatSup.y, max2.u2) annotation (Line(points={{82,60},{90,60},{
          90,74},{98,74}}, color={0,0,127}));
  connect(min1.y, max2.u1) annotation (Line(points={{12,80},{80,80},{80,86},{98,
          86}}, color={0,0,127}));
  connect(max2.y, ramLimHea.u) annotation (Line(points={{122,80},{132,80},{132,
          80},{138,80}}, color={0,0,127}));
  connect(TSet, conTChiWatSup.u_s) annotation (Line(points={{-200,40},{-150,40},
          {-150,-20},{-132,-20}}, color={0,0,127}));
  connect(TBot, conTChiWatSup.u_m) annotation (Line(points={{-200,-40},{-120,
          -40},{-120,-32}}, color={0,0,127}));
  connect(uHeaCoo, conTChiWatSup.uEna) annotation (Line(points={{-200,120},{
          -160,120},{-160,-36},{-124,-36},{-124,-32}}, color={255,0,255}));
  connect(TSet, min1.u2) annotation (Line(points={{-200,40},{-20,40},{-20,74},{
          -12,74}}, color={0,0,127}));
  connect(uCol, min2.u1) annotation (Line(points={{-200,0},{-80,0},{-80,6},{-62,
          6}}, color={0,0,127}));
  connect(min2.y, rep.u)
    annotation (Line(points={{-38,0},{-32,0}}, color={0,0,127}));
  connect(conTChiWatSup.y, addPar1.u) annotation (Line(points={{-108,-20},{-104,
          -20},{-104,-20},{-102,-20}}, color={0,0,127}));
  connect(addPar1.y, min2.u2) annotation (Line(points={{-78,-20},{-72,-20},{-72,
          -6},{-62,-6}}, color={0,0,127}));
  connect(addPar.y, swi.u1) annotation (Line(points={{-118,80},{-80,80},{-80,68},
          {-62,68}}, color={0,0,127}));
  connect(TSet, swi.u3) annotation (Line(points={{-200,40},{-80,40},{-80,52},{
          -62,52}}, color={0,0,127}));
  connect(zeroOrderHold.y, greThr1.u) annotation (Line(points={{101,-100},{120,
          -100},{120,-80},{-28,-80}}, color={0,0,127}));
  connect(greThr1.y, swi.u2) annotation (Line(points={{-52,-80},{-66,-80},{-66,
          60},{-62,60}}, color={255,0,255}));
  connect(swi.y, min1.u1) annotation (Line(points={{-38,60},{-30,60},{-30,86},{
          -12,86}}, color={0,0,127}));
  annotation (
    defaultComponentName="conCol",
    Documentation(
      revisions="<html>
<ul>
<li>
July 31, 2020, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>",
      info="<html>
<p>
This block serves as the controller for the cold side of the ETS in
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.Supervisory\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.Supervisory</a>.
It computes the following control signals.
</p>
<ul>
<li>
Control signals for ambient sources <code>yAmb</code> (array)<br/>

The cold rejection control signal yielded by the hot side controller
is processed as follows.
<ul>
<li>
A controller is used to track the chilled water
supply temperature (CHWST) set point.
This controller is enabled when cooling is enabled.
It yields a control signal value between
<code>0</code> and <code>nSouAmb</code>.
</li>
<li>
The systems serving as ambient sources are then controlled in sequence
by mapping the minimum between the CHWST control loop output and the
part of the cold rejection signal between <code>0</code>
and <code>nSouAmb</code> to a <code>nSouAmb</code>-array
of signals between <code>0</code> and <code>1</code>.
</li>
</ul>
</li>
<li>
Chilled water supply temperature set point <code>TChiWatSupSet</code><br/>

The remaining part of the cold rejection signal between
<code>nSouAmb</code> and <code>nSouAmb+1</code> is used
to reset the CHWST set point between a maximum value provided
as an input variable, and a minimum value provided as a
parameter.
</li>
<li>
Control signal for the evaporator loop isolation valve <code>yIsoAmb</code><br/>

The valve is commanded to be fully open whenever the cold rejection control signal
is greater than zero.
The command signal is held for 60s to avoid short cycling.
</li>
</ul>
</html>"),
    Diagram(
      coordinateSystem(
        extent={{-180,-140},{180,140}})));
end SideCold;
