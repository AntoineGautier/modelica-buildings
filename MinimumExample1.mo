model MinimumExample1

  model PipeAutosize
    parameter Modelica.SIunits.Length dh(
      fixed=false,
      start=0.2,
      min=0.01)
      "Hydraulic diameter (assuming a round cross section area)";
    final parameter Modelica.SIunits.PressureDifference dpStraightPipe_nominal(
      displayUnit="Pa")=
        Modelica.Fluid.Pipes.BaseClasses.WallFriction.Detailed.pressureLoss_m_flow(
          m_flow=1,
          rho_a=1.2,
          rho_b=1.2,
          mu_a=0.001,
          mu_b=0.001,
          length=1,
          diameter=dh,
          roughness=2.5e-5,
          m_flow_small=1e-4)
    "Pressure loss of a straight pipe at m_flow_nominal";
    initial equation
      dpStraightPipe_nominal = 200;
  end PipeAutosize;

  PipeAutosize pip;

initial equation

  Modelica.Utilities.Streams.print("pip.dh=" + String(pip.dh));

  annotation (uses(Modelica(version="3.2.3")));
end MinimumExample1;
