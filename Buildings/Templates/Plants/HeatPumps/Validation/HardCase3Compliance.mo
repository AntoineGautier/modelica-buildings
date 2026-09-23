within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase3Compliance "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase3(
    pla(valIso(use_cpl=true)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase3Compliance;
