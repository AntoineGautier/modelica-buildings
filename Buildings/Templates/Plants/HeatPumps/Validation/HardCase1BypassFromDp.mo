within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1BypassFromDp "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(
    pla(valChiWatMinByp(from_dp=false), valHeaWatMinByp(from_dp=false))
         );
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1BypassFromDp;
