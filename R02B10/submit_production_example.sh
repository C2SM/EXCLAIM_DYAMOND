#!/usr/bin/bash

export ACCOUNT="cwp03"
export UENV="icon-wcp/v1:rc4"
export VIEW="icon"

# First time
export restart_interval="P11D"
export end_date="2020-02-01T00:00:00"

# Subsequent runs
export lrestart="true"
export restart_interval="P1M"
export end_date="2021-04-01T00:00:00"

./DYAMOND_R02B10L120.run
