within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1Leakage "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1(pla(valIso(
    valHeaWatUniOutIso(each l=1E-3),
    valChiWatUniOutIso(each l=1E-3),
    valHeaWatUniInlIso(each l=1E-3),
    valChiWatUniInlIso(each l=1E-3)),
      valChiWatMinByp(l=1E-3),
      valHeaWatMinByp(l=1E-3))       );
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase1Leakage;
