within Buildings.Templates.Plants.Chillers.Validation;
model HardCase2FromDp "Validation of chiller plant template"
  extends Buildings.Templates.Plants.Chillers.Validation.HardCase2(
    pla(intChi(valChiWatChiBypPar(from_dp=true))));
annotation(experiment(Tolerance=1e-6,
  StopTime=86400.0,
  __Dymola_Algorithm="Cvode"));
end HardCase2FromDp;
