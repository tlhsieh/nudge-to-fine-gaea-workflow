ROOT=$(shell pwd)

FV3NET_COMMIT=92c808d13748f165d9fdaa8c0c7714f82f024eea
PROGNOSTIC_RUN_ENVIRONMENT=fv3net-prognostic-run
FV3NET_IMAGE_ENVIRONMENT=fv3net-image
EXPERIMENT_NAME=C384
SCRATCH_ROOT=/gpfs/f5/gfdl_w/scratch/$(USER)/$(EXPERIMENT_NAME)

FV3NET_DIR=$(ROOT)/fv3net
INSTALL_DIR=$(ROOT)/install
CONFIG_DIR=$(ROOT)/configs
CONFIG_TEMPLATES=$(CONFIG_DIR)/templates
SCRIPTS_DIR=$(ROOT)/scripts
SLURM_LOG_DIR=$(ROOT)/slurm-logs
CONDA_RUN=$(SCRIPTS_DIR)/conda_run.sh

# Environments
ENVIRONMENT_SCRIPTS=$(SCRIPTS_DIR)/environment

# Local grid and verification data catalog
CATALOG_SCRIPTS=$(SCRIPTS_DIR)/catalog
CATALOG_DIR=$(SCRATCH_ROOT)/catalog
COPY_CATALOG_REFERENCE_DATA=$(CATALOG_SCRIPTS)/copy_reference_data_C384.sh
FILL_CATALOG_TEMPLATE=$(CATALOG_SCRIPTS)/fill_template.py
CATALOG_TEMPLATE=$(CONFIG_TEMPLATES)/catalog_C384.yaml
CATALOG=$(CONFIG_DIR)/catalog.yaml

# Verification data
VERIFICATION_TAG=pire_xshield_control
VERIFICATION_DATASETS = pire_atmos_dyn_3h_coarse_inst.zarr pire_atmos_phys_3h_coarse.zarr pire_atmos_dyn_plev_coarse_3h.zarr
VERIFICATION_SCRIPTS=$(SCRIPTS_DIR)/verification
RENAME_VERIFICATION_VARIABLES=$(VERIFICATION_SCRIPTS)/rename_verification_variables.py
RAW_VERIFICATION_ROOT=/gpfs/f5/gfdl_w/scratch/Tsung-Lin.Hsieh/2023-09-18-PIRE-X-SHiELD-post-processing/processed/control/coarsened_by_1x/diagnostics
RENAMED_VERIFICATION_ROOT=$(CATALOG_DIR)

# Variables for prescriber dataset generation
PRESCRIBER_SCRIPTS=$(SCRIPTS_DIR)/prescriber
LAND_PRESCRIBER_SCRIPT=$(PRESCRIBER_SCRIPTS)/land.py
OCEAN_PRESCRIBER_SCRIPT=$(PRESCRIBER_SCRIPTS)/ocean.py

RESTARTS_ROOT=/gpfs/f5/gfdl_w/scratch/Tsung-Lin.Hsieh/2023-09-18-PIRE-X-SHiELD-post-processing/processed/control/coarsened_by_1x/restarts

PRESCRIBER_DATASETS=$(SCRATCH_ROOT)/prescriber
LAND_PRESCRIBER_DATASET=$(PRESCRIBER_DATASETS)/land.zarr
OCEAN_PRESCRIBER_DATASET=$(PRESCRIBER_DATASETS)/ocean.zarr


# Training, validation, and testing data for ML models
TRAINING_SCRIPTS=$(SCRIPTS_DIR)/training
FILL_MAPPER_TEMPLATE=$(TRAINING_SCRIPTS)/fill_mapper_template.py
FILL_BATCHES_TEMPLATE=$(TRAINING_SCRIPTS)/fill_batches_template.py

# Generate radiative flux dataset
GENERATE_RADIATIVE_FLUX_DATASET=$(TRAINING_SCRIPTS)/generate_radiative_flux_dataset.py
RADIATIVE_FLUX_DATASET=$(ML_DATA_ROOT)/radiative-fluxes.zarr

ML_DATA_ROOT=$(SCRATCH_ROOT)/ml-data
ML_TRAINING_DATA=$(ML_DATA_ROOT)/training
ML_VALIDATION_DATA=$(ML_DATA_ROOT)/validation

# ML configuration
ML_CONFIG_DIR=$(CONFIG_DIR)/machine-learning

