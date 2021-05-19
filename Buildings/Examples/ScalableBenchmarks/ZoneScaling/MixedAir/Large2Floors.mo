within Buildings.Examples.ScalableBenchmarks.ZoneScaling.MixedAir;
model Large2Floors
  "Open loop model of a large building with 2 floors and 10 zones"
  extends Modelica.Icons.Example;

  replaceable package Medium = Buildings.Media.Air "Medium for air";
  parameter Integer numFlo = 2 "Number of floors";

  parameter String weaName = Modelica.Utilities.Files.loadResource(
    "modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos")
    "Name of the weather file";

  BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    filNam=weaName,
    computeWetBulbTemperature=false)
    "Weather data reader"
  annotation (Placement(transformation(extent={{-60,40},{-40,60}})));

  replaceable BaseClasses.MultiFloors flo constrainedby
    Buildings.Examples.ScalableBenchmarks.ZoneScaling.BaseClasses.PartialMultiFloors(
    numFlo=numFlo,
    redeclare package Medium = Medium) "Multiple floors of the office building"
    annotation (Placement(transformation(extent={{-80,-80},{60,0}})));

  // The ACHCor is perturbed below so that the floors evolve with different state trajectories
  Examples.VAVReheat.BaseClasses.MultiZoneVAV.Guideline36VAV vav[numFlo](
    each numVAV=5,
    VRoo={{flo.floors[i].VRooCor,flo.floors[i].VRooSou,flo.floors[i].VRooEas,
        flo.floors[i].VRooNor,flo.floors[i].VRooWes} for i in 1:numFlo},
    AFlo={{flo.floors[i].cor.AFlo,flo.floors[i].sou.AFlo,flo.floors[i].eas.AFlo,
        flo.floors[i].nor.AFlo,flo.floors[i].wes.AFlo} for i in 1:numFlo},
    ACH={{6*(0.95 + 0.1*(i - 1)/(numFlo - 1)),6,9,6,7} for i in 1:numFlo},
    each lat(displayUnit="deg") = 0.72902402855803)
    annotation (Placement(transformation(extent={{-20,20},{60,100}})));
equation
  connect(weaDat.weaBus, flo.weaBus) annotation (Line(
    points={{-40,50},{-30,50},{-30,4.70588},{15.9259,4.70588}},
    color={255,204,51},
    thickness=0.5));

  for fl in 1:numFlo loop
    connect(weaDat.weaBus, vav[fl].weaBus) annotation (Line(
      points={{-40,50},{-30,50},{-30,88},{-8,88}},
      color={255,204,51},
      thickness=0.5));
    connect(vav[fl].portsVAV[1, :], flo.portsCor[fl,:]) annotation (Line(
      points={{44,20.8},{44,-31.0588},{-13.1111,-31.0588}},
      color={0,127,255}));
    connect(vav[fl].portsVAV[2, :], flo.portsSou[fl,:]) annotation (Line(
      points={{44,20.8},{44,-32},{-14,-32},{-14,-48},{-13.1111,-48}},
      color={0,127,255}));
    connect(vav[fl].portsVAV[3, :], flo.portsEas[fl,:]) annotation (Line(
      points={{44,20.8},{44,-31.0588},{46,-31.0588}},
      color={0,127,255}));
    connect(vav[fl].portsVAV[4, :], flo.portsNor[fl,:]) annotation (Line(
      points={{44,20.8},{44,-32},{-14,-32},{-14,-15.0588},{-13.1111,-15.0588}},
      color={0,127,255}));
    connect(vav[fl].portsVAV[5, :], flo.portsWes[fl,:]) annotation (Line(
      points={{44,20.8},{44,-31.0588},{-45.2593,-31.0588}},
      color={0,127,255}));
    connect(flo.TRooAir[fl,:], vav[fl].TRooAir) annotation (Line(
      points={{62.5926,-30.5882},{62.5926,-30},{80,-30},{80,60},{64,60}},
      color={0,0,127}));
  end for;

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
end Large2Floors;
