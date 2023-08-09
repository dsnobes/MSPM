# MSPM (Modular Single-Phase Model)

![MSPM GUI Screenshot](/src/GUI/MSPM-GUI-Screenshot.png)

## Overview

MSPM is a software interface and numerical model for designing and modelling low-temperature Stirling engines. MSPM is a two-dimensional third-order model. Steven Middleton initially developped it at the University of Alberta to create a more suitable numerical model for low-temperature Stirling engine performance modelling. Middleton's work is recorded in his thesis, "A Modular Numerical Model for Stirling Engines and Single-Phase Thermodynamic Machines," available at [DOI](https://doi.org/10.7939/r3-x8qd-p159). MSPM will output simulation results like shaft power, temperature, pressure and pressure-volume (PV) loops.

### Units

MSPM uses units of:

- Meters for distances
- Pascals for pressures
- Joules for work
- Watts for power
- Simulated seconds for time
- Kelvin for temperatures
- RPM or Hz for rotational speed

### System Requirements

MSPM has only been tested to work on Windows 10/11, and requires [MATLAB](https://www.mathworks.com/products/matlab.html) to be installed. MATLAB 2023a is the only version that has been thoroughly tested, although previous and later versions of MATLAB may work as well.

## Main Functionality

A range of functionality is built into MSPM to facilitate modelling and simulation. These include:

- Modelling a Stirling engine, including the mechanism and heat exchangers
- Running a combined thermodynamic and mechanical simulation of a modelled Stirling engine
- Running a test set with different engines and environmental parameters automatically
  - Both single- and multi-threaded options
- Optimizing engine dimensions, engine speed and charge pressure using a gradient ascent algorithm

## Installation

MSPM is written in MATLAB and has been tested to work in MATLAB version 2023a, therefore a major requirement for the installation of MSPM is to have MATLAB installed. Once MATLAB has been installed, download MSPM. This can be done by git cloning the repository or downloading the release ZIP file and unpacking it. Place the MSPM folder in a location of your choice. At this point the installation is complete and everything should work as expected. Simply open the MSPM folder in MATLAB and run the [Run.m](/Run.m) file to start up MSPM. Alternatively, double-click the [MSPM.bat](/MSPM.bat) file in the MSPM folder to launch MSPM.

### MATLAB Toolboxes Required

No MATLAB toolboxes are required for the core functionality of MSPM. However, running parallel test sets will only work if the **[Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html)** is installed. This is the only optional toolbox that MSPM uses, and is only needed for running parallel test sets. Single-threaded test sets can be run with or without this toolbox.

## Sample Models

There are 3 sample models provided in the **[Sample Models](/Sample_Models)** folder. These models are fully functional, feel free to use them to assist in learning how to use MSPM.

## Full Documentation

Full documentation can be found **[here](/docs)** in /docs in the repository.
