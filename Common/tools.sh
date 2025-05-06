#!/usr/bin/bash

submit(){
   (set -x
    sbatch \
        --account="${ACCOUNT}" \
        --partition="${PARTITION}" \
        --uenv="${UENV}" \
        --view="${VIEW}" \
        --nodes="${N_NODES}" \
        --time="${WALL_TIME}" \
        --job-name="${EXPNAME}" \
        --output="${EXPDIR}/${EXPNAME}.%j.o" \
        "${SCRIPT_PATH}")
}

first_submit(){
   # In the case of a first execution of that script directly from the command
   # line, submit it using variables like EXPDIR, nodes, walltime, ... and exit
   if [ "${SUBMITTED}" == "false" ]; then
       export FIRST_EXECUTION="false"
       if [ ! -d "${EXPDIR}" ]; then
           echo "EXPDIR does not exist. Creating ${EXPDIR}..."
           mkdir -p "${EXPDIR}"
       else
           echo "EXPDIR already exists at ${EXPDIR}"
       fi
       submit
       exit $?
   fi
}

run_model(){
   status_file="${EXPDIR}/finish.status"
   rm -f "${status_file}"

   date

   (set -x
    srun \
        --ntasks="${mpi_total_procs}" \
        --ntasks-per-node="${mpi_procs_pernode}" \
        --threads-per-core=1 \
        --distribution="cyclic" \
        "${SCRIPT_DIR}/../Common/santis_gpu.sh" "./icon")

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

   # Resubmit in case of restart
   if [ "${finish_status}" == " RESTART" ]; then
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
       target_item="${target_item}/${src_item_name}"
   elif [ -z "${target_item}" ]; then
       target_item="${src_item_name}"
   fi
   [ -e "${target_item}" ] || ln -s "${src_item}" "${target_item}"
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
