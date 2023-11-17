#!/bin/bash
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=32G
set -e

ROOT=$1
CONDA_ENVIRONMENT=$2
MODEL=$3
TEST_DATA_CONFIG=$4
DIAGS_OUTPUT=$5
COMPUTE_FLAGS=$6
REPORT_OUTPUT=$7
COMMIT_SHA=$8
TRAINING_CONFIG=$9
TRAINING_DATA_CONFIG=${10}

PLATFORM=stellar
FV3NET_DIR=${ROOT}/fv3net
INSTALL_PREFIX=${ROOT}/install

source ${FV3NET_DIR}/.environment-scripts/activate_environment.sh \
    ${PLATFORM} \
    ${FV3NET_DIR} \
    ${INSTALL_PREFIX} \
    ${CONDA_ENVIRONMENT}

export TMPDIR=/scratch/cimes/${USER}/scratch
export MPLBACKEND=Agg  # Required for running non-interactively

python -m fv3net.diagnostics.offline.compute \
       "${MODEL}" \
       "${TEST_DATA_CONFIG}" \
       "${DIAGS_OUTPUT}" \
       "${COMPUTE_FLAGS}"
python -m fv3net.diagnostics.offline.views.create_report \
       "${DIAGS_OUTPUT}" \
       "${REPORT_OUTPUT}" \
       --commit-sha="${COMMIT_SHA}" \
       --training-config="${TRAINING_CONFIG}" \
       --training-data-config="${TRAINING_DATA_CONFIG}" \
       --no-wandb
