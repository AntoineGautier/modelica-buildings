within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1ComplianceHighC "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1Compliance(
    pla(valIso(C=1E-4)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1ComplianceHighC;
