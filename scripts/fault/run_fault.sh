#!/bin/bash
# run fault tolerance experiment

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
  GET http://curiosiphi:${SPORT}/resetLatency
  GET http://curiosiphi:${SPORT}/revive
  SERVERS+=("http://curiosiphi:${SPORT}/watDiv_100")
  SPORT=$((SPORT+1))
done

RESFILE="${OUTPUT}/fault_tolerance_${NBSERVERS}servers.csv"
echo "target,timestamp,time,realTime" > $RESFILE

# wait 15s and then kill S1
sleep 5 && GET http://curiosiphi:3000/fakeDeath &
# wait 30 s and kill S2
sleep 20 && GET http://curiosiphi:3002/fakeDeath &

./bin/ulysses-tpf.js ${SERVERS[@]} -f $QUERY -s -r >> $RESFILE 2> $OUTPUT/errors.err

# reset S1 & S2 afterward
GET http://curiosiphi:3000/revive
GET http://curiosiphi:3002/revive
