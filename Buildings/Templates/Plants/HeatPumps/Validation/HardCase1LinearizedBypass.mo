within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1LinearizedBypass "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(valChiWatMinByp(linearized=true), valHeaWatMinByp(linearized=true)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1LinearizedBypass;
