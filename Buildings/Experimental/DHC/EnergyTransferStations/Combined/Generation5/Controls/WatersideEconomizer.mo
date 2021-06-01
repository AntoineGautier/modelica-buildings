within Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls;
model WatersideEconomizer "District heat exchanger controller"
  extends Modelica.Blocks.Icons.Block;
  parameter Buildings.Experimental.DHC.EnergyTransferStations.Types.ConnectionConfiguration conCon
    "District connection configuration"
    annotation (Evaluate=true);
  parameter Real spePum1HexMin(
    final unit="1",
    min=0)=0.1
    "Heat exchanger primary pump minimum speed (fractional)"
    annotation (Dialog(enable=not have_val1Hex));
  parameter Modelica.SIunits.PressureDifference dp1Hex_nominal(
    displayUnit="Pa")
    "Nominal pressure drop across heat exchanger on district side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dp2Hex_nominal(
    displayUnit="Pa")
    "Nominal pressure drop across heat exchanger on building side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_a1Hex_nominal
    "Nominal water inlet temperature on district side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Temperature T_b2Hex_nominal
    "Nominal water outlet temperature on building side"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.TemperatureDifference dTEna = 1
    "Minimum delta-T above predicted heat exchanger leaving water temperature to enable WSE";
  parameter Modelica.SIunits.TemperatureDifference dTDis = 0.5
    "Minimum delta-T across heat exchanger before disabling WSE";
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T1HexWatEnt(
    final unit="K",
    displayUnit="degC")
    "Heat exchanger primary water entering temperature"
    annotation (Placement(transformation(extent={{-220,-20},{-180,20}}),
      iconTransformation(extent={{-140,-20},{-100,20}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dp1(
    final unit="Pa", displayUnit="Pa")
    "Heat exchanger primary pressure drop"
    annotation (Placement(transformation(extent={{-220,100},{-180,140}}),
        iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput dp2(
    final unit="Pa", displayUnit="Pa")
    "Heat exchanger secondary pressure drop"
    annotation (Placement(transformation(extent={{-220,40},{-180,80}}),
        iconTransformation(extent={{-140,20},{-100,60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T2HexWatLvg(
    final unit="K", displayUnit="degC")
    "Heat exchanger secondary water leaving temperature"
    annotation (Placement(transformation(extent={{-220,-140},{-180,-100}}),
                     iconTransformation(extent={{-140,-100},{-100,-60}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput T2HexWatEnt(
    final unit="K", displayUnit="degC")
    "Heat exchanger secondary water entering temperature"
    annotation (Placement(transformation(extent={{-220,-80},{-180,-40}}),
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
    annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain ratNom2(
    final k=1/dp2Hex_nominal) "Compute ratio to nominal"
    annotation (Placement(transformation(extent={{-140,70},{-120,90}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain ratNom1(
    final k=1/dp1Hex_nominal) "Compute ratio to nominal"
    annotation (Placement(transformation(extent={{-140,110},{-120,130}})));
  PIDWithEnable conPI(controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI)
    "Controller for primary pump or valve"
    annotation (Placement(transformation(extent={{-66,90},{-46,110}})));
  Modelica.StateGraph.InitialStep iniSta "Initial state "
    annotation (Placement(transformation(extent={{-20,30},{0,50}})));
  Modelica.StateGraph.TransitionWithSignal ena "Enable WSE"
    annotation (Placement(transformation(extent={{10,30},{30,50}})));
  Modelica.StateGraph.StepWithSignal actSta "Active WSE"
    annotation (Placement(transformation(extent={{50,30},{70,50}})));
  Modelica.StateGraph.TransitionWithSignal ena1 "Enable WSE"
    annotation (Placement(transformation(extent={{90,30},{110,50}})));
  Buildings.Controls.OBC.CDL.Continuous.Add delT1(k2=-1) "Add delta-T"
    annotation (Placement(transformation(extent={{-140,-90},{-120,-70}})));
  Buildings.Controls.OBC.CDL.Continuous.LessThreshold delTemDis(t=dTDis) "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-20,-90},{0,-70}})));
  PredictLeavingTemperature calTemLvg(
    final dTApp_nominal=abs(T_a1Hex_nominal - T_b2Hex_nominal),
    final dp2Hex_nominal=dp2Hex_nominal)
    "Compute predicted leaving water temperature"
    annotation (Placement(transformation(extent={{-140,-10},{-120,10}})));
  Buildings.Controls.OBC.CDL.Continuous.Less delTemDis1
    "Compare to threshold for disabling WSE"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    "Convert to real signal"
    annotation (Placement(transformation(extent={{140,-50},{160,-30}})));
  inner Modelica.StateGraph.StateGraphRoot stateGraphRoot "Root of state graph"
    annotation (Placement(transformation(extent={{-100,40},{-80,60}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant min1(final k=if have_val1Hex then 0 else spePum1HexMin)
    "Minimum pump speed or actuator opening"
    annotation (Placement(transformation(extent={{-20,130},{0,150}})));
  Buildings.Controls.OBC.CDL.Continuous.Max max1
    "Maximum between control signal and minimum speed or opening"
    annotation (Placement(transformation(extent={{30,110},{50,130}})));
  Buildings.Controls.OBC.CDL.Logical.Switch swiOff1
    "Output zero if not enabled"
    annotation (Placement(transformation(extent={{100,90},{120,110}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant zer(final k=0)
    "Zero"
    annotation (Placement(transformation(extent={{30,70},{50,90}})));
protected
  parameter Boolean have_val1Hex=
    conCon == Buildings.Experimental.DHC.EnergyTransferStations.Types.ConnectionConfiguration.TwoWayValve
    "True in case of control valve on district side, false in case of a pump";
equation
  connect(dp2, ratNom2.u) annotation (Line(points={{-200,60},{-160,60},{-160,80},{-142,80}},
    color={0,0,127}));
  connect(dp1, ratNom1.u) annotation (Line(points={{-200,120},{-142,120}}, color={0,0,127}));
  connect(ratNom2.y, conPI.u_s) annotation (Line(points={{-118,80},{-100,80},{-100,100},{-68,100}},  color={0,0,127}));
  connect(ratNom1.y, conPI.u_m)
    annotation (Line(points={{-118,120},{-80,120},{-80,80},{-56,80},{-56,88}},     color={0,0,127}));
  connect(T2HexWatEnt, delT1.u1)
    annotation (Line(points={{-200,-60},{-160,-60},{-160,-74},{-142,-74}}, color={0,0,127}));
  connect(T2HexWatLvg, delT1.u2)
    annotation (Line(points={{-200,-120},{-160,-120},{-160,-86},{-142,-86}}, color={0,0,127}));
  connect(delT1.y, delTemDis.u) annotation (Line(points={{-118,-80},{-22,-80}},  color={0,0,127}));
  connect(delTemDis.y, ena1.condition) annotation (Line(points={{2,-80},{100,-80},{100,28}},  color={255,0,255}));
  connect(dp2, calTemLvg.dp2) annotation (Line(points={{-200,60},{-160,60},{-160,5},{-142,5}}, color={0,0,127}));
  connect(T1HexWatEnt, calTemLvg.T1HexWatEnt)
    annotation (Line(points={{-200,0},{-160,0},{-160,-5},{-142,-5}}, color={0,0,127}));
  connect(calTemLvg.T2HexWatLvg, addDelTem.u) annotation (Line(points={{-118,0},{-102,0}}, color={0,0,127}));
  connect(addDelTem.y, delTemDis1.u1) annotation (Line(points={{-78,0},{-22,0}},  color={0,0,127}));
  connect(T2HexWatEnt, delTemDis1.u2)
    annotation (Line(points={{-200,-60},{-40,-60},{-40,-8},{-22,-8}}, color={0,0,127}));
  connect(delTemDis1.y, ena.condition) annotation (Line(points={{2,0},{20,0},{20,28}},     color={255,0,255}));
  connect(iniSta.outPort[1], ena.inPort) annotation (Line(points={{0.5,40},{16,40}},    color={0,0,0}));
  connect(ena.outPort, actSta.inPort[1]) annotation (Line(points={{21.5,40},{49,40}}, color={0,0,0}));
  connect(actSta.outPort[1], ena1.inPort) annotation (Line(points={{70.5,40},{96,40}}, color={0,0,0}));
  connect(ena1.outPort, iniSta.inPort[1])
    annotation (Line(points={{101.5,40},{120,40},{120,60},{-40,60},{-40,40},{-21,40}},
                                                                                    color={0,0,0}));
  connect(actSta.active, booToRea.u) annotation (Line(points={{60,29},{60,20},{120,20},{120,-40},{138,-40}},
                                                                                           color={255,0,255}));
  connect(booToRea.y, yVal2Hex) annotation (Line(points={{162,-40},{200,-40}}, color={0,0,127}));
  connect(actSta.active, conPI.uEna) annotation (Line(points={{60,29},{60,20},{-60,20},{-60,88}},   color={255,0,255}));
  connect(conPI.y, max1.u2) annotation (Line(points={{-44,100},{20,100},{20,114},{28,114}}, color={0,0,127}));
  connect(min1.y, max1.u1) annotation (Line(points={{2,140},{20,140},{20,126},{28,126}}, color={0,0,127}));
  connect(max1.y, swiOff1.u1) annotation (Line(points={{52,120},{90,120},{90,108},{98,108}}, color={0,0,127}));
  connect(swiOff1.y, y1Hex) annotation (Line(points={{122,100},{160,100},{160,40},{200,40}}, color={0,0,127}));
  connect(actSta.active, swiOff1.u2)
    annotation (Line(points={{60,29},{60,20},{80,20},{80,100},{98,100}}, color={255,0,255}));
  connect(zer.y, swiOff1.u3) annotation (Line(points={{52,80},{90,80},{90,92},{98,92}}, color={0,0,127}));
  annotation (
    Diagram(
      coordinateSystem(
        preserveAspectRatio=false,
        extent={{-180,-160},{180,160}})),
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
This block implements the control logic for the district heat exchanger,
which realizes the interface between the building system and the district system.
</p>
<p>
The input signal <code>u</code> is yielded by the supervisory controller, see
<a href=\"modelica://Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.Supervisory\">
Buildings.Experimental.DHC.EnergyTransferStations.Combined.Generation5.Controls.Supervisory</a>.
The primary and secondary circuits are enabled to operate if this input signal
is greater than zero and the return position of at least one isolation valve
is greater than 90%.
When enabled,
</p>
<ul>
<li>
the secondary circuit is controlled based on the input signal <code>u</code>,
which is mapped to modulate in sequence the mixing valve
(from full bypass to closed bypass for a control signal varying between
0% and 30%) and the pump speed (from the minimum to the maximum value
for a control signal varying between 30% and 100%),
</li>
<li>
the primary pump speed (or valve opening) is modulated with
a PI loop controlling the temperature difference across the primary side
of the heat exchanger.
A set point (and gain) scheduling logic is implemented to allow changing the
control parameters based on the active rejection mode (heat or cold rejection)
of the ETS.
</li>
</ul>
<p>
Note that the valve on the secondary side is needed to stabilize the control
of the system when the secondary mass flow rate required to meet the heat or
cold rejection demand is below the flow rate corresponding to the minimum pump speed.
</p>
</html>"));
end WatersideEconomizer;