# Mapper config templates
TENDENCIES_TRAINING_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/training-data-tendencies.yaml
FLUXES_TRAINING_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/training-data-fluxes.yaml
TENDENCIES_TESTING_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/testing-data-tendencies.yaml
FLUXES_TESTING_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/testing-data-fluxes.yaml
TENDENCIES_VALIDATION_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/validation-data-tendencies.yaml
FLUXES_VALIDATION_MAPPER_TEMPLATE=$(CONFIG_TEMPLATES)/validation-data-fluxes.yaml

# Filled mapper configs
TQ_TRAINING_MAPPER=$(ML_CONFIG_DIR)/tq-training-data.yaml
UV_TRAINING_MAPPER=$(ML_CONFIG_DIR)/uv-training-data.yaml
FLUXES_TRAINING_MAPPER=$(ML_CONFIG_DIR)/fluxes-training-data.yaml

TQ_TESTING_MAPPER=$(ML_CONFIG_DIR)/tq-testing-data.yaml
UV_TESTING_MAPPER=$(ML_CONFIG_DIR)/uv-testing-data.yaml
FLUXES_TESTING_MAPPER=$(ML_CONFIG_DIR)/fluxes-testing-data.yaml

TQ_VALIDATION_MAPPER=$(ML_CONFIG_DIR)/tq-validation-data.yaml
UV_VALIDATION_MAPPER=$(ML_CONFIG_DIR)/uv-validation-data.yaml
FLUXES_VALIDATION_MAPPER=$(ML_CONFIG_DIR)/fluxes-validation-data.yaml

TRAINING_MAPPER_WILDCARD=$(ML_CONFIG_DIR)/$*-training-data.yaml
TESTING_MAPPER_WILDCARD=$(ML_CONFIG_DIR)/$*-testing-data.yaml
VALIDATION_MAPPER_WILDCARD=$(ML_CONFIG_DIR)/$*-validation-data.yaml

# Batches configs
BATCHES_CONFIG_TEMPLATE=$(CONFIG_TEMPLATES)/batches_from_netcdf.yaml
TRAINING_BATCHES_CONFIG_WILDCARD=$(ML_CONFIG_DIR)/$*-batches-training.yaml
VALIDATION_BATCHES_CONFIG_WILDCARD=$(ML_CONFIG_DIR)/$*-batches-validation.yaml

# Model training
MODELS=$(SCRATCH_ROOT)/models
PREDICTAND_SETS = tq uv fluxes
TRAINING_CONFIG_WILDCARD=$(ML_CONFIG_DIR)/$*-model.yaml
MODEL_WILDCARD=$(MODELS)/$*-model
TRAIN=$(TRAINING_SCRIPTS)/train.sh


# Simulations
SIMULATION_NTASKS=384
SIMULATION_SEGMENTS=2
SIMULATION_SCRIPTS=$(SCRIPTS_DIR)/simulations
PROGNOSTIC_RUN=$(SIMULATION_SCRIPTS)/prognostic_run.sh
SIMULATIONS = baseline nudged ml-corrected
SIMULATION_CONFIG_DIR=$(CONFIG_DIR)/simulations
SIMULATION_ROOT=$(SCRATCH_ROOT)/simulations
FV3CONFIG_REFERENCE_DIR=$(SCRATCH_ROOT)/fv3config-reference
COPY_FV3CONFIG_DATA=$(SIMULATION_SCRIPTS)/copy_fv3config_data.sh
FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT=$(SIMULATION_SCRIPTS)/fill_template.py

BASELINE_RUN_TEMPLATE=$(CONFIG_TEMPLATES)/baseline_C384_gaea.yaml
BASELINE_RUN2_TEMPLATE=$(CONFIG_TEMPLATES)/baseline2_C384_gaea.yaml
BASELINE_RUN3_TEMPLATE=$(CONFIG_TEMPLATES)/baseline3_C384_gaea.yaml
BASELINE_RUN4_TEMPLATE=$(CONFIG_TEMPLATES)/baseline4_C384_gaea.yaml
NUDGED_RUN_TEMPLATE=$(CONFIG_TEMPLATES)/nudged_C384_gaea.yaml
NUDGED_RUN2_TEMPLATE=$(CONFIG_TEMPLATES)/nudged2_C384_gaea.yaml
NUDGED_RUN3_TEMPLATE=$(CONFIG_TEMPLATES)/nudged3_C384_gaea.yaml
NUDGED_RUN4_TEMPLATE=$(CONFIG_TEMPLATES)/nudged4_C384_gaea.yaml
ML_CORRECTED_RUN_TEMPLATE=$(CONFIG_TEMPLATES)/ml-corrected_C384_gaea.yaml
ML_CORRECTED_RUN2_TEMPLATE=$(CONFIG_TEMPLATES)/ml-corrected2_C384_gaea.yaml
ML_CORRECTED_RUN3_TEMPLATE=$(CONFIG_TEMPLATES)/ml-corrected3_C384_gaea.yaml
ML_CORRECTED_RUN4_TEMPLATE=$(CONFIG_TEMPLATES)/ml-corrected4_C384_gaea.yaml

