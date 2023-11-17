#!/bin/bash
CATALOG_DIR=$1

STATIC_SOURCE=/scratch/cimes/skclark/reference
cp -r ${STATIC_SOURCE}/* ${CATALOG_DIR}/
