model MinimumExample1
  model PipeBase
    parameter Modelica.SIunits.Length dh0;
  end PipeBase;

  model PipeAutosize
    extends PipeBase(dh0=dh);
    parameter Modelica.SIunits.Length dh(
      fixed=false,
      start=0.2,
      min=0.01)
      "Hydraulic diameter (assuming a round cross section area)";

    final parameter Modelica.SIunits.PressureDifference dpStraightPipe_nominal(displayUnit="Pa")=
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

  model ConnectionBase
    replaceable model PipeModel = PipeBase;
    PipeModel pip;
  end ConnectionBase;

  model ConnectionAutosize
    extends ConnectionBase(
      redeclare model PipeModel = PipeAutosize(dh(fixed=true)=dh));
    parameter Modelica.SIunits.Length dh;
  end ConnectionAutosize;

  model DistributionBase
    replaceable ConnectionBase con[nCon];
    parameter Integer nCon;
  end DistributionBase;

  model DistributionAutosize
    extends DistributionBase(
      redeclare ConnectionAutosize con[nCon](
        dh=dhCon));
    parameter Modelica.SIunits.Length dhCon[nCon](
      each fixed=false,
      each start=0.2,
      each min=0.01);
  end DistributionAutosize;

  parameter Integer nCon=2;
  DistributionAutosize dis(nCon=nCon);

initial equation

  for i in 1:nCon loop
    Modelica.Utilities.Streams.print(
      "dis.dhCon[" + String(i) + "]=" + String(dis.dhCon[i]));
  end for;

  annotation (uses(Modelica(version="3.2.3")));
end MinimumExample1;
