#!/usr/bin/bash

check_available(){
   echo -n "Check for ${1} ... "
    if [ -r "${2}" ]; then
        echo "${2} AVAILABLE"
    else
        echo "${2} MISSING"
        exit 1
    fi
}
