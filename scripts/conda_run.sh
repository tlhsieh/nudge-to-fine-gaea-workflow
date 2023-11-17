#!/bin/bash
ROOT=$1
CONDA_ENVIRONMENT=$2
COMMAND=$3

FV3NET_DIR=${ROOT}/fv3net
PLATFORM=stellar
INSTALL_PREFIX=${ROOT}/install

source ${FV3NET_DIR}/.environment-scripts/activate_environment.sh \
    ${PLATFORM} \
    ${FV3NET_DIR} \
    ${INSTALL_PREFIX} \
    ${CONDA_ENVIRONMENT}

# Pass remaining arguments to Python command
${COMMAND} ${@:4}
