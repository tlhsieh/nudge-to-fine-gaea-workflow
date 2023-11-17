#!/bin/bash
#SBATCH --time=06:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --ntasks=4

ROOT=$1
CONDA_ENVIRONMENT=$2
RUN=$3
FLAGS=$4
DESTINATION=$5

PLATFORM=stellar
FV3NET_DIR=${ROOT}/fv3net
INSTALL_PREFIX=${ROOT}/install

source ${FV3NET_DIR}/.environment-scripts/activate_environment.sh \
    ${PLATFORM} \
    ${FV3NET_DIR} \
    ${INSTALL_PREFIX} \
    ${CONDA_ENVIRONMENT}

export TMPDIR=/scratch/cimes/skclark/scratch
export MPLBACKEND=Agg  # Required for running non-interactively

DIAGS="${DESTINATION}/diags.nc"
METRICS="${DESTINATION}/metrics.json"

prognostic_run_diags save ${FLAGS} "${RUN}" "${DIAGS}"
prognostic_run_diags metrics "${DIAGS}" > "${METRICS}"
prognostic_run_diags movie ${FLAGS} "${RUN}" "${DESTINATION}"
