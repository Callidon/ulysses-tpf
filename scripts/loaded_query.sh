#!/bin/bash
# Run the reference tpf client while generating load on TPF servers

FILE=$1
OUTPUT=$2
NBCLIENTS=$3

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./loaded_query.sh <file> <output-folder> <nb-concurrent-clients>"
  exit
fi

RESULTS=`basename $FILE`
# server to load
SERVER="http://34.208.134.212/watDiv_100"
# servers used by peneloop
SEVERS="http://34.208.134.212/watDiv_100 http://34.208.134.212/watDiv_100"

mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

pids=()
echo -n "$NBCLIENTS," >> $OUTPUT/execution_times.csv

# tell eventual proxies to move to the next query
# GET http://localhost:8000/move-to-query?name=$RESULTS
# GET http://localhost:8001/move-to-query?name=$RESULTS

# generate load
for (( c=1; c<=$NBCLIENTS; c++ ))
do
  ./scripts/ldf-forever.sh $SERVER $FILE &
  pids+=($!)
done

bin/peneloop-tpf.js $SERVERS -f $FILE -m $OUTPUT/execution_times.csv > $OUTPUT/results/$RESULTS-$NBCLIENTS 2> $OUTPUT/errors/$RESULTS-$NBCLIENTS

# kill clients
kill -9 ${pids[@]} > /dev/null 2> /dev/null
