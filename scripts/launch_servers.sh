#!/bin/bash
# Start servers & proxies for local experiment

CONFIG=$1
LATENCY=$2
NB=$3
pids=()

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./launch_servers.sh <server-config-file> <server-latency> <nb-servers>"
  exit
fi

SPORT=4000 # server port
# PPORT=3000 # proxy port

for i in $(seq 1 $NB); do
  ldf-server $CONFIG ${SPORT} 4 &
  pids+=($!)
  sleep 5
  scripts/latency_proxy.js http://localhost:${SPORT} $LATENCY ${PPORT} &
  pids+=($!)
  SPORT=$((SPORT+1))
  PPORT=$((PPORT+1))
  sleep 5
done

echo ${pids[@]}
