within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1Linearized "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(linearized=true));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1Linearized;
