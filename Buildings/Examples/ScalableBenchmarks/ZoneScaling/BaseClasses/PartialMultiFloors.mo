within Buildings.Examples.ScalableBenchmarks.ZoneScaling.BaseClasses;
model PartialMultiFloors

  parameter Integer numFlo(start=2) "Number of floors";

  replaceable package Medium =  Buildings.Media.Air
    "Medium model for air";

  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorSou[numFlo]
    "Heat port to air volume for all South zones"
    annotation (Placement(transformation(extent={{106,-46},{126,-26}}),
        iconTransformation(extent={{128,-36},{148,-16}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorEas[numFlo]
    "Heat port to air volume for all East zones"
    annotation (Placement(transformation(extent={{320,42},{340,62}}),
        iconTransformation(extent={{318,64},{338,84}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorNor[numFlo]
    "Heat port to air volume for all North zones"
    annotation (Placement(transformation(extent={{106,114},{126,134}}),
        iconTransformation(extent={{126,106},{146,126}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorWes[numFlo]
    "Heat port to air volume for all West zones"
    annotation (Placement(transformation(extent={{-40,56},{-20,76}}),
        iconTransformation(extent={{-36,64},{-16,84}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heaPorCor[numFlo]
    "Heat port to air volume for all Core zones"
    annotation (Placement(transformation(extent={{106,36},{126,56}}),
        iconTransformation(extent={{130,38},{150,58}})));

  Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b portsSou[numFlo, 2](
      redeclare package Medium = Medium) "Fluid inlets and outlets for all South zones"
    annotation (Placement(transformation(extent={{70,-44},{110,-28}}),
        iconTransformation(extent={{78,-32},{118,-16}})));

  Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b portsEas[numFlo, 2](
      redeclare package Medium = Medium) "Fluid inlets and outlets for all East zones"
    annotation (Placement(transformation(extent={{310,28},{350,44}}),
        iconTransformation(extent={{306,40},{346,56}})));

  Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b portsNor[numFlo, 2](
      redeclare package Medium = Medium) "Fluid inlets and outlets for all North zones"
    annotation (Placement(transformation(extent={{70,116},{110,132}}),
        iconTransformation(extent={{78,108},{118,124}})));

  Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b portsWes[numFlo, 2](
      redeclare package Medium = Medium) "Fluid inlets and outlets for all West zones"
    annotation (Placement(transformation(extent={{-46,40},{-6,56}}),
        iconTransformation(extent={{-46,40},{-6,56}})));

  Modelica.Fluid.Vessels.BaseClasses.VesselFluidPorts_b portsCor[numFlo, 2](
      redeclare package Medium = Medium) "Fluid inlets and outlets for all Core zones"
    annotation (Placement(transformation(extent={{70,38},{110,54}}),
        iconTransformation(extent={{78,40},{118,56}})));

  Modelica.Blocks.Interfaces.RealOutput TRooAir[numFlo, 5](
    each unit="K",
    each displayUnit="degC") "Room air temperatures"
    annotation (Placement(transformation(extent={{380,150},{400,170}}),
        iconTransformation(extent={{380,40},{400,60}})));

  Modelica.Blocks.Interfaces.RealOutput p_rel[numFlo]
    "Relative pressure signal of building static pressure" annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-170,220}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-170,-30})));

  BoundaryConditions.WeatherData.Bus weaBus "Weather bus"
    annotation (Placement(transformation(extent={{200,190},{220,210}}),
        iconTransformation(extent={{200,190},{220,210}})));

  replaceable Buildings.Examples.VAVReheat.BaseClasses.PartialFloor
    floors[numFlo](redeclare each package Medium = Medium) "Floors"
     annotation (Placement(transformation(extent={{-136,22},{-64,60}})));

equation
  connect(floors.heaPorWes, heaPorWes) annotation (Line(points={{-38.2696,
          -90.9846},{-38.2696,66},{-30,66}},
                                   color={191,0,0}));
  connect(floors.heaPorNor, heaPorNor) annotation (Line(points={{8.92174,-78.7077},
          {8.92174,100},{116,100},{116,124}}, color={191,0,0}));
  connect(floors.heaPorCor, heaPorCor) annotation (Line(points={{10.087,
          -98.5846},{22,-98.5846},{22,22},{116,22},{116,46}},
                                                    color={191,0,0}));
  connect(floors.heaPorEas, heaPorEas) annotation (Line(points={{64.8522,
          -90.9846},{302,-90.9846},{302,52},{330,52}},
                                             color={191,0,0}));
  connect(floors.heaPorSou, heaPorSou) annotation (Line(points={{9.50435,
          -120.215},{9.50435,-114},{58,-114},{58,-48},{116,-48},{116,-36}},
                                                                  color={191,0,0}));

  connect(floors.p_rel, p_rel) annotation (Line(points={{-137.565,42.5833},{
          -100,42.5833},{-100,220},{-170,220}},
                                  color={0,0,127}));

  connect(floors.portsWes, portsWes) annotation (Line(points={{-127.548,42.2667},
          {-127.548,-110},{-26,-110},{-26,48}}, color={0,127,255}));
  connect(floors.portsNor, portsNor) annotation (Line(points={{-108.139,53.0333},
          {-108.139,124},{90,124}}, color={0,127,255}));
  connect(floors.portsCor, portsCor) annotation (Line(points={{-108.139,42.2667},
          {-108.139,-92},{18,-92},{18,46},{90,46}}, color={0,127,255}));
  connect(floors.portsEas, portsEas) annotation (Line(points={{-72.4522,42.2667},
          {-72.4522,-112},{330,-112},{330,36}},color={0,127,255}));
  connect(floors.TRooAir, TRooAir) annotation (Line(points={{-62.4348,42.5833},
          {360,42.5833},{360,160},{390,160}},
                                color={0,0,127}));
  connect(floors.portsSou, portsSou) annotation (Line(points={{-108.139,30.8667},
          {-108.139,-108},{52,-108},{52,-36},{90,-36}}, color={0,127,255}));
  for i in 1:numFlo loop
  connect(floors[i].weaBus, weaBus) annotation (Line(
      points={{-90.6087,66.3333},{-90.6087,-18},{210,-18},{210,200}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  end for;

                                                                     annotation (Placement(transformation(extent={{-54,-136},{80,-60}})),
              Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,-160},
            {380,180}}), graphics={
                   Rectangle(
          extent={{-160,80},{300,-160}},
          lineColor={95,95,95},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-160,-160},{300,100}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-140,80},{280,-140}},
          pattern=LinePattern.None,
          lineColor={117,148,176},
          fillColor={170,213,255},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{-80,-160},{214,-140}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-80,-154},{214,-146}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-136,90},{-60,14},{-68,8},{-142,82},{-136,90}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{210,-64},{286,-140},{278,-146},{204,-72},{210,-64}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-160,40},{-140,-100}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-154,40},{-146,-100}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-144,-136},{-62,-58},{-54,-64},{-138,-144},{-144,-136}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
                   Rectangle(
          extent={{-120,120},{340,-120}},
          lineColor={95,95,95},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-120,-120},{340,140}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,120},{320,-100}},
          pattern=LinePattern.None,
          lineColor={117,148,176},
          fillColor={170,213,255},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{-40,-120},{254,-100}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-40,-114},{254,-106}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-96,130},{-20,54},{-28,48},{-102,122},{-96,130}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{250,-24},{326,-100},{318,-106},{244,-32},{250,-24}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-120,80},{-100,-60}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-114,80},{-106,-60}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-104,-96},{-22,-18},{-14,-24},{-98,-104},{-104,-96}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
                   Rectangle(
          extent={{-80,160},{380,-80}},
          lineColor={95,95,95},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-80,-80},{380,180}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,160},{360,-60}},
          pattern=LinePattern.None,
          lineColor={117,148,176},
          fillColor={170,213,255},
          fillPattern=FillPattern.Sphere),
        Rectangle(
          extent={{0,-80},{294,-60}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{0,-74},{294,-66}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{8,8},{294,100}},
          lineColor={95,95,95},
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{20,88},{280,22}},
          pattern=LinePattern.None,
          lineColor={117,148,176},
          fillColor={170,213,255},
          fillPattern=FillPattern.Sphere),
        Polygon(
          points={{-56,170},{20,94},{12,88},{-62,162},{-56,170}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{290,16},{366,-60},{358,-66},{284,8},{290,16}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Polygon(
          points={{284,96},{360,168},{368,162},{292,90},{284,96}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{-80,120},{-60,-20}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-74,120},{-66,-20}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-64,-56},{18,22},{26,16},{-58,-64},{-64,-56}},
          smooth=Smooth.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Rectangle(
          extent={{360,122},{380,-18}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{366,122},{374,-18}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{2,170},{296,178}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{2,160},{296,180}},
          lineColor={95,95,95},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{2,166},{296,174}},
          lineColor={95,95,95},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-160,-160},{380,180}})),
    Documentation(revisions="<html>
<ul>
<li>
March 25, 2021, by Baptiste Ravache:<br/>
First implementation.
</li>
</ul>
</html>"));
end PartialMultiFloors;
