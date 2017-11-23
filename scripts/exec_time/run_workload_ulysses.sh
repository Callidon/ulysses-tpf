#!/bin/bash
# Run a load experiment with the Ulysses TPF client

FILE=$1 # i.e. file that contains SPARQL queries to execute
OUTPUT=$2
NBSERVERS=$3
REF=$4
cpt=1

if [ "$#" -ne 4 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_workload_ulysses.sh <file> <output-folder> <nb-servers> <reference-results>"
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

TIMESFILE="$OUTPUT/execution_times.csv"
COMPLFILE="$OUTPUT/completeness.csv"
# preload file content in a variable
FILECONTENT=`cat ${FILE}`

# init execution time and completeness results
echo "query,time" > $TIMESFILE
echo "query,completeness,soundness,errors" > $COMPLFILE

while IFS='' read -r line; do
  echo -n "${cpt}," >> $TIMESFILE
  ./bin/ulysses-tpf.js $SERVERS -q "${line}" -m $TIMESFILE > $OUTPUT/results/query-$cpt.log 2> $OUTPUT/errors/query-$cpt.err
  # compute completeness and soundness
  echo -n "${cpt}," >> $COMPLFILE
  # completeness
  echo -n `./scripts/compute_completeness.sh ${REF}/query-$cpt.log ${OUTPUT}/results/query-$cpt.log default` >> $COMPLFILE
  echo -n "," >> $COMPLFILE
  # soundness
  echo -n `./scripts/compute_completeness.sh ${REF}/query-$cpt.log ${OUTPUT}/results/query-$cpt.log sound` >> $COMPLFILE
  echo -n "," >> $COMPLFILE
  # nb errors
  echo `wc -l ${OUTPUT}/errors/query-${cpt}.err | cut -d " " -f1` > $COMPLFILE
  # move to next query
  cpt=$((cpt+1))
done <<< "$FILECONTENT"

# remove tmp folders
rm -rf $OUTPUT/results/ $OUTPUT/errors/ 
