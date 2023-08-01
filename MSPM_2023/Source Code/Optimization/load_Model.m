function Model = load_Model(name)
    newfile = [pwd '/Saved Files/' name];
    File = load(newfile,'Model');
    Model = File.Model;
    Model.AxisReference = gca;

    Model.showPressureAnimation = false;
    Model.recordPressure = false;
    Model.showTemperatureAnimation = false;
    Model.recordTemperature = false;
    Model.showVelocityAnimation = false;
    Model.recordVelocity = false;
    Model.showTurbulenceAnimation = false;
    Model.recordTurbulence = false;
    Model.recordOnlyLastCycle = true;
    Model.recordStatistics = true;
    Model.outputPath= '';
    Model.warmUpPhaseLength = 0;
    Model.animationFrameTime = 0.05;
end

