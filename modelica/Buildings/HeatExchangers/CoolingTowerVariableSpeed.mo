model CoolingTowerVariableSpeed "Cooling tower with variable speed" 
  extends Fluids.Interfaces.PartialFourPortTransformer;
  extends Buildings.BaseClasses.BaseIcon;
/*  Modelica.Blocks.Interfaces.RealInput TDb(redeclare type SignalType = 
        Modelica.SIunits.Temperature) "inlet air drybulb temperature" 
    annotation (extent=[-140,60; -100,100]);
  Modelica.Blocks.Interfaces.RealInput TWb(redeclare type SignalType = 
        Modelica.SIunits.Temperature) "inlet air wetbulb temperature" 
    annotation (extent=[-140,20; -100,60]);
*/
 /*
COOLING TOWER:VARIABLE SPEED,
Big Tower1, !- Tower Name
Condenser 1 Inlet Node, !- Water Inlet Node Name
Condenser 1 Outlet Node, !- Water Outlet Node Name
YorkCalc, !- Tower Model Type
, !- Tower Model Coefficient Name
25.5556, !- Design Inlet Air Wet-Bulb Temperature {C}
3.8889, !- Design Approach Temperature {C}
5.5556, !- Design Range Temperature {C}
0.0015, !- Design Water Flow Rate {m3/s}
1.6435, !- Design Air Flow Rate {m3/s}
275, !- Design Fan Power {W}
FanRatioCurve, !- Fan Power Ratio as a function of Air Flow Rate Ratio Curve Name
0.2, !- Minimum Air Flow Rate Ratio
0.125, !- Fraction of Tower Capacity in Free Convection Regime
450.0, !- Basin Heater Capacity {W/K}
4.5, !- Basin Heater Set Point Temperature {C}
BasinSchedule, !- Basin Heater Operating Schedule Name
SATURATED EXIT, !- Evaporation Loss Mode
, !- Evaporation Loss Factor
0.05, !- Makeup Water Usage due to Drift {%}
SCHEDULED RATE, !- Blowdown Calculation Mode
BlowDownSchedule, !- Schedule Name for Makeup Water Usage due to Blowdown
; !- Name of Water Storage Tank for Supply
 
*/
 Modelica.SIunits.HeatFlowRate Q_flow 
    "Heat transfered from medium 1 to medium 2";
  
equation 
//  TDb - medium_a.T = 0.5 * (medium_b.T - medium_a.T);
  Q_flow = 1*((medium_a1.T+medium_b1.T)-(medium_a2.T+medium_b2.T))/2; // for testing only
  port_a1.H_flow + port_b1.H_flow = Q_flow;
  port_a1.m_flow + port_b1.m_flow = 0;
  port_a1.mXi_flow + port_b1.mXi_flow = zeros(Medium_1.nXi);
  port_a1.p = port_b1.p;
  
  port_a2.H_flow + port_b2.H_flow = -Q_flow;
  port_a2.m_flow + port_b2.m_flow = 0;
  port_a2.mXi_flow + port_b2.mXi_flow = zeros(Medium_2.nXi);
  port_a2.p = port_b2.p;
  
end CoolingTowerVariableSpeed;
