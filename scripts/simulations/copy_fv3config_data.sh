#!/bin/bash
FV3CONFIG_REFERENCE_DIR=$1

STATIC_SOURCE=/scratch/cimes/skclark/reference/fv3config
cp -r ${STATIC_SOURCE}/* ${FV3CONFIG_REFERENCE_DIR}/
