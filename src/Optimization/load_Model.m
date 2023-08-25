%{
   Modular Single Phase Model - MSPM. A program for simulating single phase cyclical thermodynamic machines.
   Copyright (C) 2023  David Nobes
      Mailing Address:
         University of Alberta
         Mechanical Engineering
         10-281 Donadeo Innovation Centre For Engineering
         9211-116 St
         Edmonton
         AB
         T6G 2H5
      Email: dnobes@ualberta.ca

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
%}

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

