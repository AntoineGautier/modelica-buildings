model MinimumExample2
  package Medium = Buildings.Media.Water "Medium model";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal=1;
  Buildings.Fluid.FixedResistances.Junction jun(
    redeclare package Medium=Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=m_flow_nominal*{1,1,1},
    dp_nominal=fill(1E3, 3))
    annotation (Placement(transformation(extent={{-10,10},{10,-10}})));
  Buildings.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium=Medium, nPorts=1)
    annotation (Placement(transformation(extent={{-60,30},{-40,50}})));
  Buildings.Fluid.Sources.MassFlowSource_T boundary(
    redeclare package Medium=Medium,
    m_flow=m_flow_nominal,
    nPorts=1)
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Buildings.Fluid.FixedResistances.Junction jun1(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=m_flow_nominal*{1,1,1},
    dp_nominal=fill(1E3, 3))
    annotation (Placement(transformation(extent={{10,30},{-10,50}})));
  Buildings.Experimental.DHC.Loads.Validation.BaseClasses.Distribution2Pipe
    distribution2Pipe(
    redeclare package Medium = Medium,
    nCon=1,
    mDis_flow_nominal=m_flow_nominal,
    mCon_flow_nominal={m_flow_nominal},
    dpDis_nominal={1000000000})
    annotation (Placement(transformation(extent={{-20,-70},{20,-50}})));
  Buildings.Fluid.Sources.MassFlowSource_T boundary1(
    redeclare package Medium = Medium,
    m_flow=m_flow_nominal,
    nPorts=1)
    annotation (Placement(transformation(extent={{-60,-70},{-40,-50}})));
  Buildings.Fluid.Sources.Boundary_pT bou1(
    redeclare package Medium = Medium,
    nPorts=1)
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));
  Buildings.Fluid.FixedResistances.PressureDrop res(
    redeclare package Medium = Medium,
    m_flow_nominal=
        m_flow_nominal, dp_nominal=1E3)
    annotation (Placement(transformation(extent={{10,-40},{-10,-20}})));
equation
  connect(boundary.ports[1], jun.port_1)
    annotation (Line(points={{-40,0},{-10,0}}, color={0,127,255}));
  connect(bou.ports[1], jun1.port_2)
    annotation (Line(points={{-40,40},{-10,40}}, color={0,127,255}));
  connect(jun1.port_3, jun.port_3)
    annotation (Line(points={{0,30},{0,10}}, color={0,127,255}));
  connect(boundary1.ports[1], distribution2Pipe.port_aDisSup)
    annotation (Line(points={{-40,-60},{-20,-60}}, color={0,127,255}));
  connect(bou1.ports[1], distribution2Pipe.port_bDisRet) annotation (Line(
        points={{-40,-80},{-30,-80},{-30,-66},{-20,-66}}, color={0,127,255}));
  connect(distribution2Pipe.ports_aCon[1], res.port_a)
    annotation (Line(points={{12,-50},{12,-30},{10,-30}}, color={0,127,255}));
  connect(res.port_b, distribution2Pipe.ports_bCon[1]) annotation (Line(points={
          {-10,-30},{-12,-30},{-12,-50}}, color={0,127,255}));
  annotation (uses(Modelica(version="3.2.3"), Buildings(version="8.0.0")));
end MinimumExample2;
