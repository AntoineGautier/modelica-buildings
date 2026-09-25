within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1BoundaryCHW "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(use_bouChiWat=true));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1BoundaryCHW;
