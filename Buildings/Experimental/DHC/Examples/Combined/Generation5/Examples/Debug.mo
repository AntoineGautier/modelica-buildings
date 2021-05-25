within Buildings.Experimental.DHC.Examples.Combined.Generation5.Examples;
model Debug
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
  Networks.UnidirectionalParallel
    dis(
    show_entFlo=true,
    redeclare final package Medium = Medium,
    final nCon=nBui,
    final dp_length_nominal=datDes.dp_length_nominal,
    final mDis_flow_nominal=datDes.mPipDis_flow_nominal,
    final mCon_flow_nominal=datDes.mCon_flow_nominal,
    final mDisCon_flow_nominal=datDes.mDisCon_flow_nominal,
    final mEnd_flow_nominal=datDes.mEnd_flow_nominal,
    final lDis=datDes.lDis,
    final lCon=datDes.lCon,
    final lEnd=datDes.lEnd,
    final allowFlowReversal=allowFlowReversalSer) "Distribution network"
    annotation (Placement(transformation(extent={{-20,-10},{20,10}})));
  Fluid.Sources.Boundary_pT           bou(redeclare final package Medium = Medium, nPorts=2)
    "Boundary pressure condition representing the expansion vessel"
    annotation (Placement(transformation(
      extent={{-10,-10},{10,10}},
      rotation=180,
      origin={50,-60})));
  EnergyTransferStations.BaseClasses.Pump_m_flow     pumDis(redeclare final package Medium = Medium, final
      m_flow_nominal=datDes.mPumDis_flow_nominal)
    "Distribution pump"
    annotation (Placement(transformation(
      extent={{10,-10},{-10,10}},
      rotation=0,
      origin={0,-80})));
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
  Modelica.Blocks.Sources.Constant masFloMaiPum(k=datDes.mPumDis_flow_nominal)
    "Distribution pump mass flow rate"
    annotation (Placement(transformation(extent={{-88,-70},{-68,-50}})));
equation
  connect(pumDis.port_a, bou.ports[1]) annotation (Line(points={{10,-80},{40,-80},{40,-62}}, color={0,127,255}));
  connect(dis.port_bDisRet, bou.ports[2])
    annotation (Line(points={{-20,-6},{-40,-6},{-40,-20},{40,-20},{40,-58}}, color={0,127,255}));
  connect(pumDis.port_b, dis.port_aDisSup)
    annotation (Line(points={{-10,-80},{-60,-80},{-60,0},{-20,0}}, color={0,127,255}));
  connect(dis.ports_bCon[3], bui.port_aSerAmb)
    annotation (Line(points={{-12,10},{-12,20},{-20,20},{-20,40},{-10,40}}, color={0,127,255}));
  connect(bui.port_bSerAmb, dis.ports_aCon[3])
    annotation (Line(points={{10,40},{20,40},{20,20},{12,20},{12,10}}, color={0,127,255}));
  connect(TChiWatSupSet.y, bui.TChiWatSupSet)
    annotation (Line(points={{-28,40},{-22,40},{-22,45},{-12,45}}, color={0,0,127}));
  connect(THeaWatSupMaxSet.y, bui.THeaWatSupMaxSet)
    annotation (Line(points={{-58,60},{-20,60},{-20,47},{-12,47}}, color={0,0,127}));
  connect(THeaWatSupMinSet.y, bui.THeaWatSupMinSet)
    annotation (Line(points={{-28,80},{-16,80},{-16,49},{-12,49}}, color={0,0,127}));
  connect(masFloMaiPum.y, pumDis.m_flow_in) annotation (Line(points={{-67,-60},{0,-60},{0,-68}}, color={0,0,127}));
  connect(dis.port_bDisSup, dis.port_aDisRet)
    annotation (Line(points={{20,0},{40,0},{40,-6},{20,-6}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)));
end Debug;
