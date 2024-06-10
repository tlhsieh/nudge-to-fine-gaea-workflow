#!/bin/bash
FV3CONFIG_REFERENCE_DIR=$1

STATIC_SOURCE=/ncrc/home2/Tsung-Lin.Hsieh/scratch/C384_reference/fv3config/
cp -r ${STATIC_SOURCE}/* ${FV3CONFIG_REFERENCE_DIR}/
