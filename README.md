[![Documentation](https://codedocs.xyz/jintonic/gears.svg)](https://codedocs.xyz/jintonic/gears/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Code size](https://img.shields.io/github/languages/code-size/jintonic/gears.svg?style=flat)
![](https://img.shields.io/github/languages/top/jintonic/gears.svg?style=flat)

[GEARS][] is a [Geant4][] [Example Application](https://geant4.kek.jp/lxr/source/examples/) with [Rich features](#features) yet Small footprint. The entire C++ coding is minimized down to a single file with about 600 [SLOC][]. This is achieved mainly by utilizing [Geant4][] plain [text geometry description][tg], [build-in UI commands][TUI] (macros), and C++ inheritance. It is ideal for student training and fast implementation of small to medium-sized experiments.

## Features

* [Single small C++ file](https://github.com/jintonic/gears/blob/master/gears.cc)
  * [Easy code browsing](https://codedocs.xyz/jintonic/gears/gears_8cc.html#a3c04138a5bfe5d72780bb7e82a18e627)
  * Easy management and fast [compilation](https://github.com/jintonic/gears/blob/master/makefile) (a few second on a regular PC)
* [Output in multiple data format](#output)
  * [ROOT](#root) TTree format (default, no ROOT installation is needed)
    * Build-in data compression, well suitable for large data processing
    * Fast access to independent data members
    * Flat tree (no nested branches or arrays) with short leaf names
      * Easy to use in TTree::Draw
      * No need to load extra library to open
  * HDF5, universal data format, easy to read by different tools
  * CSV or XML, Human readable ASCII file, capable of dealing with multiple dimensional arrays
* [Record information of step 0](#record-information-of-step-0) (initStep)
  * This is not available from G4UserSteppingAction
* [simple text][tg] or [GDML][] geometry I/O
  * Fast implementation of [detector geometry](https://github.com/jintonic/gears/blob/master/examples/detector/README.md) without C++ programming
  * Create/Change geometry without re-compilation
  * Turn off data saving in a volume by assigning it a non-positive copy number
  * Turn any volume to a sensitive detector by adding "(S)" in its name
  * Assign optical properties in [Geant4][] plain [text geometry description][tg]
* Optional optical and hadronic physics
* Periodic status report in a long run
* Frequently used source spectra (AmBe, Am-241, etc.)
* [Doxygen documentation](https://codedocs.xyz/jintonic/gears/)
* Many sample macros and geometry descriptions for feature demonstration

## Getting started

### Prerequisites

* [Geant4][], version above 9 is requested due to the following inconvenience in version 9: <http://hypernews.slac.stanford.edu/HyperNews/geant4/get/hadronprocess/1242.html>.
* (Optional) [Xerces-C++ XML Parser](https://xerces.apache.org/xerces-c/), if you'd like to use or export detector geometries defined in [GDML][] format.
* (Optional) [HDF5][], if you'd like to save the simulation result in [HDF5][] format.

### Get GEARS

You can download [GEARS][] as a `.tar.gz` or `*.zip` file from its [homepage](http://physino.xyz/gears) or [GitHub page](https://github.com/jintonic/gears), and run the following to unzip it:

```sh
$ unzip gears-master.zip # if you downloaded the zip file
$ tar xfvz jintonic-gears-commitID.tar.gz # if you download the tar.gz file
$ mv jintonic-gears-commitID gears # rename the directory
```

If you know how to use [Git][], you can download the whole [GEARS repository from GitHub](https://github.com/jintonic/gears):

```sh
$ git clone https://github.com/jintonic/gears.git
```

This way, you can update your [GEARS][] using

```sh
$ cd /path/to/gears
$ git pull
```

### Compilation

[GEARS][] is shipped with a simple [makefile](https://github.com/jintonic/gears/blob/master/makefile). Simply type `make` to compile [gears.cc](https://github.com/jintonic/gears/blob/master/gears.cc) to generate the executable `gears`:

```sh
$ git clone https://github.com/jintonic/gears.git
$ cd gears
$ make # compile gears.cc
$ export PATH=/path/to/gears:$PATH
$ export LD_LIBRARY_PATH=/path/to/geant4/libs:$LD_LIBRARY_PATH # for Linux
$ export DYLD_LIBRARY_PATH=/path/to/geant4/libs:$DYLD_LIBRARY_PATH # for MAC
$ gears # run gears
```

### User interface

[GEARS][] relies on [G4UIExecutive](http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/GettingStarted/graphicalUserInterface.html#how-to-select-interface-in-your-applications) to select a user interface (UI). Without any specific setup, [GEARS][] will try to run a graphic user interface (GUI) based on [Qt][]. If your [Geant4][] is not compiled with [Qt][] support, [GEARS][] will try to [use a command-line UI that behaves like a tcsh](http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/GettingStarted/graphicalUserInterface.html#g4uiterminal). Run the following command to check if your [Geant4][] is compiled with [Qt][]

```sh
$ geant4-config --help | grep qt
```

If the output is `qt[yes]`, then you should be able to use the [Qt][] based GUI. If you can't, please check if you set the environment variable `G4UI_USE_TCSH` to `1` somewhere:

```sh
$ env |grep G4UI
```

If yes, change it to `G4UI_USE_QT=1` instead, and run `gears` again.

If none of the `G4UI_USE_XXX` variables is set, check if you have `~/.g4session` with the following line in it:

```sh
tcsh
```

If yes, add one more line to it:

```sh
gears qt
```

so that you can use [Qt][] based GUI with [GEARS][], while run other [Geant4][] applications with command-line based UI.

# Physics

## Physics list

Since it requires a lot of knowledge to set up a correct physics list, [Geant4][] provides some pre-packaged physics lists. Three are enabled by default in [GEARS][]:

- G4DecayPhysics, it defines particle decays. It defines more particles than G4EmStandardPhysics does, so it has to be enabled before optional hadronic physics, otherwise the later will complain about missing particle definitions.
- G4RadioactiveDecayPhysics, it defines nuclear decays.
- G4EmStandardPhysics, it has to be defined after G4RadioactiveDecayPhysics, otherwise nuclei cannot get their energy state information and won't decay. No [Geant4][] documentation warns it.

Three optional lists (G4OpticalPhysics, G4HadronElasticPhysicsHP, G4HadronPhysicsFTFP_BERT_HP) can be enabled using [Geant4][] macros:

~~~
  # has to be called before /run/initialize
  /physics_lists/enable Optical
  /physics_lists/enable HadronElastic
  /physics_lists/enable HadronInelastic
~~~

### Physics processes

Run `/process/list` after `/run/initialize`, and you will get

~~~
     Transportation,              Decay,   RadioactiveDecay,                msc
              hIoni,            ionIoni,             hBrems,          hPairProd
        CoulombScat,              eIoni,              eBrem,            annihil
               phot,              compt,               conv,             muIoni
            muBrems,         muPairProd,         hadElastic,   neutronInelastic
           nCapture,           nFission,    protonInelastic,       pi+Inelastic
       pi-Inelastic,     kaon+Inelastic,     kaon-Inelastic,    kaon0LInelastic
    kaon0SInelastic,    lambdaInelastic,anti-lambdaInelastic,   sigma-Inelastic
anti_sigma-Inelastic,    sigma+Inelastic,anti_sigma+Inelastic,     xi-Inelastic
  anti_xi-Inelastic,       xi0Inelastic,  anti_xi0Inelastic,    omega-Inelastic
anti_omega-Inelastic,anti_protonInelastic,anti_neutronInelastic,anti_deuteronInelastic
anti_tritonInelastic,  anti_He3Inelastic,anti_alphaInelastic
~~~

Now you can use, for example, `/process/inactivate nCapture` to disable neutron capture process in your simulation. And you can use, for example, `/process/setVerbose 20 RadioactiveDecay` to change the verbosity of the radioactive decay process.

Individual optical processes can be toggled by the following commands:

~~~
/process/optical/processActivation Cerenkov true/false
/process/optical/processActivation Scintillation true/false
/process/optical/processActivation OpAbsorption true/false
/process/optical/processActivation OpRayleigh true/false
/process/optical/processActivation OpMieHG true/false
/process/optical/processActivation OpBoundary true/false
/process/optical/processActivation OpWLS true/false
~~~

Detailed control of radioactive decay is provided by the /[grdm]/ command, for example,

~~~
/grdm/deselectVolume chamber # disabled radioactive decay in volume "chamber"
/grdm/nucleusLimits 1 80 # enabled radioactive decay only when z in [1, 80]
~~~

# Output

## Output format
[GEARS][] utilizes [Geant4 analysis managers](http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Analysis/managers.html) to provide 4 output formats: ROOT (default), HDF5, CSV, and XML. The output file format can be chosen using the following command:

~~~sh
make hdf5 # create ghdf5.cc from gears.cc
make # compile ghdf5.cc
~~~

The output file name can be chosen using macro command:

~~~
/analysis/setFileName output
~~~

No suffix is needed for the file name.

### ROOT

ROOT use TTree to save data. TTree have entry and branch to build their data structure. Each branch is a variable listed in [Track Points](#track-point), and each entry is a event. ROOT will compress the data, so it will cost less disk space. ROOT can load part of data, which can save time when it get large.

## Track point

A track point is a concept introduced in [GEARS][]. It is a point where a track is generated or changed. It records the following information:

* Track id (`trk` in short)
* Step number, starting from 0  (`stp` in short)
* Detector volume copy number (`det` in short)
* [Process id](#process-id) (`pro` in short)
* [Particle id](#particle-id) (`pid` in short)
* Parent id (`mom` in short)
* Energy deposited [keV] (`e` in short)
* Kinetic energy of the track [keV] (`k` in short)
* global time [ns] (`t` in short)
* x [mm]
* y [mm]
* z [mm]

## Process id

The physics process generating each track point is saved in a variable `pro[n]`, where `n` is the index of the track point. It equals to (process type) * 1000 + (sub type). The Process types are defined in G4ProcessType.hh, sub types are defined in G4HadronicProcessType.hh, G4DecayProcessType.hh, G4EmProcessSubType.hh,  G4TransportationProcessType.hh, G4FastSimulationProcessType.hh, G4OpProcessSubType.hh, etc. They can be found at http://www-geant4.kek.jp/lxr/find?string=Type.hh

## Particle id

The type of particle related to a track point is saved in a variable `pdg[n]`. It is the same as the `PDG encoding` of the particle. A Google search will give more information about it.

## Record information of step 0

One cannot get access to step 0 (initStep printed on screen if `/tracking/verbose` is set to be more than 0) through [G4UserSteppingAction][], which only provides access to step 1 and afterwards. However, step 0 contains some very important information that is constantly requested by the user. For example, the energy of a gamma ray from a radioactive decay is only available from step 0. Such information can be easily displayed using the following ROOT command with the Output ROOT tree, `t`:

~~~cpp
  // draw kinetic energy, "k", of a gamma (pdg==22)
  // created by radioactive decay process (pro==6210)
  t->Draw("k","pro==6210 && pdg==22")
~~~

This is achieved by using [G4SteppingVerbose][] instead of [G4UserSteppingAction][] for data recording. The former provides a function called [TrackingStarted][]() to print verbose information about step 0 on screen if `/tracking/verbose` is set to be more than 0. It also provides a function called [StepInfo][]() to print verbose information about steps after step 0 on screen if `/tracking/verbose` is more than 0. [G4SteppingVerbose][]::[StepInfo][]() is called right before [G4UserSteppingAction][]::[UserSteppingAction][]([G4Step][]*) is called in [G4SteppingManager][]::[Stepping][](), it hence can be used to fully replace the functionality of [G4UserSteppingAction][]::[UserSteppingAction][]([G4Step][]*).

In fact, [G4UserSteppingAction][]::[UserSteppingAction][]([G4Step][]*) is not used at all in [GEARS][]. The Output class inherits [TrackingStarted][]() and [StepInfo][]() from [G4SteppingVerbose][] to record data from all steps. There is another advantage of using [G4SteppingVerbose][] instead of [G4UserSteppingAction][] for recording, that is, [G4SteppingVerbose][] is provided as a globally available singleton, which can be easily accessed at different places in the codes using:

~~~cpp
  G4VSteppingVerbose::GetInstance()
~~~

This is used in [G4UserRunAction][] to open and close a TFile, in [G4UserEventAction][] to fill a TTree.

The catch is that functions in [G4SteppingVerbose][] will not be called in [G4SteppingManager][] unless `/tracking/verbose` is set, which will print too much information on screen for a long run. This is solved in EventAction::BeginOfEventAction by turning on tracking verbose all the time so that all functions in [G4SteppingVerbose][] will be called, while at the same time, turning on [G4SteppingVerbose][] local verbose flag [Silent][] to run them in silent mode.


# Coding convention

## G4cout VS std::cout

`G4cout` and `G4endl` is preferred over `std:cout` and `std:endl` because the former handle the output in [Geant4][] GUI correctly, while the later can only output to terminal.

# To-do's

- examples
  - add an example to show how QE can be implemented
  - add an example to show how one can use uproot to load ROOT file
  - add examples to show how one can distribute source in a volume or surface
- new functions
  - time chopping of radioactive decay chain

[GEARS]: https://github.com/jintonic/gears
[tg]: http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Detector/Geometry/geomASCII.html
[TUI]: http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Control/commands.html
[SLOC]: https://en.wikipedia.org/wiki/Source_lines_of_code
[ROOT]: https://root.cern.ch
[Geant4]: http://geant4.cern.ch
[NIST]: http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Appendix/materialNames.html#g4matrdb
[run]: http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Control/AllResources/Control/UIcommands/_run_.html
[listMaterials]: http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Control/AllResources/Control/UIcommands/_material_nist_.html
[G4OpBoundaryProcess]: http://www-geant4.kek.jp/lxr/source//processes/optical/include/G4OpBoundaryProcess.hh
[PostStepDoIt]: http://www.apc.univ-paris7.fr/~franco/g4doxy4.10/html/class_g4_op_boundary_process.html#a70a65cc5127a05680a0c4679f8300871
[G4LogicalBorderSurface]: http://www-geant4.kek.jp/lxr/source/geometry/volumes/include/G4LogicalBorderSurface.hh
[grdm]:http://geant4-userdoc.web.cern.ch/geant4-userdoc/UsersGuides/ForApplicationDeveloper/html/Control/AllResources/Control/UIcommands/_grdm_.html
[G4Track]: http://www-geant4.kek.jp/lxr/source/track/include/G4Track.hh
[G4Step]: http://www-geant4.kek.jp/lxr/source/track/include/G4Step.hh
[G4UserSteppingAction]:http://www-geant4.kek.jp/lxr/source/tracking/include/G4UserSteppingAction.hh
[UserSteppingAction]:http://www-geant4.kek.jp/lxr/source/tracking/include/G4UserSteppingAction.hh
[G4SteppingVerbose]: http://www-geant4.kek.jp/lxr/source/tracking/include/G4SteppingVerbose.hh
[G4SteppingManager]: http://www-geant4.kek.jp/lxr/source/tracking/include/G4SteppingManager.hh
[G4UserRunAction]: http://www-geant4.kek.jp/lxr/source/run/include/G4UserRunAction.hh
[G4UserEventAction]: http://www-geant4.kek.jp/lxr/source/event/include/G4UserEventAction.hh
[Silent]: http://www-geant4.kek.jp/lxr/source/tracking/src/G4VSteppingVerbose.cc#L50
[Stepping]: http://www-geant4.kek.jp/lxr/source/tracking/src/G4SteppingManager.cc#L116
[StepInfo]: http://www-geant4.kek.jp/lxr/source/tracking/src/G4SteppingManager.cc#L228
[TrackingStarted]: http://www-geant4.kek.jp/lxr/source/tracking/src/G4SteppingManager.cc#L360
[GDML]: https://gdml.web.cern.ch/GDML/
[md]: https://en.wikipedia.org/wiki/Markdown
[HTML]: https://www.w3schools.com/html/
[HDF5]: https://www.hdfgroup.org/downloads/hdf5/
[Qt]: https://doc.qt.io/
[Git]: https://en.wikipedia.org/wiki/Git
