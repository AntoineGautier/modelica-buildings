model SensibleHexConstantUA 
  "Simple heat exchanger with convective heat transfer as input" 
  extends Fluids.Interfaces.PartialDynamicFourPortTransformer(final C=tau_m*UA0);
  extends Buildings.BaseClasses.BaseIcon;
  
  annotation (
    Documentation(info="<html>
<p>
Simple model of a heat exchanger. The <tt>UA</tt> value is a constant
(independent of the mass flow rates) and the driving force for the heat transfer
is the linear temperature difference (not the logarithmic temperature difference).
Therefore, this model is only applicable for situations with constant flow rate and 
where the temperatures along the streamline do not intersect with the port temperatures.
</p>
<p>
</p>
</html>", revisions="<html>
<ul>
<li>
March 25, 2008, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"), Diagram);
  
   parameter Modelica.SIunits.ThermalConductance UA0(min=0) 
    "Thermal conductance at nominal flow" 
          annotation(Dialog(tab="General", group="Nominal condition"));
  parameter Modelica.SIunits.Time tau_m(min=0) = 2 "Time constant of metal" 
          annotation(Dialog(tab="General", group="Nominal condition"));
  Modelica.Blocks.Interfaces.RealInput Gc_1(redeclare type SignalType = 
        Modelica.SIunits.ThermalConductance) 
    "Signal representing the convective thermal conductance of fluid 1 in [W/K]"
    annotation (extent=[-140,10; -100,50], rotation=0);
  Modelica.Blocks.Interfaces.RealInput Gc_2(redeclare type SignalType = 
        Modelica.SIunits.ThermalConductance) 
    "Signal representing the convective thermal conductance of fluid 2 in [W/K]"
    annotation (extent=[-140,-50; -100,-10],
                                           rotation=0);
equation 
  connect(Gc_1, con1.Gc) annotation (points=[-120,30; -70,30; -70,44; -46,44;
        -46,30], style(color=74, rgbcolor={0,0,127}));
  connect(Gc_2, con2.Gc) annotation (points=[-120,-30; -60,-30; -60,-2; -46,-2;
        -46,-10], style(color=74, rgbcolor={0,0,127}));
end SensibleHexConstantUA;
