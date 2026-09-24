within Buildings.Templates.Plants.HeatPumps.Validation;
model HardCase1NLoadsCompliance
  "Validation of AWHP plant template with a distributed set of terminal loads"
  extends Buildings.Templates.Plants.HeatPumps.Validation.HardCase1NLoads(
    pla(use_cpl=true));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"),
  Documentation(
    info="<html>
<p>
  This model is identical to
  <a href=\"modelica://Buildings.Templates.Plants.HeatPumps.Validation.HardCase1NLoads\">
    Buildings.Templates.Plants.HeatPumps.Validation.HardCase1NLoads</a>
  except that a hydraulic compliance is added at the CHW and HW supply
  junctions of the isolation valve component, which provides a pressure state
  to each of these nodes.
</p>
</html>",
    revisions="<html>
<ul>
<li>
September 18, 2026, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end HardCase1NLoadsCompliance;