BASELINE_RUN_CONFIG=$(SIMULATION_CONFIG_DIR)/baseline.yaml
BASELINE_RUN2_CONFIG=$(SIMULATION_CONFIG_DIR)/baseline2.yaml
BASELINE_RUN3_CONFIG=$(SIMULATION_CONFIG_DIR)/baseline3.yaml
BASELINE_RUN4_CONFIG=$(SIMULATION_CONFIG_DIR)/baseline4.yaml
NUDGED_RUN_CONFIG=$(SIMULATION_CONFIG_DIR)/nudged.yaml
NUDGED_RUN2_CONFIG=$(SIMULATION_CONFIG_DIR)/nudged2.yaml
NUDGED_RUN3_CONFIG=$(SIMULATION_CONFIG_DIR)/nudged3.yaml
NUDGED_RUN4_CONFIG=$(SIMULATION_CONFIG_DIR)/nudged4.yaml
ML_CORRECTED_RUN_CONFIG=$(SIMULATION_CONFIG_DIR)/ml-corrected.yaml
ML_CORRECTED_RUN2_CONFIG=$(SIMULATION_CONFIG_DIR)/ml-corrected2.yaml
ML_CORRECTED_RUN3_CONFIG=$(SIMULATION_CONFIG_DIR)/ml-corrected3.yaml
ML_CORRECTED_RUN4_CONFIG=$(SIMULATION_CONFIG_DIR)/ml-corrected4.yaml

# Offline reports
OFFLINE_REPORT=$(TRAINING_SCRIPTS)/offline_report.sh
OFFLINE_ROOT=$(SCRATCH_ROOT)/offline
OFFLINE_DIAGS_ROOT=$(OFFLINE_ROOT)/diags
OFFLINE_REPORT_ROOT=$(OFFLINE_ROOT)/reports
OFFLINE_DIAGS_WILDCARD=$(OFFLINE_DIAGS_ROOT)/$*-model
OFFLINE_REPORT_WILDCARD=$(OFFLINE_REPORT_ROOT)/$*-model
OFFLINE_COMPUTE_FLAGS="--catalog_path=$(CATALOG)"

# Prognostic run reports
PROGNOSTIC_RUN_DIAGS_FLAGS="--verification=${VERIFICATION_TAG} --catalog=${CATALOG}"
PROGNOSTIC_RUN_REPORT=$(SCRATCH_ROOT)/prognostic-run-report
PROGNOSTIC_RUN_REPORT_SCRIPTS=$(SCRIPTS_DIR)/prognostic-run-report
PROGNOSTIC_RUN_DIAGS=$(PROGNOSTIC_RUN_REPORT_SCRIPTS)/prognostic_run_diags.sh
RUNDIRS_TEMPLATE=$(CONFIG_TEMPLATES)/rundirs.json
RUNDIRS=$(CONFIG_DIR)/rundirs.json
VERTICALLY_INTERPOLATE_REFERENCE=$(PROGNOSTIC_RUN_REPORT_SCRIPTS)/interpolate_reference_dataset.py
VERTICALLY_INTERPOLATED_REFERENCE=$(CATALOG_DIR)/vertically_interpolated_reference.zarr
FILL_RUNDIRS=$(PROGNOSTIC_RUN_REPORT_SCRIPTS)/fill_rundirs.py

# Installing software; note this should be done before anything else.
install: update_submodules build_prognostic_run_environment build_fv3net_image_environment


update_submodules:
	git submodule update --init --recursive


build_prognostic_run_environment:
	$(ENVIRONMENT_SCRIPTS)/build_prognostic_run_environment.sh \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT)


build_fv3net_image_environment:
	$(ENVIRONMENT_SCRIPTS)/build_fv3net_image_environment.sh \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT)


