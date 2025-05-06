#!/usr/bin/bash

benchmark(){
    export N_NODES="${1}"
    export N_IO_PROCS="${2}"
    export EXPDIR="./experiments/Benchmark_${1}_${2}"
    ./Diamond_R02B06L120.run
}

export start_date="2020-01-20T00:00:00"
export end_date="2020-01-20T06:00:00"

benchmark 2 1
benchmark 3 1
benchmark 3 2
