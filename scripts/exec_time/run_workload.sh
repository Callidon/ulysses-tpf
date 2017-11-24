#!/bin/bash
# Run execution time + completeness/soundness experiment

MODE=$1 # by default, run with classic TPF client. With MODE="ulysses", run ulysses client
FILE=$2 # i.e. file that contains SPARQL queries to execute
OUTPUT=$3
NBSERVERS=$4 # number of servers (1, 2 or 3). Default to 1
REF=$5 # folder where reference results are stored. used to compute completeness & soundness
cpt=1

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_workload_ref.sh <mode> <file> <output-folder> <nb-servers> <reference-results>"
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

RESFILE="${OUTPUT}/execution_times_ref_${NBSERVERS}servers.csv"
BIN="./bin/reference.js"

if [[ "$MODE" = "ulysses" ]]; then
  RESFILE="${OUTPUT}/execution_times_ulysses_${NBSERVERS}servers.csv"
  BIN="./bin/ulysses-tpf.js"
fi

# preload file content in a variable
FILECONTENT=`cat ${FILE}`

# init results file with headers
echo "query,time,completeness,soundness,errors" > $RESFILE

while IFS='' read -r line; do
  echo -n "${cpt}," >> $RESFILE
  # execution time
  $BIN $SERVERS -q "${line}" -m $RESFILE > $OUTPUT/results/query-$cpt.log 2> $OUTPUT/errors/query-$cpt.err
  echo -n "," >> $RESFILE
  # completeness
  echo -n `./scripts/compute_completeness.sh ${REF}/query-$cpt.log ${OUTPUT}/results/query-$cpt.log default` >> $RESFILE
  echo -n "," >> $RESFILE
  # soundness
  echo -n `./scripts/compute_completeness.sh ${REF}/query-$cpt.log ${OUTPUT}/results/query-$cpt.log sound` >> $RESFILE
  echo -n "," >> $RESFILE
  # nb errors during query processing
  echo `wc -l ${OUTPUT}/errors/query-${cpt}.err | cut -d " " -f1` >> $RESFILE
  # move to next query
  cpt=$((cpt+1))
done <<< "$FILECONTENT"

# remove tmp folders
rm -rf $OUTPUT/results/ $OUTPUT/errors/
