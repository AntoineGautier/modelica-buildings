within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1LinearizedBypassBoundarySupply
  "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(
locBou=Buildings.Templates.Plants.HeatPumps.Types.LocationBoundary.Supply,
      valChiWatMinByp(linearized=true), valHeaWatMinByp(linearized=true)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1LinearizedBypassBoundarySupply;
