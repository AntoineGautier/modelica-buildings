within Buildings.Applications.DHC.EnergyTransferStations.FifthGeneration.BaseClasses;
model Chiller "Base subsystem with heat recovery chiller"
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium
    "Medium model"
    annotation (choices(
      choice(redeclare package Medium = Buildings.Media.Water "Water"),
      choice(redeclare package Medium =
          Buildings.Media.Antifreeze.PropyleneGlycolWater (
        property_T=293.15,
        X_a=0.40) "Propylene glycol water, 40% mass fraction")));

  parameter Boolean allowFlowReversal = false
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);

  parameter Buildings.Fluid.Chillers.Data.ElectricEIR.Generic dat
    "Chiller performance data"
    annotation (Placement(transformation(extent={{-160,-160},{-140,-140}})));

  parameter Modelica.SIunits.PressureDifference dpCon_nominal
    "Nominal pressure drop accross condenser"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.PressureDifference dpEva_nominal
    "Nominal pressure drop accross evaporator"
    annotation (Dialog(group="Nominal condition"));
  parameter Modelica.SIunits.Pressure dpValCon_nominal=dpCon_nominal / 4
    "Nominal pressure drop accross control valve on condenser side";
  parameter Modelica.SIunits.Pressure dpValEva_nominal=dpEva_nominal / 4
    "Nominal pressure drop accross control valve on evaporator side";

  // IO CONNECTORS
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uHea
    "Heating mode enabled signal"
    annotation (Placement(transformation(extent={{-240,160},{-200,200}}),
      iconTransformation(extent={{-140,10},{-100,50}})));
  Buildings.Controls.OBC.CDL.Interfaces.BooleanInput uCoo
    "Cooling mode enabled signal"
    annotation (Placement(transformation(extent={{-240,130},{-200,170}}),
      iconTransformation(extent={{-140,-10},{-100,30}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput TChiWatSupSet(
    final unit="K", displayUnit="degC")
    "Chilled water supply temperature set-point (may be reset down)"
    annotation (Placement(transformation(extent={{-240,70},{-200,110}}),
      iconTransformation(extent={{-140,-50},{-100,-10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealInput THeaWatSupSet(
    final unit="K", displayUnit="degC")
    "Heating water supply temperature set-point"
    annotation (Placement(transformation(extent={{-240,100},{-200,140}}),
      iconTransformation(extent={{-140,-30},{-100,10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aChiWat(
    redeclare final package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid port for chilled water return"
    annotation (Placement(transformation(extent={{190,-70},{210,-50}}),
        iconTransformation(extent={{90,-70},{110,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bChiWat(
    redeclare final package Medium = Medium,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid port for chilled water supply"
    annotation (Placement(transformation(extent={{190,50},{210,70}}),
        iconTransformation(extent={{90,50},{110,70}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aHeaWat(
    redeclare final package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid port for heating water return"
    annotation (Placement(transformation(extent={{-210,-70},{-190,-50}}),
        iconTransformation(extent={{-110,-70},{-90,-50}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bHeaWat(
    redeclare final package Medium = Medium,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0),
    each h_outflow(start=Medium.h_default, nominal=Medium.h_default))
    "Fluid port for heating water supply"
    annotation (Placement(transformation(extent={{-210,50},{-190,70}}),
        iconTransformation(extent={{-110,50},{-90,70}})));
  // COMPONENTS
  Fluid.Chillers.ElectricEIR chi(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final allowFlowReversal1=allowFlowReversal,
    final allowFlowReversal2=allowFlowReversal,
    final dp1_nominal=0,
    final dp2_nominal=0,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final per=dat)
    "Water cooled chiller (ports indexed 1 are on condenser side)"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  Buildings.Fluid.Movers.SpeedControlled_y pumCon(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final addPowerToMedium=false,
    per(pressure(dp={dpCon_nominal,0}, V_flow={0,mCon_flow_nominal/1000})),
    final allowFlowReversal=allowFlowReversal)
    "Condenser pump"
    annotation (Placement(transformation(extent={{-110,50},{-90,70}})));
  Buildings.Fluid.Movers.SpeedControlled_y pumEva(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    final addPowerToMedium=false,
    per(pressure(dp={dpEva_nominal,0}, V_flow={0,mEva_flow_nominal/1000})),
    final allowFlowReversal=allowFlowReversal)
    "Evaporator pump"
    annotation (Placement(transformation(
      extent={{10,-10},{-10,10}},
      rotation=0,
      origin={-100,-60})));
  FifthGeneration.Controls.Chiller con(
    TChiWatSupSetMin=dat.TEvaLvgMin,
    TConWatEntMin=dat.TConEntMin,
    TEvaWatEntMax=dat.TEvaLvgMax - dat.QEva_flow_nominal /
      cp_default / dat.mEva_flow_nominal)
    "Controller"
    annotation (Placement(transformation(extent={{-70,130},{-50,150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTConLvg(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_nominal=mCon_flow_nominal)
    "Condenser water leaving temperature"
    annotation (Placement(
      transformation(
      extent={{10,10},{-10,-10}},
      rotation=270,
      origin={20,20})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTConEnt(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_nominal=mCon_flow_nominal)
    "Condenser water entering temperature"
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
      rotation=-90,
      origin={-20,40})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTEvaEnt(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_nominal=mEva_flow_nominal)
    "Evaporator water entering temperature"
    annotation (Placement(
      transformation(
      extent={{10,10},{-10,-10}},
      rotation=270,
      origin={20,-40})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTEvaLvg(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_nominal=mEva_flow_nominal)
    "Evaporator water leaving temperature"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-20,-20})));
  Junction splEva(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mEva_flow_nominal)
    "Flow splitter for the evaporator water circuit"
    annotation (Placement(
      transformation(
      extent={{10,-10},{-10,10}},
      rotation=0,
      origin={-140,-60})));
  Junction splConMix(
    redeclare final package Medium = Medium,
    final m_flow_nominal=mCon_flow_nominal)
    "Flow splitter"
    annotation (Placement(transformation(
      extent={{-10,10},{10,-10}},
      rotation=0,
      origin={120,60})));
  Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valMixEva(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=mEva_flow_nominal,
    final dpValve_nominal=dpValEva_nominal,
    final dpFixed_nominal=dpEva_nominal)
    "Three-way mixing valve controlling evaporator water entering temperature"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={120,-60})));
  Fluid.Actuators.Valves.ThreeWayEqualPercentageLinear valMixCon(
    redeclare final package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final m_flow_nominal=mCon_flow_nominal,
    final dpValve_nominal=dpValCon_nominal,
    final dpFixed_nominal=dpCon_nominal)
    "Three-way mixing valve to controlling condenser water entering temperature"
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={-140,60})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea[2]
    "Constant speed primary pumps control signal"
    annotation (Placement(transformation(extent={{-160,170},{-140,190}})));
protected
  final parameter Medium.ThermodynamicState sta_default = Medium.setState_pTX(
    T=Medium.T_default,
    p=Medium.p_default,
    X=Medium.X_default[1:Medium.nXi])
    "Medium state at default properties";
  final parameter Modelica.SIunits.SpecificHeatCapacity cp_default=
    Medium.specificHeatCapacityCp(sta_default)
    "Specific heat capacity of the fluid";
equation
  connect(splConMix.port_3,valMixCon. port_3) annotation (Line(points={{120,70},
          {120,80},{-140,80},{-140,70}},    color={0,127,255}));
  connect(valMixCon.port_2, pumCon.port_a)
    annotation (Line(points={{-130,60},{-110,60}},   color={0,127,255}));
  connect(pumEva.port_b, splEva.port_1)
    annotation (Line(points={{-110,-60},{-130,-60}},
                                                   color={0,127,255}));
  connect(splEva.port_3,valMixEva. port_3) annotation (Line(points={{-140,-70},{
          -140,-80},{120,-80},{120,-70}},
                                  color={0,127,255}));
  connect(con.yMixEva, valMixEva.y) annotation (Line(points={{-48,136},{100,136},
          {100,-40},{120,-40},{120,-48}},
                                        color={0,0,127}));
  connect(con.yMixCon, valMixCon.y) annotation (Line(points={{-48,132},{-44,132},
          {-44,120},{-160,120},{-160,40},{-140,40},{-140,48}},
                                          color={0,0,127}));
  connect(con.yChi, chi.on) annotation (Line(points={{-48,148},{-36,148},{-36,3},
          {-12,3}}, color={255,0,255}));
  connect(con.TChiWatSupSet, chi.TSet) annotation (Line(points={{-48,144},{-40,144},
          {-40,-3},{-12,-3}},      color={0,0,127}));
  connect(uHea, con.uHea) annotation (Line(points={{-220,180},{-180,180},{-180,148},
          {-72,148}},  color={255,0,255}));
  connect(uCoo, con.uCoo) annotation (Line(points={{-220,150},{-186,150},{-186,146},
          {-72,146}},  color={255,0,255}));
  connect(TChiWatSupSet, con.TChiWatSupSetMax) annotation (Line(points={{-220,90},
          {-186,90},{-186,142},{-72,142}},   color={0,0,127}));
  connect(uHea, booToRea[1].u) annotation (Line(points={{-220,180},{-162,180}},
                            color={255,0,255}));
  connect(uCoo, booToRea[2].u) annotation (Line(points={{-220,150},{-192,150},{-192,
          180},{-162,180}}, color={255,0,255}));
  connect(booToRea[1].y, pumCon.y) annotation (Line(points={{-138,180},{-100,180},
          {-100,72}},  color={0,0,127}));
  connect(booToRea[2].y, pumEva.y) annotation (Line(points={{-138,180},{-120,180},
          {-120,0},{-100,0},{-100,-48}},  color={0,0,127}));
  connect(senTConEnt.T, con.TConWatEnt) annotation (Line(points={{-31,40},{-78,40},
          {-78,136},{-72,136}},              color={0,0,127}));
  connect(senTEvaEnt.T, con.TEvaWatEnt) annotation (Line(points={{9,-40},{-80,-40},
          {-80,138},{-72,138}},              color={0,0,127}));
  connect(THeaWatSupSet, con.THeaWatSupSet) annotation (Line(points={{-220,120},
          {-192,120},{-192,144},{-72,144}},  color={0,0,127}));
  connect(senTConLvg.T, con.THeaWatSup) annotation (Line(points={{9,20},{-82,20},
          {-82,140},{-72,140}},              color={0,0,127}));
  connect(splConMix.port_2, port_bHeaWat) annotation (Line(points={{130,60},{140,
          60},{140,100},{-180,100},{-180,60},{-200,60}},
                                  color={0,127,255}));
  connect(splEva.port_2, port_bChiWat) annotation (Line(points={{-150,-60},{-160,
          -60},{-160,-100},{180,-100},{180,60},{200,60}},
                                     color={0,127,255}));
  connect(port_aHeaWat,valMixCon. port_1) annotation (Line(points={{-200,-60},{-170,
          -60},{-170,60},{-150,60}},                        color={0,127,255}));
  connect(port_aChiWat,valMixEva. port_1) annotation (Line(points={{200,-60},{130,
          -60}},                                            color={0,127,255}));
  connect(valMixEva.port_2, senTEvaEnt.port_a)
    annotation (Line(points={{110,-60},{20,-60},{20,-50}}, color={0,127,255}));
  connect(senTEvaLvg.port_b, pumEva.port_a) annotation (Line(points={{-20,-30},{
          -20,-60},{-90,-60}}, color={0,127,255}));
  connect(senTEvaLvg.port_a, chi.port_b2)
    annotation (Line(points={{-20,-10},{-20,-6},{-10,-6}}, color={0,127,255}));
  connect(senTEvaEnt.port_b, chi.port_a2)
    annotation (Line(points={{20,-30},{20,-6},{10,-6}}, color={0,127,255}));
  connect(chi.port_b1, senTConLvg.port_a)
    annotation (Line(points={{10,6},{20,6},{20,10}}, color={0,127,255}));
  connect(senTConLvg.port_b, splConMix.port_1)
    annotation (Line(points={{20,30},{20,60},{110,60}}, color={0,127,255}));
  connect(pumCon.port_b, senTConEnt.port_a)
    annotation (Line(points={{-90,60},{-20,60},{-20,50}}, color={0,127,255}));
  connect(senTConEnt.port_b, chi.port_a1)
    annotation (Line(points={{-20,30},{-20,6},{-10,6}}, color={0,127,255}));
annotation (
  defaultComponentName="chi",
  Documentation(info="<html>
<p>
This models represents an energy transfer station (ETS) for fifth generation
district heating and cooling systems.
The control logic is based on five operating modes:
</p>
<ul>
<li>
heating only,
</li>
<li>
cooling only,
</li>
<li>
simultaneous heating and cooling,
</li>
<li>
part surplus heat or cold rejection,
</li>
<li>
full surplus heat or cold rejection.
</li>
</ul>
<p align=\"center\">
<img alt=\"Image the 5th generation of district heating and cooling substation\"
src=\"modelica://Buildings/Resources/Images/Applications/DHC/EnergyTransferStations/SubstationModifiedLayout.png\"/>
<p>
The substation layout consists in three water circuits:
</p>
<ol>
<li>
the heating water circuit, which is connected to the building heating water
distribution system,
</li>
<li>
the chilled water circuit, which is connected to the building chilled water
distribution system,
</li>
<li>
the ambient water circuit, which is connected to the district heat exchanger
(and optionally to the geothermal borefield).
</li>
</ol>
<h4>Heating water circuit</h4>
<p>
It satisfies the building heating requirements and consists in:
</p>
<ol>
<li>
the heating/cooling generating source, where the EIR chiller i.e. condenser heat exchanger operates to satisfy the heating setpoint
<code>TSetHea</code>.
</li>
<li>
The constant speed condenser water pump <code>pumCon</code>.
</li>
<li>
The hot buffer tank, is implemented to provide hydraulic decoupling between the primary (the ETS side) and secondary (the building side)
water circulators i.e. pumps and to eliminate the cycling of the heat generating source machine i.e EIR chiller.
</li>
<li>
Modulating mixing three way valve <code>valCon</code> to control the condenser entering water temperature.
</li>
</ol>
<h4>Chilled water circuit</h4>
<p>
It operates to satisfy the building cooling requirements and consists of
</p>
<ol>
<li>
The heating/cooling generating source, where the  EIR chiller i.e evaporator heat
exchanger operates to satisfy the cooling setpoint <code>TSetCoo</code>.
</li>
<li>
The constant speed evaporator water pump <code>pumEva</code>.
</li>
<li>
The chilled water buffer tank, is implemented obviously for the same mentioned reasons of the hot buffer tank.
</li>
<li>
Modulating mixing three way valve <code>valEva</code> to control the evaporator entering water temperature.
</li>
</ol>
<p>
For more detailed description of
</p>
<p>
The controller of heating/cooling generating source, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.ChillerController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.ChillerController.</a>
</p>
<p>
The evaporator pump <code>pumEva</code> and the condenser pump <code>pumCon</code>, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.PrimaryPumpsConstantSpeed\">
Buildings.Applications.DHC.EnergyTransferStations.Control.PrimaryPumpsConstantSpeed.</a>
</p>
<h4>Ambient water circuit</h4>
<p>
The ambient water circuit operates to maximize the system exergy by rejecting surplus i.e. heating or cooling energy
first to the borefield system and second to either or both of the borefield and the district systems.
It consists of
</p>
<ol>
<li>
The borefield component model <code>borFie</code>.
</li>
<li>
The borefield pump <code>pumBor</code>, where its mass flow rate is modulated using a reverse action PI controller.
</li>
<li>
Modulating mixing three way valve <code>valBor</code> to control the borefield entering water temperature.
</li>
<li>
The heat exchanger component model <code>hex</code>.
</li>
<li>
The heat exchanger district pump <code>pumHexDis</code>, where its mass flow rate is modulated using a reverse action PI controller.
</li>
<li>
Two on/off 2-way valves <code> valHea</code>, <code>valCoo</code>
which separates the ambient from the chilled water and heating water circuits.
</ol>
<p>
For more detailed description of the ambient circuit control concept see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.AmbientCircuitController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.AmbientCircuitController.</a>
</p>
<h4>Notes</h4>
<p>
For more detailed description of the finite state machines which transitions the ETS between
different operational modes, see
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.HotSideController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.HotSideController</a> and
<a href=\"Buildings.Applications.DHC.EnergyTransferStations.Control.ColdSideController\">
Buildings.Applications.DHC.EnergyTransferStations.Control.ColdSideController</a>.
</p>

</html>", revisions="<html>
<ul>
<li>
January 18, 2020, by Hagar Elarga: <br/>
First implementation
</li>
</ul>
</html>"),
    Icon(graphics={
        Rectangle(
          extent={{-100,-100},{100,100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,60},{60,-60}},
          lineColor={27,0,55},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-149,-110},{151,-150}},
          lineColor={0,0,255},
          textString="%name")}),
    Diagram(coordinateSystem(extent={{-200,-200},{200,200}})));
end Chiller;