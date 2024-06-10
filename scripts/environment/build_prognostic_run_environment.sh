#!/bin/bash
ROOT=$1
ENVIRONMENT_NAME=$2

CLONE_PREFIX=${ROOT}/clone
INSTALL_PREFIX=${ROOT}/install
FV3NET_DIR=${ROOT}/fv3net
CALLPYFORT=""

bash $FV3NET_DIR/.environment-scripts/setup_environment.sh \
    all \
    gaea-c5 \
    $CLONE_PREFIX \
    $INSTALL_PREFIX \
    $FV3NET_DIR \
    "$CALLPYFORT" \
    ${ENVIRONMENT_NAME}
