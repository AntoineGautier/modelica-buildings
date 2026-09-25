within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase3BoundaryHPOutlet "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase3(
    pla(locBou=Buildings.Templates.Plants.HeatPumps.Types.LocationBoundary.HeatPumpOutlet));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase3BoundaryHPOutlet;
