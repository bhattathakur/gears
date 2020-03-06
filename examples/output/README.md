[![home](https://img.shields.io/badge/gears-home-blue?style=flat)](../..)
[![examples](https://img.shields.io/badge/gears-examples-green?style=flat)](..)
[![ROOT](https://img.shields.io/badge/output-ROOT-orange?style=flat)](#root)

## Output
Generally speaking, the [visualization](../detector/#detector-visualization) of [detector](../detector) [geometry](../detector/#detector-construction) and the [screen dump](#screen-dump) of a [Geant4][] application can be all regarded as output of a [Geant4][] simulation. Strictly speaking, the output of a [Geant4][] simulation includes [histograms][] and/or [ntuples][] of data generated during the simulation, which can be used to reveal statistical distributions of, for example, positions and energy depositions of interactions.

[GEARS][] utilizes [Geant4 analysis managers]({{site.g4doc}}/Analysis/managers.html) to provide four output formats: [ROOT][] (default), [HDF5][], CSV, and XML. The output file format can be chosen using the following command:

~~~sh
$ make hdf5 # create ghdf5.cc from gears.cc
$ make # compile ghdf5.cc
~~~

The output file name can be chosen using macro command:

~~~
/analysis/setFileName output
~~~

No suffix is needed for the file name. Note that the output is disabled by default. It will be enabled if the output file name is not empty. So this macro command also works as a switch. Without it, no output file will be created.

[Geant4]: http://geant4.cern.ch
[histograms]:https://www.khanacademy.org/math/ap-statistics/quantitative-data-ap/histograms-stem-leaf/v/histograms-intro
[ntuples]:https://en.wikipedia.org/wiki/Tuple
[ROOT]:https://root.cern.ch
[HDF5]: https://www.hdfgroup.org/downloads/hdf5/
[GEARS]: http://physino.xyz/gears

### Screen dump

[Geant4][] can print out on screen detailed information of a simulation if you increase the verbose level of tracking using the macro command [/tracking/verbose]({{site.g4doc}}/Control/AllResources/Control/UIcommands/_tracking_.html), for example,

```sh
# turn on detailed screen dump
/tracking/verbose 2
# run a few events for debugging
/run/beamOn 10
# turn off screen dump for fast simulation
/tracking/verbose 0
# run a lot of events
/run/beamOn 100000
```

You can re-direct the screen dump to a file for detailed examination:

```sh
$ gears macro.mac | tee log
$ less log
```

### ROOT

The [ROOT][] version of [ntuples][] is [TTree][], which is commonly called a **tree**. Simply put, a tree is a table. Each row is called an entry and each column is called a branch. If you simulate 1000 events using [GEARS][], your [ROOT][] tree would have 1000 entries. If you save the first interaction position `x`, `y`, and `z` in the tree, your tree would have 3 branches, each holds 1000 values of `x`, `y`, or `z`. [ROOT][] [TTree][] offers the following features that are desired for analyzing data generated by [GEARS][]:

- It is designed to work with large data sets. For example, it can deal with Terra Bytes of data easily.
- It compresses data to save disk space.
- It can load individual branches separately for analysis, which requires relatively small memory compared to loading the whole table as many other analysis tools do.
- It provide [functions][] to create and analyze statistical distributions of data using multiple dimensional [histograms][].

[TTree]:https://root.cern.ch/doc/master/classTTree.html
[functions]:https://root.cern.ch/doc/master/classTTree.html#a8a2b55624f48451d7ab0fc3c70bfe8d7

## Step point

[Geant4][] follows a particle step by step when it passes through the simulated [geometry](../detector).
A step point is where a particle is generated or changed. A step point in [GEARS][] contains the following information:

* Track id (`trk` in short)
* Step number, starting from 0  (`stp` in short)
* Detector volume copy number (`vlm` in short)
* [Process id](#process-id) (`pro` in short)
* [Particle id](#particle-id) (`pid` in short)
* Parent id (`mom` in short)
* Energy deposited [keV] (`e` in short)
* Kinetic energy of the particle [keV] (`k` in short)
* global time `t0` [ns]
* global position `x0` [mm]
* global position `y0` [mm]
* global position `z0` [mm]
* local time `t` [ns]
* local position `x` [mm]
* local position `y` [mm]
* local position `z` [mm]

## Process id

The physics process generating each step point is saved in a variable `pro[n]`, where `n` is the index of the step point. It equals to (process type) * 1000 + (sub type). The Process types are defined in G4ProcessType.hh, sub types are defined in G4HadronicProcessType.hh, G4DecayProcessType.hh, G4EmProcessSubType.hh,  G4TransportationProcessType.hh, G4FastSimulationProcessType.hh, G4OpProcessSubType.hh, etc. They can be found at http://www-geant4.kek.jp/lxr/find?string=Type.hh

## Particle id

The type of particle related to a step point is saved in a variable `pdg[n]`. It is the same as the `PDG encoding` of the particle. A Google search will give more information about it.

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