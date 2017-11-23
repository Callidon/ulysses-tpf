#!/bin/bash
# Run a load experiment with the reference TPF client

FILE=$1 # i.e. file that contains SPARQL queries to execute
OUTPUT=$2
NBSERVERS=$3
cpt=1

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_workload_ref.sh <file> <output-folder> <nb-servers>"
  exit
fi

# server(s) to use
SERVERS="http://localhost:3000/watDiv_100"

if [[ "$NBSERVERS" = "2" ]]; then
  SERVERS="$SERVERS http://localhost:3001/watDiv_100"
elif [[ "$NBSERVERS" = "3" ]]; then
  SERVERS="$SERVERS http://localhost:3001/watDiv_100 http://localhost:3002/watDiv_100"
fi

mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

# preload file content in a variable
FILECONTENT=`cat ${FILE}`

echo "query,time" > $OUTPUT/execution_times_ref.csv

while IFS='' read -r line; do
  echo -n "${cpt}," >> $OUTPUT/execution_times_ref.csv
  ./bin/reference.js $SERVERS -q "${line}" -m $OUTPUT/execution_times_ref.csv > $OUTPUT/results/query-$cpt.log 2> $OUTPUT/errors/query-$cpt.err
  cpt=$((cpt+1))
done <<< "$FILECONTENT"

# remove tmp folders
rm -rf $OUTPUT/results/ $OUTPUT/errors/ 