# Create directories for simulations and other artifacts; should be run after
# installing the environments.
initialize_experiment:
	mkdir -p $(CATALOG_DIR)
	mkdir -p $(ML_DATA_ROOT)
	mkdir -p $(MODELS)
	mkdir -p $(OFFLINE_REPORT_ROOT)
	mkdir -p $(PRESCRIBER_DATASETS)
	mkdir -p $(SIMULATION_ROOT)
	mkdir -p $(FV3CONFIG_REFERENCE_DIR)
	$(COPY_FV3CONFIG_DATA) $(FV3CONFIG_REFERENCE_DIR)


# Run this immediately after the initialize_experiment rule.  fv3net expects
# variable names in the verification data to be named a certain way, which was
# not entirely how variables were named in the PIRE simulation outputs.
rename_verification_variables: $(addprefix rename_verification_variables_, $(VERIFICATION_DATASETS))
rename_verification_variables_%:
	sbatch \
	--output=$(SLURM_LOG_DIR)/rename-verification-variables-%j.out \
	--time=01:00:00 \
	--ntasks=4 \
	--cluster=c5 \
	--qos=debug \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(RENAME_VERIFICATION_VARIABLES) \
	$(RAW_VERIFICATION_ROOT)/$* \
	$(RENAMED_VERIFICATION_ROOT)/$*


build_catalog:
	$(COPY_CATALOG_REFERENCE_DATA) $(CATALOG_DIR)
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_CATALOG_TEMPLATE) \
	$(CATALOG_TEMPLATE) \
	$(CATALOG_DIR) \
	$(CATALOG)


# Prescriber datasets; these must be run prior to submitting any simulations.
# They are used to prescribe the sea surface temperature, ocean/land/sea-ice
# mask, sea ice fraction, and sea ice thickness over ocean, and the downward
# shortwave, net shortwave, downward longwave, and precipitation seen by the
# land surface model.  The ocean fields are prescribed in all simulations; the
# land fields are only prescribed in the nudged run.
prescriber_datasets: ocean_prescriber_dataset land_prescriber_dataset


ocean_prescriber_dataset:
	sbatch --output=$(SLURM_LOG_DIR)/ocean-prescriber-dataset-%j.out --time=03:00:00 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(OCEAN_PRESCRIBER_SCRIPT) \
	$(RESTARTS_ROOT) \
	$(OCEAN_PRESCRIBER_DATASET)


land_prescriber_dataset:
	sbatch --output=$(SLURM_LOG_DIR)/land-prescriber-dataset-%j.out --time=01:00:00 \
	--cluster=c5 \
	--qos=debug \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(LAND_PRESCRIBER_SCRIPT) \
	$(CATALOG) \
	$(LAND_PRESCRIBER_DATASET)


