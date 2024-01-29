within Buildings.Fluid.HeatPumps.BaseClasses;
model AirToWaterHeatPumpModular
  "Model of AWHP"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface(
    final m_flow_nominal(
      final min=Modelica.Constants.small)=mHeaWat_flow_nominal);
  replaceable package MediumAir=Buildings.Media.Air
    "Air medium";
  parameter Modelica.Units.SI.HeatFlowRate capHea_nominal(
    final min=0)
    "Heat pump heating capacity"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature THeaWatSup_nominal
    "HW supply temperature setpoint"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.Units.SI.Temperature TOut_nominal
    "OAT temperature"
    annotation (Dialog(group="Nominal condition"));
  final parameter Modelica.Units.SI.MassFlowRate mHeaWat_flow_nominal(
    final min=0)=heaPum.mCon_flow_nominal
    "Design HW design mass flow rate"
    annotation (Dialog(group="Nominal condition"));
  final parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal(
    final min=0)=heaPum.mEva_flow_nominal
    "Air mass flow rate at design heating condit"
    annotation (Dialog(group="Nominal condition"));
  // Assumptions
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Evaluate=true,
    Dialog(tab="Dynamics",group="Conservation equations"));
  parameter Modelica.Units.SI.Time tau=30
    "Time constant of fluid volume for nominal HW flow, used if energy or mass balance is dynamic"
    annotation (Dialog(tab="Dynamics",group="Nominal condition",
      enable=energyDynamics<>Modelica.Fluid.Types.Dynamics.SteadyState));
  // Pump speed filter parameters
  parameter Boolean use_inputFilter=energyDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState
    "= true, if signal is filtered with a 2nd order CriticalDamping filter"
    annotation (Dialog(tab="Dynamics",group="Filtered pump speed"));
  parameter Modelica.Units.SI.Time riseTime=30
    "Rise time of the filter (time to reach 99.6 % of the speed)"
    annotation (Dialog(tab="Dynamics",group="Filtered pump speed",
      enable=use_inputFilter));
  parameter Modelica.Blocks.Types.Init init=Modelica.Blocks.Types.Init.InitialOutput
    "Type of initialization (no init/steady state/initial state/initial output)"
    annotation (Dialog(tab="Dynamics",group="Filtered pump speed",
      enable=use_inputFilter));
  parameter Real y_start=1
    "Initial position of actuator"
    annotation (Dialog(tab="Dynamics",group="Filtered pump speed",
      enable=use_inputFilter));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput y1
    "Heat pump On/Off command"
    annotation (Placement(transformation(extent={{-140,80},{-100,120}}),
      iconTransformation(extent={{-140,60},{-100,100}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TSet(
    final unit="K",
    displayUnit="degC")
    "Supply temperature setpoint"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
      iconTransformation(extent={{-140,-80},{-100,-40}})));
  BoundaryConditions.WeatherData.Bus weaBus
    "Bus with weather data"
    annotation (Placement(transformation(extent={{90,-50},{110,-30}}),
      iconTransformation(extent={{-20,80},{20,120}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput P(
    final unit="W")
    "Power drawn by heat pumps"
    annotation (Placement(transformation(extent={{100,80},{140,120}}),
      iconTransformation(extent={{100,60},{140,100}})));
  Buildings.Fluid.HeatPumps.ModularReversible.ReversibleAirToWaterTableData2D heaPum(
    redeclare final package MediumCon=Medium,
    redeclare final package MediumEva=MediumAir,
    final QHea_flow_nominal=capHea_nominal,
    final TCon_nominal=THeaWatSup_nominal,
    final TEva_nominal=TOut_nominal,
    final datTabHea=datTabHea,
    final datTabCoo=datTabCoo,
    final show_T=show_T,
    final energyDynamics=energyDynamics)
    "Heat pump"
    annotation (Placement(transformation(extent={{-10,-16},{10,4}})));
  Fluid.Sources.MassFlowSource_WeatherData airSou(
    redeclare final package Medium=MediumAir,
    final use_m_flow_in=true,
    final nPorts=1)
    "Air flow source"
    annotation (Placement(transformation(extent={{42,-50},{22,-30}})));
  Fluid.Sources.Boundary_pT airSin(
    redeclare final package Medium=MediumAir,
    final nPorts=1)
    "Air flow sink"
    annotation (Placement(transformation(extent={{-50,-50},{-30,-30}})));
  Buildings.Controls.OBC.CDL.Reals.MultiplyByParameter comFan(
    final k=mAir_flow_nominal)
    "Convert On/Off command to air flow setpoint"
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},rotation=-90,
      origin={46,30})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    "Convert to real"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=-90,
      origin={0,80})));
  Controls.OBC.CDL.Interfaces.BooleanInput yHea
    "Heating/cooling mode command (true=heating)"
    annotation (Placement(transformation(extent={{-140,20},{-100,60}}),
      iconTransformation(extent={{-140,20},{-100,60}})));
  Controls.OBC.CDL.Conversions.BooleanToInteger booToInt1
    "Convert to integer"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=0,
      origin={-70,80})));
  Sensors.SpecificEnthalpyTwoPort hConInl(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal)
    "Condenser inlet specific enthalpy"
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  Sensors.MassFlowRate mCon_flow(
    redeclare final package Medium=Medium)
    "Condenser mass flow rate"
    annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));
  Modelica.Blocks.Sources.RealExpression QReqHea_flow(
    y=max(0,(Buildings.Media.Water.enthalpyOfLiquid(TSet) - hConInl.h_out) * mCon_flow.m_flow))
    "HP heating load"
    annotation (Placement(transformation(extent={{-88,-90},{-68,-70}})));
  ModularReversible.RefrigerantCycle.TableData2D tableData2D(
    final useInHeaPum=true,
    final QHea_flow_nominal=heaPum.QHea_flow_nominal,
    final TCon_nominal=heaPum.TCon_nominal,
    final TEva_nominal=heaPum.TEva_nominal,
    final dTCon_nominal=heaPum.dTCon_nominal,
    final dTEva_nominal=heaPum.dTEva_nominal,
    final mCon_flow_nominal=heaPum.mCon_flow_nominal,
    final mEva_flow_nominal=heaPum.mEva_flow_nominal,
    final cpCon=heaPum.cpCon,
    final cpEva=heaPum.cpEva,
    final y_nominal=heaPum.y_nominal,
    final datTab=datTabHea)
    annotation (Placement(transformation(extent={{-26,-92},{-2,-68}})));
  Modelica.Blocks.Math.InverseBlockConstraints inverseBlockConstraints
    annotation (Placement(transformation(extent={{-40,-100},{8,-60}})));
  Sensors.TemperatureTwoPort TConOut(
    redeclare final package Medium=Medium,
    final m_flow_nominal=m_flow_nominal)
    "Condenser outlet temperature"
    annotation (Placement(transformation(extent={{64,-10},{84,10}})));
  Sensors.TemperatureTwoPort TEvaInl(
    redeclare final package Medium=MediumAir,
    final m_flow_nominal=mAir_flow_nominal)
    "Evaporator inlet temperature"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},rotation=90,
      origin={16,-28})));
  replaceable parameter ModularReversible.Data.TableData2D.GenericAirToWater datTabHea
    constrainedby ModularReversible.Data.TableData2D.GenericAirToWater
    "Performance data in heating mode"
    annotation (choicesAllMatching=true,
    Placement(transformation(extent={{-28,102},{-12,118}})));
  replaceable parameter Chillers.ModularReversible.Data.TableData2D.Generic datTabCoo
    constrainedby Chillers.ModularReversible.Data.TableData2D.Generic
    "Performance data in cooling mode"
    annotation (choicesAllMatching=true,
    Placement(transformation(extent={{4,102},{20,118}})));
