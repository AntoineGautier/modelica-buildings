within Buildings.ThermalZones.EnergyPlus.Validation;
model OneZoneTwoDifferentOutputVariables
  "Validation model for one zone with two different output variables"
  extends OneZoneOneOutputVariable;

  Buildings.ThermalZones.EnergyPlus.OutputVariable incBeaSou(
    key="Perimeter_ZN_1_wall_south_Window_1",
    name="Surface Outside Face Incident Beam Solar Radiation Rate per Area",
    y(final unit="W/m2"))
    "Block that reads incident beam solar radiation on south window from EnergyPlus"
    annotation (Placement(transformation(extent={{70,10},{90,30}})));
  annotation (Documentation(info="<html>
<p>
Simple test case for one building with one thermal zone and two different output variables.
This test case validates that the outputs are correct if requested from different
EnergyPlus variables.
</p>
</html>", revisions="<html>
<ul><li>
December 13, 2019, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"),
 __Dymola_Commands(file="modelica://Buildings/Resources/Scripts/Dymola/ThermalZones/EnergyPlus/Validation/OneZoneTwoDifferentOutputVariables.mos"
        "Simulate and plot"),
experiment(
      StopTime=432000,
      Tolerance=1e-06));
end OneZoneTwoDifferentOutputVariables;