within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase2 "Validation of AWHP plant template"
  // linearized=true is detrimental in this case!
  // with linearized=true: simulation fails on native amd64 Linux, succeeds on emulated amd64.
  // with linearized=false: simulation SUCCEEDS on native amd64 Linux as well.
  extends Buildings.Templates.Plants.HeatPumps.Validation.AirToWaterReversibleHeatRecovery(
    pla(
      linearized=false,
      typ=Buildings.Templates.Plants.Controls.Types.PlantHeatPump.ReversibleHeatRecovery,
      typDis_select1=Buildings.Templates.Plants.HeatPumps.Types.Distribution.Variable1Only,
      typArrPumPri_select=Buildings.Templates.Components.Types.PumpArrangement.Headered,
      ctl(have_senDpHeaWatRemWir=false)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"));
end HardCase2;
