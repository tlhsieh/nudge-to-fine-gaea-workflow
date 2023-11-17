#!/bin/bash
ROOT=$1
ENVIRONMENT_NAME=$2

FV3NET_DIR=${ROOT}/fv3net
SCRIPTS=${FV3NET_DIR}/.environment-scripts

module load anaconda3/2022.10
eval "$(conda shell.bash hook)"

cd $FV3NET_DIR
bash ${SCRIPTS}/build_environment.sh ${ENVIRONMENT_NAME}
bash ${SCRIPTS}/install_local_packages.sh ${ENVIRONMENT_NAME}
