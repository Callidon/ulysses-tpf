#!/bin/bash
# Run nb http calls experiment

FILE=$1 # i.e. file that contains SPARQL queries to execute
OUTPUT=$2
NBSERVERS=$3 # number of servers
cpt=1

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_workload.sh <file> <output-folder> <nb-servers>"
  exit
fi

# server(s) to use (without proxy, as exec time does not matter here)
# SPORT=3000
# SERVERS=()
# for x in $(seq 1 $NBSERVERS); do
#   SERVERS+=("http://curiosiphi:${SPORT}/watDiv_100")
#   SPORT=$((SPORT+1))
# done

SERVERS=("http://fragments.dbpedia.org/2015-10/en" "http://fragments.mementodepot.org/dbpedia_201510")

# RESFILE="${OUTPUT}/http_calls_${NBSERVERS}servers_hetero.csv"
RESFILE="${OUTPUT}/http_calls_usewod2016_dbpedia.csv"
echo "target,timestamp,time,realtime,strpattern" > $RESFILE

# preload file content in a variable
FILECONTENT=`cat ${FILE}`

while IFS='' read -r line; do
  echo "executing query n${cpt}"
  ./bin/ulysses-tpf.js ${SERVERS[@]} -q "${line}" -r -s >> $RESFILE #2> /dev/null
  # move to next query
  cpt=$((cpt+1))
done <<< "$FILECONTENT"
