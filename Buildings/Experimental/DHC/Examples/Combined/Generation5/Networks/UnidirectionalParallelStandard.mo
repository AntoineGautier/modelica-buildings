within Buildings.Experimental.DHC.Examples.Combined.Generation5.Networks;
model UnidirectionalParallelStandard "Hydronic network for unidirectional parallel DHC system"
  extends Experimental.DHC.Networks.BaseClasses.PartialDistribution2Pipe(
    tau=5*60,
    redeclare BaseClasses.ConnectionParallelStandard con[nCon](
      final lDis=lDis,
      final lCon=lCon,
      final dhDis=dhDis,
      final dhCon=dhCon),
    redeclare model Model_pipDis = BaseClasses.PipeStandard (
      roughness=7e-6,
      fac=1.5,
      final dh(fixed=true)=dhEnd,
      final length=2*lEnd));
  parameter Modelica.SIunits.Length lDis[nCon]
    "Length of the distribution pipe before each connection (supply only, not counting return line)";
  parameter Modelica.SIunits.Length lCon[nCon]
    "Length of each connection pipe (supply only, not counting return line)";
  parameter Modelica.SIunits.Length lEnd
    "Length of the end of the distribution line (supply only, not counting return line)";
  parameter Modelica.SIunits.Length dhDis[nCon](
    each start=0.2,
    each min=0.01)
    "Hydraulic diameter of the distribution pipe before each connection";
  parameter Modelica.SIunits.Length dhCon[nCon](
    each start=0.2,
    each min=0.01)
    "Hydraulic diameter of each connection pipe";
  parameter Modelica.SIunits.Length dhEnd(
    start=0.2,
    min=0.01)
    "Hydraulic diameter of the end of the distribution line";
  annotation (Documentation(info="<html>
<p>
This model represents a two-pipe distribution network with built-in computation
of the pipe diameters based on the pressure drop per pipe length 
at nominal flow rate.
</p>
</html>", revisions="<html>
<ul>
<li>
February 23, 2021, by Antoine Gautier:<br/>
First implementation.
</li>
</ul>
</html>"));
end UnidirectionalParallelStandard;