# Simulations; we include rules for running three types of simulations: a
# baseline (no-ML) run, a run nudged to the coarsened state of the X-SHiELD run,
# and an ML-corrected run.
baseline_run_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(BASELINE_RUN_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(BASELINE_RUN_CONFIG)


baseline_run: baseline_run_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(BASELINE_RUN_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/baseline


baseline_run2_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(BASELINE_RUN2_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(BASELINE_RUN2_CONFIG)


baseline_run2: baseline_run2_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(BASELINE_RUN2_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/baseline_01290600_6day


baseline_run3_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(BASELINE_RUN3_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(BASELINE_RUN3_CONFIG)


baseline_run3: baseline_run3_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(BASELINE_RUN3_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/baseline_01290900_6day


baseline_run4_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(BASELINE_RUN4_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(BASELINE_RUN4_CONFIG)


baseline_run4: baseline_run4_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(BASELINE_RUN4_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/baseline_01291200_6day


nudged_run_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(NUDGED_RUN_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(NUDGED_RUN_CONFIG)


nudged_run: nudged_run_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=normal \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(NUDGED_RUN_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/nudged


nudged_run2_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(NUDGED_RUN2_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(NUDGED_RUN2_CONFIG)


nudged_run2: nudged_run2_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=normal \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(NUDGED_RUN2_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/nudged2


nudged_run3_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(NUDGED_RUN3_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(NUDGED_RUN3_CONFIG)


nudged_run3: nudged_run3_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=normal \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(NUDGED_RUN3_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/nudged3


nudged_run4_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(NUDGED_RUN4_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(NUDGED_RUN4_CONFIG)


nudged_run4: nudged_run4_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=normal \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(NUDGED_RUN4_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/nudged4


ml_corrected_run_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(ML_CORRECTED_RUN_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(ML_CORRECTED_RUN_CONFIG)


ml_corrected_run: ml_corrected_run_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(ML_CORRECTED_RUN_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/ml-corrected


ml_corrected_run2_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(ML_CORRECTED_RUN2_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(ML_CORRECTED_RUN2_CONFIG)


ml_corrected_run2: ml_corrected_run2_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(ML_CORRECTED_RUN2_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/ml-corrected_seed2


ml_corrected_run3_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(ML_CORRECTED_RUN3_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(ML_CORRECTED_RUN3_CONFIG)


ml_corrected_run3: ml_corrected_run3_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(ML_CORRECTED_RUN3_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/ml-corrected_seed3


ml_corrected_run4_config:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_PROGNOSTIC_RUN_CONFIG_SCRIPT) \
	$(ML_CORRECTED_RUN4_TEMPLATE) \
	$(FV3CONFIG_REFERENCE_DIR) \
	$(MODELS) \
	$(PRESCRIBER_DATASETS) \
	$(RESTARTS_ROOT) \
	$(ML_CORRECTED_RUN4_CONFIG)


ml_corrected_run4: ml_corrected_run4_config
	SBATCH_TIMELIMIT=5:00:00 \
	SLURM_NTASKS=$(SIMULATION_NTASKS) \
	SLURM_LOG_DIR=$(SLURM_LOG_DIR) \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-%j.out \
	--ntasks=$(SIMULATION_NTASKS) \
	--export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(PROGNOSTIC_RUN) \
	$(ML_CORRECTED_RUN4_CONFIG) \
	$(SIMULATION_SEGMENTS) \
	$(SIMULATION_ROOT)/ml-corrected_seed4


# ML datasets; we can only run these rules after running the nudged simulation,
# which generates the data we use for ML training, validation, and testing.
flux_training_validation_testing_zarr:
	sbatch -W --output=$(SLURM_LOG_DIR)/radiative-flux-dataset-%j.out --time=01:00:00 \
	--cluster=c5 \
	--qos=debug \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(GENERATE_RADIATIVE_FLUX_DATASET) \
	$(CATALOG) \
	$(ML_CONFIG_DIR) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET)


fill_data_mapper_templates: fill_training_data_mapper_templates fill_testing_data_mapper_templates fill_validation_data_mapper_templates


fill_training_data_mapper_templates:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_TRAINING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(TQ_TRAINING_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_TRAINING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(UV_TRAINING_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(FLUXES_TRAINING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(FLUXES_TRAINING_MAPPER)


fill_testing_data_mapper_templates:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_TESTING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(TQ_TESTING_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_TESTING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(UV_TESTING_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(FLUXES_TESTING_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(FLUXES_TESTING_MAPPER)


fill_validation_data_mapper_templates:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_VALIDATION_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(TQ_VALIDATION_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(TENDENCIES_VALIDATION_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(UV_VALIDATION_MAPPER)

	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_MAPPER_TEMPLATE) \
	$(FLUXES_VALIDATION_MAPPER_TEMPLATE) \
	$(CATALOG) \
	$(SIMULATION_ROOT) \
	$(RADIATIVE_FLUX_DATASET) \
	$(FLUXES_VALIDATION_MAPPER)


netcdf_batches: fill_data_mapper_templates flux_training_validation_testing_zarr netcdf_batches_training netcdf_batches_validation


netcdf_batches_training: $(addsuffix _netcdf_batches_training, $(PREDICTAND_SETS))
%_netcdf_batches_training:
	sbatch --output=$(SLURM_LOG_DIR)/batches-%j.out --time=02:00:00 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	python -m loaders.batches.save \
	$(TRAINING_MAPPER_WILDCARD) \
	$(ML_TRAINING_DATA)/$*


netcdf_batches_validation: $(addsuffix _netcdf_batches_validation, $(PREDICTAND_SETS))
%_netcdf_batches_validation:
	sbatch --output=$(SLURM_LOG_DIR)/batches-%j.out --time=01:00:00 \
	--cluster=c5 \
	--qos=debug \
	$(CONDA_RUN) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	python -m loaders.batches.save \
	$(VALIDATION_MAPPER_WILDCARD) \
	$(ML_VALIDATION_DATA)/$*


netcdf_batches_config: netcdf_batches_config_training netcdf_batches_config_validation


netcdf_batches_config_training: $(addsuffix _netcdf_batches_config_training, $(PREDICTAND_SETS))
%_netcdf_batches_config_training:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_BATCHES_TEMPLATE) \
	$(BATCHES_CONFIG_TEMPLATE) \
	$(ML_TRAINING_DATA)/$* \
	$(TRAINING_BATCHES_CONFIG_WILDCARD)


netcdf_batches_config_validation: $(addsuffix _netcdf_batches_config_validation, $(PREDICTAND_SETS))
%_netcdf_batches_config_validation:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_BATCHES_TEMPLATE) \
	$(BATCHES_CONFIG_TEMPLATE) \
	$(ML_VALIDATION_DATA)/$* \
	$(VALIDATION_BATCHES_CONFIG_WILDCARD)


subsample_ml_data:
	sbatch \
	--output=$(SLURM_LOG_DIR)/balanced-datasets-%j.out \
	--time=04:00:00 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	python /ncrc/home2/Tsung-Lin.Hsieh/fv3net_helper/sample_netcdf_batches.py


# ML training; we can only run these rules after generating the requisite
# training and validation datasets.
train: netcdf_batches_config $(addprefix train_, $(PREDICTAND_SETS))
train_%:
	TMPDIR=/gpfs/f5/gfdl_w/scratch/$(USER)/tmp \
	sbatch --output=$(SLURM_LOG_DIR)/train-%j.out --time=16:00:00 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	python -m fv3fit.train \
	$(TRAINING_CONFIG_WILDCARD) \
	$(TRAINING_BATCHES_CONFIG_WILDCARD) \
	$(MODEL_WILDCARD) \
    --validation-data-config=$(VALIDATION_BATCHES_CONFIG_WILDCARD) \
    --no-wandb


# Offline reports; these naturally require trained ML models.
offline_report: $(addprefix offline_report_, $(PREDICTAND_SETS))
offline_report_%:
	sbatch --output=$(SLURM_LOG_DIR)/offline-report-%j.out \
	--cluster=c5 \
	--qos=urgent \
	$(OFFLINE_REPORT) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	$(MODEL_WILDCARD) \
	$(TESTING_MAPPER_WILDCARD) \
	$(OFFLINE_DIAGS_WILDCARD) \
	$(OFFLINE_COMPUTE_FLAGS) \
	$(OFFLINE_REPORT_WILDCARD) \
	$(FV3NET_COMMIT) \
	$(TRAINING_CONFIG_WILDCARD) \
	$(TRAINING_MAPPER_WILDCARD)


vertically_interpolated_reference:
	sbatch -W --output=$(SLURM_LOG_DIR)/interpolate-%j.out --time=03:00:00 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(VERTICALLY_INTERPOLATE_REFERENCE) \
	$(SIMULATION_ROOT) \
	$(VERTICALLY_INTERPOLATED_REFERENCE)


# Prognostic run diagnostics
prognostic_run_diags: vertically_interpolated_reference $(addprefix prognostic_run_diags_, $(SIMULATIONS))
prognostic_run_diags_%:
	sbatch --output=$(SLURM_LOG_DIR)/prognostic-run-diags-%j.out \
	--cluster=c5 \
	--qos=urgent \
	$(PROGNOSTIC_RUN_DIAGS) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	$(SIMULATION_ROOT)/$* \
	$(PROGNOSTIC_RUN_DIAGS_FLAGS) \
	$(SIMULATION_ROOT)/$*/prognostic-run-diags


prognostic_run_rundirs:
	$(CONDA_RUN) \
	$(ROOT) \
	$(PROGNOSTIC_RUN_ENVIRONMENT) \
	$(FILL_RUNDIRS) \
	$(RUNDIRS_TEMPLATE) \
	$(SIMULATION_ROOT) \
	$(RUNDIRS)


prognostic_run_report: prognostic_run_rundirs
	TMPDIR=/gpfs/f5/gfdl_w/scratch/$(USER)/tmp \
	MPLBACKEND=Agg \
	sbatch \
	--output=$(SLURM_LOG_DIR)/prognostic-run-report-%j.out \
	--time=06:00:00 \
	--ntasks=4 \
	--cluster=c5 \
	--qos=urgent \
	$(CONDA_RUN) \
	$(ROOT) \
	$(FV3NET_IMAGE_ENVIRONMENT) \
	prognostic_run_diags report-from-json \
	$(RUNDIRS) \
	$(PROGNOSTIC_RUN_REPORT)
