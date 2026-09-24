within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase5Compliance "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase5(
    pla(use_cpl=true));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase5Compliance;
