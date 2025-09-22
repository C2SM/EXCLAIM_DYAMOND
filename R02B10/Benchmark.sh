#!/usr/bin/bash

EXP_ROOT="/capstor/scratch/cscs/leclairm/DYAMOND_experiments//Benchmark_R02B10"
MEMBERS="3"
NODES="240"
IO_PROCS="31"

benchmark_with_io(){
    export ENABLE_IO="true"
    export N_NODES="${2}"
    export N_IO_PROCS="${3}"
    export EXPDIR="${EXP_ROOT}/with_IO/member_${1}/Benchmark_${2}_${3}"
    rm -rf "${EXPDIR}"
    mkdir -p "${EXPDIR}"
    ./DYAMOND_R02B10L120.run
}

benchmark_no_io(){
    export ENABLE_IO="false"
    export N_NODES="${2}"
    export EXPDIR="${EXP_ROOT}/no_IO/member_${1}/Benchmark_${2}"
    rm -rf "${EXPDIR}"
    mkdir -p "${EXPDIR}"
    ./DYAMOND_R02B10L120.run
}

export basedir="/capstor/store/cscs/userlab/cwd01/leclairm/archive_build_liskov/icon_25.2_v3/icon-exclaim/build_dsl"
export start_date="2020-01-20T00:00:00"
export end_date="2020-01-22T00:00:00"
export restart_interval="P1D"

export ACCOUNT="cwd01"
export WALL_TIME="01:30:00"
export UENV="icon/25.2:v3"
export VIEW="default"
export RESERVATION="lustre_client_fix"
export restart_mode="async"
export N_RST_TASKS=30


for m in ${MEMBERS}; do
    echo
    echo "member ${m}"
    echo
    for N_NODES in ${NODES}; do
        # echo "    benchmark_no_io ${m} ${N_NODES}"
        # benchmark_no_io "${m}" "${N_NODES}"
        for N_IO_PROCS in ${IO_PROCS}; do
            echo
            echo "    benchmark_with_io ${m} ${N_NODES} ${N_IO_PROCS}"
            benchmark_with_io "${m}" "${N_NODES}" "${N_IO_PROCS}"
        done
    done
done
