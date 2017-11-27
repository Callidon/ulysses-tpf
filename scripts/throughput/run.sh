#!/bin/bash
# run three times the experiment with throughput

QUERY=$1
OUTPUT=$2
pids=()

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run.sh <query-file> <output-folder>"
  exit
fi

SERVERS="http://localhost:3000/watDiv_100 http://localhost:3001/watDiv_100 http://localhost:3002/watDiv_100"
RESFILE="${OUTPUT}/record_throughput.csv"

source ./scripts/config.cfg

# launch TPF servers
ldf-server $ldf_config 4000 4 &
pids+=($!)
ldf-server $ldf_config 4001 4 &
pids+=($!)
ldf-server $ldf_config 4002 4 &
pids+=($!)

sleep 5

# launch latency proxies
scripts/latency_proxy.js http://localhost:4000 3000 $latency &
pids+=($!)
scripts/latency_proxy.js http://localhost:4001 3001 $latency &
pids+=($!)
scripts/latency_proxy.js http://localhost:4002 3002 $latency &
pids+=($!)

sleep 5

# wait 15s and then triple latency of S1 over 10s
sleep 15 && GET http://localhost:3000/setLatency?value=350 &
sleep 20 && GET http://localhost:3000/setLatency?value=400 &
sleep 25 && GET http://localhost:3000/setLatency?value=450 &
sleep 30 && GET http://localhost:3000/setLatency?value=500 &

./bin/ulysses-tpf.js $SERVERS -f $QUERY -m $RESFILE -r > $OUTPUT/results.log 2> $OUTPUT/errors.err

# kill servers & proxies
sleep 5
kill -9 ${pids[@]} > /dev/null 2> /dev/null
