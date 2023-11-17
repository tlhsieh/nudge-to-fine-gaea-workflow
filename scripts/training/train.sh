#!/bin/bash
set -e

ROOT=$1
CONDA_ENVIRONMENT=$2
TRAINING_CONFIG=$3
TRAINING_DATA_CONFIG=$4
VALIDATION_DATA_CONFIG=$5
DESTINATION=$6

PLATFORM=stellar
FV3NET_DIR=${ROOT}/fv3net
INSTALL_PREFIX=${ROOT}/install

source ${FV3NET_DIR}/external/fv3gfs-fortran/FV3/conf/modules.fv3.stellar
source ${FV3NET_DIR}/.environment-scripts/activate_environment.sh \
    ${PLATFORM} \
    ${FV3NET_DIR} \
    ${INSTALL_PREFIX} \
    ${CONDA_ENVIRONMENT}


TEMPORARY_DIRECTORY=/scratch/cimes/${USER}/scratch/$(uuidgen)-training
mkdir -p ${TEMPORARY_DIRECTORY}
cd ${TEMPORARY_DIRECTORY}
python -m fv3fit.train \
       ${TRAINING_CONFIG} \
       ${TRAINING_DATA_CONFIG} \
       ${DESTINATION} \
       --validation-data-config=${VALIDATION_DATA_CONFIG} \
       --no-wandb
cd -
rm -rf ${TEMPORARY_DIRECTORY}
