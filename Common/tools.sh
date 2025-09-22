#!/usr/bin/bash

submit(){
    cmd="sbatch --account=${ACCOUNT} --partition=${PARTITION} --uenv=${UENV} --view=${VIEW}"
    cmd+=" --nodes=${N_NODES} --time=${WALL_TIME} --job-name=${EXPNAME} --output=${EXPDIR}/${EXPNAME}.%j.o"
    [ -n "${RESERVATION}" ] && cmd+=" --reservation=${RESERVATION}"
    cmd+=" ${SCRIPT_PATH}"
    (set -x
     ${cmd})
}

first_submit(){
   # In the case of a first execution of that script directly from the command
   # line, submit it using variables like EXPDIR, nodes, walltime, ... and exit
   if [ "${SUBMITTED}" == "false" ]; then
       if [ ! -d "${EXPDIR}" ]; then
           echo "EXPDIR does not exist. Creating ${EXPDIR}..."
           mkdir -p "${EXPDIR}"
       else
           echo "EXPDIR already exists at ${EXPDIR}"
       fi
       export FIRST_EXECUTION="false"
       export FIRST_SUBMIT="true"

       # Store required script and repo path elements
       SCRIPT_NAME="$(basename "${SCRIPT_PATH}")"
       SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
       CASE_NAME="$(basename "${SCRIPT_DIR}")"
       ROOT_DIR="$(realpath "${SCRIPT_DIR}/..")"
       ROOT_NAME="$(basename "${ROOT_DIR}")"

       # copy repo to EXPDIR if we're not already executing from there
       if [ "${SCRIPT_PATH}" == "${EXPDIR}/${ROOT_NAME}/${CASE_NAME}/${SCRIPT_NAME}" ]; then
           echo "already executing from EXPDIR"
       else
           echo "sending scripts to EXPDIR"
           rsync -avq --delete "${ROOT_DIR}" "${EXPDIR}"
       fi

       pushd "${EXPDIR}">/dev/null 2>&1 || exit 1
       # overwrite SCRIPT_PATH for this first submission
       SCRIPT_PATH="./${ROOT_NAME}/${CASE_NAME}/${SCRIPT_NAME}" submit
       popd >/dev/null 2>&1 || exit 1
       exit $?
   fi
}

run_model(){
   status_file="${EXPDIR}/finish.status"
   rm -f "${status_file}"

   date

   # - ML - ORIGINAL
   NTASKS_PER_NODE=4
   (( N_TASKS = N_NODES * NTASKS_PER_NODE ))
   # - ML - TEST
   # NTASKS_PER_NODE=5
   # COMPUTE_TASKS_PER_NODE=4
   # (( N_TASKS = N_NODES * COMPUTE_TASKS_PER_NODE + N_IO_TASKS + N_RST_TASKS ))
   # - ML - END TEST

   # - ML - ORIGINAL
   DISTRIBUTION="cyclic"
   # - ML - TEST (only compatible with try from above)
   # DISTRIBUTION="plane=4"
   # - ML - END TEST

   (set -x
    srun \
        --ntasks="${N_TASKS}" \
        --ntasks-per-node="${NTASKS_PER_NODE}" \
        --threads-per-core=1 \
        --distribution="${DISTRIBUTION}" \
        "${SCRIPT_DIR}/../Common/santis_gpu.sh" "./icon"
   )

   date

   if [ ! -f "${status_file}" ]; then
       echo
       echo "============================"
       echo "Script failed"
       echo "============================"
       echo
       exit 1
   fi

   finish_status=$(cat "${status_file}")
   echo
   echo "============================"
   echo "Script ran successfully: ${finish_status}"
   echo "============================"
   echo
   echo

   echo "Accounting"
   sacct -j ${SLURM_JOB_ID} --format "ElapsedRaw, CPUTimeRAW, ConsumedEnergyRaw"

   # Resubmit in case of restart
   if [ "${finish_status}" == " RESTART" ]; then
       echo
       echo "submitting next chunk"
       export lrestart=.true.
       submit
   fi
}

link_item(){
   src_item="${1}"
   target_item="${2:-}"
   [ -r "${src_item}" ] || (echo "ERROR ${src_item} not available"; exit 1)
   src_item_name=$(basename "${src_item}")
   if [ -d "${target_item}" ]; then
       trg_item="${target_item}/${src_item_name}"
   elif [ -z "${target_item}" ]; then
       trg_item="${src_item_name}"
   else
       trg_item="${target_item}"
   fi
   if [ "${FIRST_SUBMIT}" == "true" ]; then
       ln -sf "${src_item}" "${trg_item}"
   elif [ ! -e "${trg_item}" ]; then
       ln -s "${src_item}" "${trg_item}"
   fi
}

link_input(){
   source="${1}"
   target="${2:-}"
   if [ -d "${source}" ]; then
       link_item "${source}" "${target}"
   else
       for src in ${source}; do
           link_item "${src}" "${target}"
       done
   fi
}

check_available(){
   echo -n "Check for ${1} ... "
   if [ -r "${2}" ]; then
       echo "${2} AVAILABLE"
   else
       echo "${2} MISSING"
       exit 1
   fi
}
