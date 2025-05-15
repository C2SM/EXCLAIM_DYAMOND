#!/usr/bin/bash

# First time
export restart_interval="P11D"
export end_date="2020-02-01T00:00:00"

# Subsequent runs
export lrestart="true"
export end_date="2021-04-01T00:00:00"

./DYAMOND_R02B10L120.run
