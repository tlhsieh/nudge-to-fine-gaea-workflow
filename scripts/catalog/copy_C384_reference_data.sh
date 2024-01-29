#!/bin/bash
CATALOG_DIR=$1

STATIC_SOURCE=/scratch/cimes/skclark/C384_reference
cp -r ${STATIC_SOURCE}/* ${CATALOG_DIR}/
