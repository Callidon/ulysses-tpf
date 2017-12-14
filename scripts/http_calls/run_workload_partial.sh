#!/bin/bash
# Run nb http calls experiment

FILE=$1 # i.e. file that contains a SPARQL query to execute
OUTPUT=$2
CATALOG=$3
NBSERVERS=$4 # number of servers
cpt=1

if [ "$#" -ne 4 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_workload_ref.sh <file-query> <output-folder> <catalog-file> <nb-servers>"
  exit
fi

# server(s) to use (without proxy, as exec time does not matter here)
SPORT=4000
SERVERS=()
for x in $(seq 1 $NBSERVERS); do
  SERVERS+=("http://curiosiphi:${SPORT}/watDiv_100")
  SPORT=$((SPORT+1))
done

QUERYNAME=`basename ${FILE}`

RESFILE="${OUTPUT}/${QUERYNAME}_http_calls_${NBSERVERS}servers_partial.csv"
echo "target,timestamp,time,realtime,strpattern" > $RESFILE

# preload file content in a variable
FILECONTENT=`cat ${FILE}`

while IFS='' read -r line; do
  echo "executing query n${cpt}"
  ./bin/ulysses-tpf.js ${SERVERS[@]} -q "${line}" -c $CATALOG -r -s >> $RESFILE
  # move to next query
  cpt=$((cpt+1))
done <<< "$FILECONTENT"
