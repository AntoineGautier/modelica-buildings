within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1 "Validation of AWHP plant template"
  extends Buildings.Templates.Plants.HeatPumps.Validation.AirToWaterReversibleHeatRecovery(
    pla(typ=Buildings.Templates.Plants.Controls.Types.PlantHeatPump.Reversible,
      typDis_select1=Buildings.Templates.Plants.HeatPumps.Types.Distribution.Variable1Only,
      typArrPumPri_select=Buildings.Templates.Components.Types.PumpArrangement.Dedicated,
      have_pumPriDedComHp_select=false,
      ctl(have_senTLooRet_select=true,
        have_senDpHeaWatRemWir=false)));
annotation(
  experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"));
end HardCase1;
