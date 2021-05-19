within Buildings.Examples.ScalableBenchmarks.ZoneScaling.EnergyPlus;
model Large2Floors
  "Open loop model of a large building with 2 floors and 10 zones"
  extends Buildings.Examples.ScalableBenchmarks.ZoneScaling.MixedAir.Large2Floors(
    redeclare BaseClasses.MultiFloors flo(weaName=weaName))
    annotation (
experiment(
      StopTime=432000,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"),
Documentation(info="<html>
</html>", revisions="<html>
<ul>
<li>
March 25, 2021, by Baptiste Ravache:<br/>
First implementation.
</li>
</ul>
</html>"));

  annotation (Documentation(revisions="<html>
<ul>
<li>
March 25, 2021, by Baptiste Ravache:<br/>
First implementation.
</li>
</ul>
</html>"));
end Large2Floors;
