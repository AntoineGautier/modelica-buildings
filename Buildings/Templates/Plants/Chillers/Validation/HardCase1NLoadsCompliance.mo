within Buildings.Templates.Plants.Chillers.Validation;
model HardCase1NLoadsCompliance
  "Validation of chiller plant template with a distributed set of terminal loads"
  extends Buildings.Templates.Plants.Chillers.Validation.HardCase1NLoads(
    pla(intChi(use_cpl=true)));
annotation(experiment(StopTime=86400,
  Tolerance=1e-06,
  __Dymola_Algorithm="Cvode"),
  Documentation(
    info="<html>
<p>
  This model is identical to
  <a href=\"modelica://Buildings.Templates.Plants.Chillers.Validation.HardCase1NLoads\">
    Buildings.Templates.Plants.Chillers.Validation.HardCase1NLoads</a>
  except that a hydraulic compliance is added at the CHW supply junction of
  the chiller group interface, which provides a pressure state to that node.
</p>
</html>",
    revisions="<html>
<ul>
<li>
September 21, 2026, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end HardCase1NLoadsCompliance;
