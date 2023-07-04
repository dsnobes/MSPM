%{
Run this file to start MSPM!
this clears memory, runs a startup script which ensures
all necessary subdirectories are added to MATLAB's PATH,
and starts the GUI (which takes care of everything else)
%}

clear; clc;
startup();
SimulationInterfaceV5();
