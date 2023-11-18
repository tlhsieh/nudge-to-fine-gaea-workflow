# nudge-to-fine-stellar-workflow

This repository contains example configuration files and code for running AI2's
nudge-to-fine corrective machine learning workflow (e.g., [Bretherton et al.,
2022](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2021MS002794);
[Clark et al.,
2022](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2022MS003219);
[Kwa et al.,
2023](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2022MS003400);
[Sanford et al.,
2023](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2023MS003809))
bare-metal on [Princeton's Stellar computing
cluster](https://researchcomputing.princeton.edu/systems/stellar). The example
illustrates all steps of the workflow, using coarsened data from a
control-climate C3072 resolution X-SHiELD simulation as a reference ([Cheng et
al.,
2022](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2022GL099796)),
and learning to correct errors of a C48 resolution version of
[FV3GFS](https://github.com/ai2cm/fv3gfs-fortran).  As in Sanford et al. (2023),
we configure and train ML models to correct the temperature, moisture,
horizontal winds, and surface radiative fluxes (we omit novelty detection). To
keep computation costs relatively small, the simulations in this example
workflow are set up to run for 40 days, but data is available to run for
multiple years.

Through some careful templating, the code in this repository is set up such that
any user of Stellar should be able to clone it themselves, and immediately step
through each of the `make` rules, which cover all the steps from installing the
required software, to running simulations, training machine learning models, and
evaluating skill.  Some details about how to step through the `make` rules-and
what each of them mean-can be found below.

## Verification data

As described above, the verification data for this example comes from a
two-plus-year C3072 X-SHiELD simulation run on Stellar.  This simulation was
configured to produce online-coarsened diagnostics and restart files every three
hours to C384 resolution.  To prepare this raw data for use in this workflow, it
is required to further coarsen these fields to C48 resolution, concatenate the
diagnostics datasets into cohesive zarr stores, and organize the further
coarsened restart files into an expected directory structure.  This was done in
[a separate computationally intensive
workflow](https://github.com/ai2cm/PIRE-post-processing-worfklow). The outputs
of this workflow were saved on Stellar here:
`/scratch/cimes/skclark/2023-09-18-PIRE-X-SHiELD-post-processing` and are
referenced and used in this repository.  While the example in this repository
only leverages roughly 40 days of post-spinup data from the control-climate
simulation, the data from the entire two-plus-year lengths of the four X-SHiELD
simulations carried out by Kai-Yuan were post-processed.  We will take the
availability of this post-processed data as given; no action is needed on your
part.

## Quickstart

### Installation

To run the example workflow, start by cloning this repository on Stellar and
running the `make install` rule:

```
$ git clone https://github.com/ai2cm/nudge-to-fine-stellar-workflow.git
$ cd nudge-to-fine-stellar-workflow
$ make install
```

This rule will begin by initializing all the submodules in the repository,
starting from a recent commit of [fv3net](https://github.com/ai2cm/fv3net), and
proceed to build two environments:

- `fv3net-prognostic-run`
- `fv3net-image`

These environments are analogs of the environments built within the
`prognostic_run` and `fv3net` Docker images we use when running experiments in
the cloud.  The `fv3net-prognostic-run` environment includes and installation of
the Python-wrapped version of FV3GFS, and therefore in addition to a number of
Python dependencies, requires the compilation of the FV3GFS model and its
dependencies, FMS, ESMF, and NCEPlibs.  The process of compiling and installing
all of this software will take thirty minutes to an hour to complete.  The
software itself, including Python packages, will be installed into a top-level
`install` directory.

Once the installation phase is complete, we are ready to move on to running the
steps of the workflow.

### Initializing the experiment

Before we can run any simulations, we first need to take care of some
housekeeping, i.e. setting up some empty directories for later use, and
generating some reference datasets.  This involves running the following steps:

```
$ make initialize_experiment
$ make rename_verification_variables
$ make build_catalog
```

More specifically, the steps do the following:

- The `initialize_experiment` rule will create several directories within the
  designated `SCRATCH_ROOT` directory defined near the top of the `Makefile`.
  By default this directory points to
  `/scratch/cimes/$(USER)/$(EXPERIMENT_NAME)`, but you are welcome to modify
  that as you see fit.  It will also copy some FV3GFS-related reference data
  into a directory that you own.
- The `rename_verification_variables` rule will generate copies of three
  verification datasets with variables renamed to match fv3net's expectations.
  Note this rule submits some short-running batch jobs, so it is recommended to
  wait until those jobs complete before proceeding forward.
- The `build_catalog` rule will produce an
  [`intake`](https://intake-xarray.readthedocs.io/en/latest/)-compatible catalog
  YAML file, which points to these renamed verification datasets and some C48
  grid-related reference data.

Once this initial infrastructure has been set up, we can move on to setting up
some C48 baseline and nudged simulations.

### Baseline and nudged simulations

Two important simulations for our corrective machine learning work are the
baseline and nudged runs.  The C48 baseline simulation represents the skill of
the C48 model without any corrections; while the C48 nudged simulation is used
to generate a training dataset of paired coarse model states and corrective
tendencies.  Both of these simulations can be run at this moment in the
workflow.  

To set these up, we first need to generate "prescriber" datasets, which put
reference data into a form that it can be used to force aspects of the ocean
and/or land surface of these runs.  Because the reference C3072 simulation was
run with a mixed layer ocean, nudged to observed sea surface temperatures and
prescribed observed sea ice, we prefer to run the C48 simulations with identical
ocean boundary conditions.  In addition, to prevent the land surface from
drifting in the nudged run, we prescribe the surface radiative fluxes and
precipitation rate seen by the land surface model (note we do not prescribe land
surface forcings in the baseline or ML-corrected runs).  The ocean and land
prescriber datasets can be generated by running:

```
$ make prescriber_datasets
```

Once the two batch jobs complete--it should be fast--you can then submit the
baseline and nudged runs:

```
$ make baseline_run
$ make nudged_run
```

Calling these rules will automatically trigger rules to generate baseline and
nudged run configuration files from template YAML files, with the appropriate
paths filled in.  The simulations are configured to be run in four segments of
ten days each (the segments will resubmit automatically).  The baseline run will
finish relatively quickly, while the nudged run will take a few hours to
complete.  We cannot proceed to the next step of the workflow until the nudged
run completes.

### Training ML models

Once the nudged run completes, we can move on to preparing data for and training
machine learning models.  To prepare several configuration files and construct
training datasets, run the following rule:

```
$ make netcdf_batches
```

This rule will run all code necessary to build datasets used in training,
validation, and testing of three machine learning models: one to predict the
temperature and specific humidity corrective tendencies, one to predict the
horizontal wind corrective tendencies, and one to predict the shortwave
transmissivity and downward longwave radiative flux at the surface.  Once the
final batch jobs from this rule complete, we can move on to training models by
running:

```
$ make train
```

This is the most time-consuming step of this example workflow.  The neural
networks are configured to train for up to 500 epochs, though an "early
stopping" callback, which halts model training once the validation loss
plateaus, typically tends to limit them to a couple hundred.  This training
process can take over ten hours, so it is best to let run overnight.

### Evaluating offline skill

As a sanity check on the machine learning models we trained, we can evaluate
their skill in making predictions on held out test samples using our offline
report tool.  To generate an offline report for each of the models use:

```
$ make offline_report
```

This will submit three batch jobs (one for each ML model).  When finished, three
reports will have been generated and will end up here:
`/scratch/cimes/$USER/example/offline/reports`.  These reports are HTML-based
and are perhaps easiest to view in your local browser (i.e. on your laptop)
rather than on Stellar.  This is how you might download them locally:

```
scp -r stellar:/scratch/cimes/$USER/example/offline/reports .
```

Example reports can be found here:

- [T, q
  model](https://storage.googleapis.com/vcm-ml-public/spencerc/2023-11-17-example-stellar-workflow-offline-reports/tq-model/index.html)
- [u, v
  model](https://storage.googleapis.com/vcm-ml-public/spencerc/2023-11-17-example-stellar-workflow-offline-reports/uv-model/index.html)
- [Flux
  model](https://storage.googleapis.com/vcm-ml-public/spencerc/2023-11-17-example-stellar-workflow-offline-reports/fluxes-model/index.html)

### Running an ML-corrected simulation

If offline skill looks reasonable, we are free to submit the ML-corrected
simulation, which uses the corrective tendency and radiative flux models to
correct an otherwise free-running C48 simulation at each timestep:

```
$ make ml_corrected_run
```

This will take a similar amount of wall-clock time as the nudged run.  Once this
completes, we can move on to evaluating online skill to see if the ML models
successfully reduced biases of the C48 model relative to the no-ML baseline.

### Evaluating online skill

To generate a prognostic run report, all that is left is to run the following
two rules:

```
$ make prognostic_run_diags
$ make prognostic_run_report
```

Note that `prognostic_run_diags` submits batch jobs to compute diagnostics for
each of the simulations.  Since we have included the movie-generation code, this
will take several hours to complete.  Once this is done, however, we can make
the HTML report using `prognostic_run_report`.  This will compare the baseline
and ML-corrected simulations together relative to the verification dataset.  An
example report from this workflow can be found
[here](https://storage.googleapis.com/vcm-ml-public/spencerc/2023-11-17-example-stellar-prognostic-run-report/index.html).

For custom analysis it is best to look at the raw output from the simulations,
which can be found conveniently/automatically processed into multi-segment zarr
stores within the directories here: `/scratch/cimes/$USER/example/simulations`.

## Further details

The `make` rules in this repository handle a lot of the hard work that goes into
configuring simulations and ML models (see the template configuration files
committed in the `configs` directory of this repository, and the additional
configs generated locally when stepping through the workflow).  To extend this
workflow for a custom application, you will need to learn how the different
configuration files are set up and used.  Some information about this can be
found in the [fv3net
documentation](https://vulcanclimatemodeling.com/docs/fv3net/index.html), though
looking at examples like this or the code repositories associated with AI2's
publications can also be illuminating (beware, however, that APIs have changed
over the years, and old configs may not be drop-in compatible).

## Acknowledgements

Porting the corrective ML workflow to run on Stellar was accomplished with help
from Mykhailo Rudko, a Computational Scientist at Princeton University, funded
through the NOAA Information Technology Incubator.
