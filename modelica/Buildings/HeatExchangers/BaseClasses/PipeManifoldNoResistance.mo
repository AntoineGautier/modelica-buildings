model PipeManifoldNoResistance "Manifold for heat exchanger register" 
  extends PartialPipeManifold;
annotation (Diagram,
Documentation(info="<html>
<p>
Pipe manifold without flow resistance.</p>
</p>
<p>
This model connects the flows between the ports without 
modeling flow friction. The model is used in conjunction with
a manifold which contains pressure drop elements and that
is added to the other side of the heat exchanger registers.
</p>
</html>",
revisions="<html>
<ul>
<li>
April 14, 2008, by Michael Wetter:<br>
First implementation.
</li>
</ul>
</html>"));
equation 
  for i in 1:nPipPar loop
    connect(port_a, port_b[i]) annotation (points=[-100,5.55112e-16; -2,
          5.55112e-16; -2,5.55112e-16; 100,5.55112e-16],
                                     style(color=69, rgbcolor={0,127,255}));
  end for;
end PipeManifoldNoResistance;
