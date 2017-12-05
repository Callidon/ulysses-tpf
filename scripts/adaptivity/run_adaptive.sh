#!/bin/bash
# run load adaption experiment

QUERY=$1
OUTPUT=$2
NBSERVERS=$3 # number of servers

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run.sh <query-file> <output-folder> <nb-servers>"
  exit
fi

# server(s) to use (without proxy, as exec time does not matter here)
SPORT=3000
SERVERS=()
for x in $(seq 1 $NBSERVERS); do
  # set base server latency
  GET http://curiosiphi:${SPORT}/resetLatency
  SERVERS+=("http://curiosiphi:${SPORT}/watDiv_100")
  SPORT=$((SPORT+1))
done

RESFILE="${OUTPUT}/load_increase_${NBSERVERS}servers.csv"
echo "target,timestamp,time,realTime" > $RESFILE

sleep 5

# wait 15s and then triple latency of S1
sleep 20 && GET http://curiosiphi:3000/setLatency?value=900 &
# wait 30s and then restore latency of S1 to 300ms
# sleep 50 && GET http://curiosiphi:3000/resetLatency &

./bin/ulysses-tpf.js ${SERVERS[@]} -f $QUERY -s -r >> $RESFILE 2> $OUTPUT/errors.err
