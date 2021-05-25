within Buildings.Experimental.DHC.Examples.Combined.Generation5.Examples;
model Debug1
  extends Modelica.Icons.Example;
  package Medium = Buildings.Media.Water "Medium model";
  constant Real facMul = 10
    "Building loads multiplier factor";
  parameter Boolean allowFlowReversalSer = true
    "Set to true to allow flow reversal in the service lines"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Boolean allowFlowReversalBui = false
    "Set to true to allow flow reversal for in-building systems"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  parameter Integer nBui = datDes.nBui
    "Number of buildings connected to DHC system"
    annotation (Evaluate=true);
  Loads.BuildingSpawnWithETS bui annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Fluid.Sources.Boundary_pT           bou(redeclare final package Medium = Medium, nPorts=2)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
      extent={{-10,-10},{10,10}},
      rotation=180,
      origin={50,-60})));
  inner parameter Data.DesignDataSpawn datDes(
    idxBuiSpa=3,
    mPumDis_flow_nominal=150,
    mPipDis_flow_nominal=150,
    dp_length_nominal=250,
    epsPla=0.91,
    final mCon_flow_nominal=fill(bui.ets.mDisWat_flow_nominal, 3))
    "Design data"
    annotation (Placement(transformation(extent={{60,72},{80,92}})));
  Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMaxSet(k=55 + 273.15)
    "Heating water supply temperature set point - Maximum value"
    annotation (Placement(transformation(extent={{-80,50},{-60,70}})));
  Controls.OBC.CDL.Continuous.Sources.Constant TChiWatSupSet(k=7 + 273.15) "Chilled water supply temperature set point"
    annotation (Placement(transformation(extent={{-50,30},{-30,50}})));
  Controls.OBC.CDL.Continuous.Sources.Constant THeaWatSupMinSet(each k=28 + 273.15)
    "Heating water supply temperature set point - Minimum value"
    annotation (Placement(transformation(extent={{-50,70},{-30,90}})));
equation
  connect(TChiWatSupSet.y, bui.TChiWatSupSet)
    annotation (Line(points={{-28,40},{-22,40},{-22,45},{-12,45}}, color={0,0,127}));
  connect(THeaWatSupMaxSet.y, bui.THeaWatSupMaxSet)
    annotation (Line(points={{-58,60},{-20,60},{-20,47},{-12,47}}, color={0,0,127}));
  connect(THeaWatSupMinSet.y, bui.THeaWatSupMinSet)
    annotation (Line(points={{-28,80},{-16,80},{-16,49},{-12,49}}, color={0,0,127}));
  connect(bui.port_bSerAmb, bou.ports[1]) annotation (Line(points={{10,40},{40,40},{40,-62}}, color={0,127,255}));
  connect(bui.port_aSerAmb, bou.ports[2])
    annotation (Line(points={{-10,40},{-20,40},{-20,-58},{40,-58}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)));
end Debug1;
