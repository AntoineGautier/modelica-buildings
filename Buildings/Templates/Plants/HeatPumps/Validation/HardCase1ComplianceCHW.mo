within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1ComplianceCHW "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(valIso(use_cpl=true, use_cplHw=false)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1ComplianceCHW;
