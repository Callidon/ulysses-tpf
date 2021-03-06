#!/bin/bash
# Start servers & proxies for local experiment

CONFIG=$1
LATENCY=$2
# FILE=$3
# OUTPUT=$4
# MODE=$5
pids=()

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./launch_run.sh <server-config-file> <server-latency> <query-file> <output> <mode>"
  exit
fi

# launch TPF servers
ldf-server $CONFIG 4000 4 &
pids+=($!)
ldf-server $CONFIG 4001 4 &
pids+=($!)
ldf-server $CONFIG 4002 4 &
pids+=($!)

sleep 5

# launch latency proxies
scripts/latency_proxy.js http://localhost:4000 3000 $LATENCY &
pids+=($!)
scripts/latency_proxy.js http://localhost:4001 3001 $LATENCY &
pids+=($!)
scripts/latency_proxy.js http://localhost:4002 3002 $LATENCY &
pids+=($!)

sleep 5

# launch experiment
# if [[ "$MODE" = "ref" ]]; then
#   ./scripts/run_load_ref.sh $FILE $OUTPUT
# elif [[ "$MODE" = "tpf+ulysses" ]]; then
#   ./scripts/run_load.sh $FILE $OUTPUT ldf 1
# elif [[ "$MODE" = "ulysses" ]]; then
#   ./scripts/run_load.sh $FILE $OUTPUT ulysses 1
# fi
#
# # kill servers & proxies
# kill -9 ${pids[@]} > /dev/null 2> /dev/null
