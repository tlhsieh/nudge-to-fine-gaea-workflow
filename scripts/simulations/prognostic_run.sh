#!/bin/bash
set -e

ROOT=$1
CONDA_ENVIRONMENT=$2
SCRIPT=$3
CONFIG=$4
SEGMENTS=$5
DESTINATION=$6

PLATFORM=stellar
FV3NET_DIR=${ROOT}/fv3net
INSTALL_PREFIX=${ROOT}/install

# Ensure simulations can run on multiple nodes by using a commonly
# accessible TMPDIR.
WORK=$(dirname ${DESTINATION})/work_directories
mkdir -p ${WORK}
export TMPDIR=${WORK}

SEGMENT_CONFIG=${DESTINATION}/fv3config.yml

source ${FV3NET_DIR}/external/fv3gfs-fortran/FV3/conf/modules.fv3.stellar
source ${FV3NET_DIR}/.environment-scripts/activate_environment.sh \
    ${PLATFORM} \
    ${FV3NET_DIR} \
    ${INSTALL_PREFIX} \
    ${CONDA_ENVIRONMENT}

# Output environment to stdout for prevenance
conda list

RST_COUNT=${DESTINATION}/restart/rst.count
if [ -f ${RST_COUNT} ] 
then
  source ${RST_COUNT}
  if [ x"$num" == "x" ] || [ ${num} -lt 1 ]
  then
    RESTART_RUN="F"
  else
    RESTART_RUN="T"
  fi
else
  num=0
  RESTART_RUN="F"
fi

if [ "$RESTART_RUN" == "F" ]
then
    # We only need to prepare the config and create the simulation if this
    # is the first segment of the run.
    PREPARED_CONFIG=$(uuidgen)-fv3config.yml
    srun --export=ALL --ntasks=1 prepare-config ${CONFIG} > ${PREPARED_CONFIG}
    runfv3 create ${DESTINATION} ${PREPARED_CONFIG}
    rm ${PREPARED_CONFIG}
    mkdir -p ${DESTINATION}/restart
fi

runfv3 append --mpi_launcher srun ${DESTINATION}
num=$((num+1))
echo "num=${num}" > ${RST_COUNT}

# Resubmit to run another segment if needed
if [ ${num} -lt ${SEGMENTS} ]
then
  echo "Resubmitting to run another segment... "
  sbatch \
      --output=${SLURM_LOG_DIR}/prognostic-run-%j.out \
      --ntasks=${SLURM_NTASKS} \
      --export=SLURM_LOG_DIR,SBATCH_TIMELIMIT,SLURM_NTASKS \
      ${SCRIPT} \
      ${ROOT} \
      ${CONDA_ENVIRONMENT} \
      ${SCRIPT} \
      ${CONFIG} \
      ${SEGMENTS} \
      ${DESTINATION}
  sleep 60
fi
