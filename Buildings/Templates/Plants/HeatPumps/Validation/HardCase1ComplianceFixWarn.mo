within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1ComplianceFixWarn "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1Compliance(
    loaHea(loa(coi(use_dynamicFlowRegime=true))));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1ComplianceFixWarn;