protected
  ModularReversible.BaseClasses.RefrigerantMachineControlBus bus
    "HP control bus"
    annotation (Placement(transformation(extent={{40,-88},{80,-48}}),
      iconTransformation(extent={{-204,-92},{-164,-52}})));
equation
  connect(airSin.ports[1], heaPum.port_b2)
    annotation (Line(points={{-30,-40},{-20,-40},{-20,-12},{-10,-12}},color={0,127,255}));
  connect(comFan.y, airSou.m_flow_in)
    annotation (Line(points={{46,18},{46,-32},{42,-32}},color={0,0,127}));
  connect(weaBus, airSou.weaBus)
    annotation (Line(points={{100,-40},{42,-40},{42,-39.8}},color={255,204,51},thickness=0.5),
      Text(string="%first",index=-1,extent={{6,3},{6,3}},horizontalAlignment=TextAlignment.Left));
  connect(booToRea.y, comFan.u)
    annotation (Line(points={{0,68},{0,60},{46,60},{46,42}},color={0,0,127}));
  connect(y1, booToRea.u)
    annotation (Line(points={{-120,100},{0,100},{0,92}},color={255,0,255}));
  connect(y1, booToInt1.u)
    annotation (Line(points={{-120,100},{-90,100},{-90,80},{-82,80}},color={255,0,255}));
  connect(heaPum.P, P)
    annotation (Line(points={{11,-6},{20,-6},{20,100},{120,100}},color={0,0,127}));
  connect(yHea, heaPum.hea)
    annotation (Line(points={{-120,40},{-20,40},{-20,-7.9},{-11.1,-7.9}},color={255,0,255}));
  connect(port_a, hConInl.port_a)
    annotation (Line(points={{-100,0},{-80,0}},color={0,127,255}));
  connect(hConInl.port_b, mCon_flow.port_a)
    annotation (Line(points={{-60,0},{-50,0}},color={0,127,255}));
  connect(mCon_flow.port_b, heaPum.port_a1)
    annotation (Line(points={{-30,0},{-10,0}},color={0,127,255}));
  connect(tableData2D.QCon_flow, inverseBlockConstraints.u2)
    annotation (Line(points={{-22,-93},{-22,-98},{-28,-98},{-28,-80},{-35.2,-80}},
      color={0,0,127}));
  connect(QReqHea_flow.y, inverseBlockConstraints.u1)
    annotation (Line(points={{-67,-80},{-42.4,-80}},color={0,0,127}));
  connect(inverseBlockConstraints.y2, bus.ySet)
    annotation (Line(points={{4.4,-80},{6,-80},{6,-94},{60,-94},{60,-68}},color={0,0,127}),
      Text(string="%second",index=1,extent={{6,3},{6,3}},horizontalAlignment=TextAlignment.Left));
  connect(bus, tableData2D.sigBus)
    annotation (Line(points={{60,-68},{-13.9,-68}},color={255,204,51},thickness=0.5));
  connect(heaPum.port_b1, TConOut.port_a)
    annotation (Line(points={{10,0},{64,0}},color={0,127,255}));
  connect(TConOut.port_b, port_b)
    annotation (Line(points={{84,0},{100,0}},color={0,127,255}));
  connect(TConOut.T, bus.TConOutMea)
    annotation (Line(points={{74,11},{74,14},{60,14},{60,-68}},color={0,0,127}));
  connect(airSou.ports[1], TEvaInl.port_a)
    annotation (Line(points={{22,-40},{16,-40},{16,-38}},color={0,127,255}));
  connect(TEvaInl.port_b, heaPum.port_a2)
    annotation (Line(points={{16,-18},{16,-12},{10,-12}},color={0,127,255}));
  connect(TEvaInl.T, bus.TEvaInMea)
    annotation (Line(points={{5,-28},{0,-28},{0,-68},{60,-68}},color={0,0,127}));
  connect(inverseBlockConstraints.y1, heaPum.ySet)
    annotation (Line(points={{9.2,-80},{16,-80},{16,-50},{-16,-50},{-16,-4},{-11.2,-4}},
      color={0,0,127}));
  annotation (
    defaultComponentName="heaPum",
    Icon(
      coordinateSystem(
        preserveAspectRatio=false),
      graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-70,80},{70,-80}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5),
        Rectangle(
          extent={{-56,68},{58,50}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-56,-52},{58,-70}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-42,0},{-52,-12},{-32,-12},{-42,0}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5),
        Polygon(
          points={{-42,0},{-52,10},{-32,10},{-42,0}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5),
        Rectangle(
          extent={{-44,50},{-40,10}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-44,-12},{-40,-52}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{38,50},{42,-52}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{18,22},{62,-20}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5),
        Polygon(
          points={{40,22},{22,-10},{58,-10},{40,22}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid)}),
    Diagram(
      coordinateSystem(
        extent={{-100,-120},{100,120}})),
    Documentation(
      info="<html>
<p>
This model represents a set of identical air-to-water heat pumps
that are piped in parallel.
Dedicated constant-speed condenser pumps are included.
</p>
<h4>Control points</h4>
<p>
The following input and output points are available.
</p>
<ul>
<li>
On/Off command <code>y1</code>:
DO signal dedicated to each unit, with a dimensionality of one
</li>
<li>
Supply temperature setpoint <code>TSet</code>:
AO signal common to all units, with a dimensionality of zero
</li>
<li>
CW supply temperature <code>TConWatSup</code>:
AI signal common to all units, with a dimensionality of zero
</li>
</ul>
<h4>Details</h4>
<h5>Modeling approach</h5>
<p>
In a parallel arrangement, all operating units have the same operating point.
This allows modeling the heat transfer from outdoor air to condenser water
with a single instance of
<a href=\"modelica://Buildings.Fluid.HeatPumps.EquationFitReversible\">
Buildings.Fluid.HeatPumps.EquationFitReversible</a>.
Hydronics are resolved with mass flow rate multiplier components.
<p>
The model
<a href=\"modelica://Buildings.Fluid.HeatPumps.EquationFitReversible\">
Buildings.Fluid.HeatPumps.EquationFitReversible</a>
does not capture the sensitivity of the heat pump performance
to the HW supply temperature setpoint.
This means that a varying HW supply temperature setpoint
has no impact on the heat pump <i>COP</i> (all other variables
such as the HW return temperature being kept invariant).
This is a limitation of the model.
</p>
</html>",
      revisions="<html>
<ul>
<li>
February 24, 2023, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end AirToWaterHeatPumpModular;
