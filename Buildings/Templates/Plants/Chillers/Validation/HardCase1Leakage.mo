within Buildings.Templates.Plants.Chillers.Validation;
model HardCase1Leakage "Validation of chiller plant template"
  extends Buildings.Templates.Plants.Chillers.Validation.HardCase1(pla(chi(
          valChiWatChiIsoPar(each l=1E-3), valConWatChiIso(each l=1E-3)),
        valChiWatMinByp(l=1E-3)));
annotation(experiment(Tolerance=1e-6,
  StopTime=86400.0,
  __Dymola_Algorithm="Cvode"));
end HardCase1Leakage;
