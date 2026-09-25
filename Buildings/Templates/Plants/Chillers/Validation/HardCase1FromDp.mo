within Buildings.Templates.Plants.Chillers.Validation;
model HardCase1FromDp "Validation of chiller plant template"
  extends Buildings.Templates.Plants.Chillers.Validation.HardCase1(
    pla(intChi(valChiWatChiBypPar(from_dp=true))));
annotation(experiment(Tolerance=1e-6,
  StopTime=86400.0,
  __Dymola_Algorithm="Cvode"));
end HardCase1FromDp;
