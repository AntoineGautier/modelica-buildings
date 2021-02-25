model MinimumExample1
  model PipeBase
    parameter Modelica.SIunits.Length dh0;
  end PipeBase;

  model PipeAutosize
    extends PipeBase(dh0=dh);
    parameter Modelica.SIunits.Length dh
      "Hydraulic diameter (assuming a round cross section area)";
  initial equation
    dh0 = 1;
  end PipeAutosize;

  model ConnectionBase
    replaceable model PipeModel = PipeBase;
    PipeModel pip;
  end ConnectionBase;

  model ConnectionAutosize
    extends ConnectionBase(
      redeclare model PipeModel = PipeAutosize(dh=dh));
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
    parameter Modelica.SIunits.Length dhCon[nCon](each fixed=false);
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
