#!/bin/bash
# Run the tpf client with the time in seconds printed in stderr

FILE=$1
OUTPUT=$2

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_with_time_ref.sh <file> <output-folder>"
  exit
fi

RESULTS=`basename $FILE`
# SERVER="http://localhost:8000/watDiv_100"
SERVER="http://34.208.134.212/watDiv_100"

# tell eventual proxies to move to the next query
# GET http://localhost:8000/move-to-query?name=$RESULTS

ldf-client $SERVER -f $FILE -m $OUTPUT/execution_times.csv > $OUTPUT/results/$RESULTS 2> $OUTPUT/errors/$RESULTS
