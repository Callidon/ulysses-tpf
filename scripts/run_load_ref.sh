#!/bin/bash
# Run a load experiment with the reference TPF client

FILE=$1 # i.e. file that contains a SPARQL query to execute
OUTPUT=$2
MODE="ldf"

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_load_ref.sh <file> <output-folder>"
  exit
fi

QUERYFILE=`basename $FILE`
NBCLIENTS=(1 2 3 4 5 6 7 8 9 10 15 20 25 30 35 45 50 60 70 80 90 100)

# server to use & load
# SERVER="http://34.208.134.212/watDiv_100" # AWS server
SERVER="http://localhost:3000/watDiv_100" # local server

mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

echo "clients,time" > $OUTPUT/execution_times_ref.csv

# run with each number of clients
for nb in ${NBCLIENTS[@]}; do
  pids=()
  echo -n "$nb," >> $OUTPUT/execution_times_ref.csv

  # generate load
  for (( c=1; c<=$nb; c++ ))
  do
    ./scripts/ldf_forever.sh $SERVER $FILE $MODE &
    pids+=($!)
  done

  # give some time for clients to start processing
  sleep 5

  bin/reference.js $SERVER -f $FILE -m $OUTPUT/execution_times_ref.csv > $OUTPUT/results/$QUERYFILE-$nb-ref 2> $OUTPUT/errors/$QUERYFILE-$nb-ref

  # kill clients
  kill -9 ${pids[@]} > /dev/null 2> /dev/null
done
