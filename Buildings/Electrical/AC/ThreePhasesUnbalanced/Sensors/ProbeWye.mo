within Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors;
model ProbeWye
  "Model of a probe that measures voltage magnitude and angle (Wye configuration)"
  extends
    Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors.BaseClasses.GeneralizedProbe;
  Interfaces.WyeToWyeGround wyeToWyeGround
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={20,0})));
equation
  for i in 1:3 loop
      theta[i] = (180.0/Modelica.Constants.pi)*Buildings.Electrical.PhaseSystems.OnePhase.phase(wyeToWyeGround.wyeg.phase[i].v);
      if PerUnit then
        V[i] = Buildings.Electrical.PhaseSystems.OnePhase.systemVoltage(wyeToWyeGround.wyeg.phase[i].v)/(V_nominal/sqrt(3));
      else
        V[i] = Buildings.Electrical.PhaseSystems.OnePhase.systemVoltage(wyeToWyeGround.wyeg.phase[i].v);
      end if;
  end for;

  connect(term, wyeToWyeGround.wye) annotation (Line(
      points={{0,-90},{0,4.44089e-16},{10,4.44089e-16}},
      color={0,120,120},
      smooth=Smooth.None));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={
        Line(
          points={{0,-10},{0,-30},{-14,-44}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5),
        Line(
          points={{0,-30},{14,-44}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5)}),         Documentation(info="<html>
<p>
This model represents a probe that measures the RMS voltage and the angle
of the voltage phasors (in degrees) at a given point. The probes are connected
in Wye (Y) grounded configuration.
</p>
</html>", revisions="<html>
<ul>
<li>
June 6, 2014, by Marco Bonvini:<br/>
First implementation.
</li>
</ul>
</html>"),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,
            100}}), graphics));
end ProbeWye;
