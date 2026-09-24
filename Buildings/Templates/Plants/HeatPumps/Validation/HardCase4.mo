within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase4 "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.AirToWaterReversiblePolyvalent(
    pla(linearized=false,
      typDis_select1=Buildings.Templates.Plants.HeatPumps.Types.Distribution.Constant1Variable2,
      typArrPumPri_select=Buildings.Templates.Components.Types.PumpArrangement.Dedicated,
      typPumPri_select=Buildings.Templates.Plants.HeatPumps.Types.PumpsPrimary.Constant,
      have_pumPriDedComHp_select=false,
      ctl(have_senTPriRet_select=true,
        have_senDpHeaWatRemWir=true)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase4;
