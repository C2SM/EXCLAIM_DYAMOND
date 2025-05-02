#!/usr/bin/bash

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
       [ -z "${START}" ] && (echo "ERROR: START not defined"; exit 1)
       [ -z "${ICON_EXE}" ] && (echo "ERROR: ICON_EXE not defined"; exit 1)
       [ -z "${SUBMIT}" ] && (echo "ERROR: SUBMIT not defined"; exit 1)
       ${SUBMIT}
       exit $?
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

run_model(){
   status_file="${EXPDIR}/finish.status"
   rm -f "${status_file}"

   date
   ${START} ${ICON_EXE}
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
       ${SUBMIT}
   fi
}
