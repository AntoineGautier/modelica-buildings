within Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls;
model WatersideEconomizer "District heat exchanger controller"
  extends Modelica.Blocks.Icons.Block;
  parameter DHC.EnergyTransferStations.Types.ConnectionConfiguration conCon
    "District connection configuration"
    annotation (Evaluate=true);
  parameter Modelica.SIunits.PressureDifference dp1Hex_nominal(
    displayUnit="Pa")
    "Nominal pressure drop across heat exchanger on district side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dp2Hex_nominal(
    displayUnit="Pa")
    "Nominal pressure drop across heat exchanger on building side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dpVal2Hex_nominal(
    displayUnit="Pa")
    "Nominal pressure drop of heat exchanger bypass valve"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_a1Hex_nominal
    "Nominal water inlet temperature on district side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_b2Hex_nominal
    "Nominal water outlet temperature on building side"
    annotation (Dialog(group="Nominal condition"));
  parameter Real spePum1HexMin(
    final unit="1",
    min=0)=0.1
    "Heat exchanger primary pump minimum speed (fractional)"
    annotation (Dialog(group="Controls",enable=not have_val1Hex));
  parameter Real yVal1HexMin(
    final unit="1",
    min=0.01)=0.1
    "Minimum valve opening for temperature measurement (fractional)"
    annotation (Dialog(group="Controls",enable=have_val1Hex));
  parameter Modelica.SIunits.TemperatureDifference dTEna = 1
    "Minimum delta-T above predicted heat exchanger leaving water temperature to enable WSE"
    annotation (Dialog(group="Controls"));
  parameter Modelica.SIunits.TemperatureDifference dTDis = 0.5
    "Minimum delta-T across heat exchanger before disabling WSE"
    annotation (Dialog(group="Controls"));
  parameter Real k(
    min=0)=1
    "Gain of controller"
    annotation (Dialog(group="Controls"));
  parameter Modelica.SIunits.Time Ti(
    min=Buildings.Controls.OBC.CDL.Constants.small)=60
    "Time constant of integrator block"
    annotation (Dialog(group="Controls"));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T1HexWatEnt(
    final unit="K",
    displayUnit="degC") "Heat exchanger primary water entering temperature"
    annotation (Placement(transformation(extent={{-220,-60},{-180,-20}}),
      iconTransformation(extent={{-140,-30},{-100,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dp1(
    final unit="Pa", displayUnit="Pa")
    "Heat exchanger primary pressure drop"
    annotation (Placement(transformation(extent={{-220,80},{-180,120}}),
        iconTransformation(extent={{-140,30},{-100,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dp2(final unit="Pa", displayUnit="Pa")
    "Heat exchanger secondary pressure drop" annotation (Placement(transformation(extent={{-220,20},{-180,60}}),
        iconTransformation(extent={{-140,0},{-100,40}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T2HexWatLvg(
    final unit="K", displayUnit="degC")
    "Heat exchanger secondary water leaving temperature"
    annotation (Placement(transformation(extent={{-220,-180},{-180,-140}}),
                     iconTransformation(extent={{-140,-90},{-100,-50}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T2HexWatEnt(
    final unit="K", displayUnit="degC")
    "Heat exchanger secondary water entering temperature"
    annotation (Placement(transformation(extent={{-220,-140},{-180,-100}}),
                    iconTransformation(extent={{-140,-60},{-100,-20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput y1Hex(
    final unit="1")
    "Primary control signal (pump or valve)"
    annotation (Placement(transformation(extent={{180,20},{220,60}}),
      iconTransformation(extent={{100,30},{140,70}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput yVal2Hex(
    final unit="1")
    "Secondary valve control signal"
    annotation (Placement(transformation(extent={{180,-60},{220,-20}}),
      iconTransformation(extent={{100,-70},{140,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.AddParameter addDelTem(
    final p=1,
    final k=dTEna)
    "Add threshold for enabling WSE"
    annotation (Placement(transformation(extent={{-100,-50},{-80,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain ratNom2(
    final k=1/dp2Hex_nominal) "Compute ratio to nominal"
    annotation (Placement(transformation(extent={{-140,30},{-120,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain ratNom1(
    final k=1/dp1Hex_nominal) "Compute ratio to nominal"
    annotation (Placement(transformation(extent={{-140,90},{-120,110}})));
  PIDWithEnable conPI(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    final k=k,
    final Ti=Ti)
    "Controller for primary pump or valve"
    annotation (Placement(transformation(extent={{-66,90},{-46,110}})));
  Modelica.StateGraph.InitialStepWithSignal
                                  iniSta "Initial state "
    annotation (Placement(transformation(extent={{-30,30},{-10,50}})));
  Modelica.StateGraph.TransitionWithSignal ena "Enable WSE"
    annotation (Placement(transformation(extent={{10,30},{30,50}})));
  Modelica.StateGraph.StepWithSignal actSta "Active WSE"
    annotation (Placement(transformation(extent={{50,30},{70,50}})));
  Modelica.StateGraph.TransitionWithSignal ena1 "Enable WSE"
    annotation (Placement(transformation(extent={{90,30},{110,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
    annotation (Placement(transformation(extent={{-140,-150},{-120,-130}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis)
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-50,-150},{-30,-130}})));
  PredictLeavingTemperature calTemLvg(
    final dTApp_nominal=abs(T_a1Hex_nominal - T_b2Hex_nominal),
    final dpVal2Hex_nominal=dpVal2Hex_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-140,-50},{-120,-30}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1 "Compare to threshold for enabling WSE"
    annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=0, realFalse=1)
    "Convert to real signal (close bypass valve when WSE enabled)"
    annotation (Placement(transformation(extent={{140,-50},{160,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-10,70},{10,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant min1(final k=if have_val1Hex then yVal1HexMin else
        spePum1HexMin)
    "Minimum pump speed or actuator opening"
    annotation (Placement(transformation(extent={{-10,110},{10,130}})));
  Buildings.Controls.OBC.CDL.Continuous.Max max1
    "Maximum between control signal and minimum speed or opening"
    annotation (Placement(transformation(extent={{30,110},{50,130}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff1
    "Output zero if not enabled"
    annotation (Placement(transformation(extent={{100,90},{120,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0)
    "Zero"
    annotation (Placement(transformation(extent={{30,70},{50,90}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCoo
    "Cooling enable signal"
    annotation (Placement(transformation(extent={{-220,140},{-180,180}}),
    iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Logical.MultiAnd mulAnd(nu=3)
    "Enable if cooling enabled and temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-50},{10,-30}})));
  Buildings.Controls.OBC.CDL.Logical.Or or1 "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{-10,-150},{10,-130}})));
  Buildings.Controls.OBC.CDL.Logical.Not not2 "Cooling disabled"
    annotation (Placement(transformation(extent={{-50,-110},{-30,-90}})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim(t=1200) "True when WSE active for more than t" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={60,-90})));
  Buildings.Controls.OBC.CDL.Logical.Timer tim1(t=1200) "True when WSE inactive for more than t"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-20,0})));
  Buildings.Controls.OBC.CDL.Logical.And and2 "Cooling disabled or temperature criterion verified"
    annotation (Placement(transformation(extent={{70,-150},{90,-130}})));
protected
  parameter Boolean have_val1Hex=
    conCon == Buildings.Experimental.DHC.EnergyTransferStations.Types.ConnectionConfiguration.TwoWayValve
    "True in case of control valve on district side, false in case of a pump";
equation
  connect(dp2, ratNom2.u) annotation (Line(points={{-200,40},{-142,40}}, color={0,0,127}));
  connect(dp1, ratNom1.u) annotation (Line(points={{-200,100},{-142,100}}, color={0,0,127}));
  connect(ratNom2.y, conPI.u_s) annotation (Line(points={{-118,40},{-80,40},{-80,100},{-68,100}},    color={0,0,127}));
  connect(ratNom1.y, conPI.u_m)
    annotation (Line(points={{-118,100},{-100,100},{-100,80},{-56,80},{-56,88}},   color={0,0,127}));
  connect(T2HexWatEnt, delT1.u1)
    annotation (Line(points={{-200,-120},{-160,-120},{-160,-134},{-142,-134}},
                                                                           color={0,0,127}));
  connect(T2HexWatLvg, delT1.u2)
    annotation (Line(points={{-200,-160},{-152,-160},{-152,-146},{-142,-146}},
                                                                             color={0,0,127}));
  connect(delT1.y, delTemDis.u) annotation (Line(points={{-118,-140},{-52,-140}},color={0,0,127}));
  connect(T1HexWatEnt, calTemLvg.T1HexWatEnt)
    annotation (Line(points={{-200,-40},{-160,-40},{-160,-45},{-142,-45}},
                                                                     color={0,0,127}));
  connect(calTemLvg.T2HexWatLvg, addDelTem.u) annotation (Line(points={{-118,-40},{-102,-40}},
                                                                                           color={0,0,127}));
  connect(addDelTem.y, delTemDis1.u1) annotation (Line(points={{-78,-40},{-52,-40}},
                                                                                  color={0,0,127}));
  connect(T2HexWatEnt, delTemDis1.u2)
    annotation (Line(points={{-200,-120},{-60,-120},{-60,-48},{-52,-48}},
                                                                      color={0,0,127}));
  connect(iniSta.outPort[1], ena.inPort) annotation (Line(points={{-9.5,40},{16,40}},   color={0,0,0}));
  connect(ena.outPort, actSta.inPort[1]) annotation (Line(points={{21.5,40},{49,40}}, color={0,0,0}));
  connect(actSta.outPort[1], ena1.inPort) annotation (Line(points={{70.5,40},{96,40}}, color={0,0,0}));
  connect(ena1.outPort, iniSta.inPort[1])
    annotation (Line(points={{101.5,40},{120,40},{120,60},{-40,60},{-40,40},{-31,40}},
                                                                                    color={0,0,0}));
  connect(booToRea.y, yVal2Hex) annotation (Line(points={{162,-40},{200,-40}}, color={0,0,127}));
  connect(actSta.active, conPI.uEna) annotation (Line(points={{60,29},{60,20},{-60,20},{-60,88}},   color={255,0,255}));
  connect(conPI.y, max1.u2) annotation (Line(points={{-44,100},{20,100},{20,114},{28,114}}, color={0,0,127}));
  connect(min1.y, max1.u1) annotation (Line(points={{12,120},{20,120},{20,126},{28,126}},color={0,0,127}));
  connect(max1.y, swiOff1.u1) annotation (Line(points={{52,120},{90,120},{90,108},{98,108}}, color={0,0,127}));
  connect(swiOff1.y, y1Hex) annotation (Line(points={{122,100},{160,100},{160,40},{200,40}}, color={0,0,127}));
  connect(zer.y, swiOff1.u3) annotation (Line(points={{52,80},{90,80},{90,92},{98,92}}, color={0,0,127}));
  connect(uCoo, swiOff1.u2) annotation (Line(points={{-200,160},{80,160},{80,100},{98,100}}, color={255,0,255}));
  connect(mulAnd.y, ena.condition) annotation (Line(points={{12,-40},{20,-40},{20,28}}, color={255,0,255}));
  connect(delTemDis.y, or1.u2)
    annotation (Line(points={{-28,-140},{-24,-140},{-24,-148},{-12,-148}}, color={255,0,255}));
  connect(not2.y, or1.u1) annotation (Line(points={{-28,-100},{-20,-100},{-20,-140},{-12,-140}}, color={255,0,255}));
  connect(uCoo, not2.u) annotation (Line(points={{-200,160},{-170,160},{-170,-60},{-80,-60},{-80,-100},{-52,-100}},
                                                                                                color={255,0,255}));
  connect(actSta.active, booToRea.u) annotation (Line(points={{60,29},{60,-40},{138,-40}}, color={255,0,255}));
  connect(delTemDis1.y, mulAnd.u[1])
    annotation (Line(points={{-28,-40},{-12,-40},{-12,-35.3333}},                color={255,0,255}));
  connect(iniSta.active, tim1.u) annotation (Line(points={{-20,29},{-20,12}}, color={255,0,255}));
  connect(tim1.passed, mulAnd.u[2])
    annotation (Line(points={{-28,-12},{-28,-32},{-12,-32},{-12,-40}}, color={255,0,255}));
  connect(uCoo, mulAnd.u[3]) annotation (Line(points={{-200,160},{-170,160},{-170,-60},{-20,-60},{-20,-44},{-12,-44},{
          -12,-44.6667}}, color={255,0,255}));
  connect(actSta.active, tim.u) annotation (Line(points={{60,29},{60,-78}}, color={255,0,255}));
  connect(tim.passed, and2.u1) annotation (Line(points={{52,-102},{52,-140},{68,-140}}, color={255,0,255}));
  connect(or1.y, and2.u2) annotation (Line(points={{12,-140},{40,-140},{40,-148},{68,-148}}, color={255,0,255}));
  connect(and2.y, ena1.condition) annotation (Line(points={{92,-140},{100,-140},{100,28}}, color={255,0,255}));
  connect(dp2, calTemLvg.dp2) annotation (Line(points={{-200,40},{-160,40},{-160,-35},{-142,-35}}, color={0,0,127}));
  annotation (
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-180,-180},{180,180}})),
    defaultComponentName="conWSE",
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
This block implements the control logic for the waterside economizer.
</p>
<p>
The system is enabled if
</p>
<ul>
<li>
it has been disabled for more than 20 minutes, and
</li>
<li>
the \"cooling enabled\" input signal is <code>true</code>, and
</li>
<li>
the predicted leaving water temperature is lower than the entering water
temperature minus <code></code>.
</li>
</ul>
<p>
The system is disabled if
</p>
<ul>
<li>
it has been enabled for more than 20 minutes, and
</li>
<li>
the \"cooling enabled\" input signal is <code>false</code>, or
</li>
<li>
the leaving water temperature is higher than the entering water
temperature minus <code></code>.
</li>
</ul>
<p>
When the system is enabled
</p>
<ul>
<li>
the primary side is controlled so that the primary flow rate 
roughly matches the secondary flow rate: the pressure drop across
the heat exchanger is used to approximate the flow rate on each 
side,
</li>
<li>
the bypass valve on the secondary side is fully closed.
</li>
</ul>
<p>
When the system is disabled
</p>
<ul>
<li>
if the \"cooling enabled\" input signal is <code>true</code>,
the primary pump (resp. valve) is operated at its minimums speed 
(resp. opening), otherwise it is switched off (resp. fully closed): 
this is needed to yield a representative measurement of the 
service water entering temperature,
</li>
<li>
the bypass valve on the secondary side is fully open.
</li>
</ul>
</html>"));
end WatersideEconomizer;
