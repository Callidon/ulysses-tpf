#!/bin/bash
# Run a load experiment with ulysses

FILE=$1 # i.e. file that contains a SPARQL query to execute
OUTPUT=$2
MODE=$3
NBLOADED=$4

if [ "$#" -ne 4 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_load.sh <file> <output-folder> <mode> <nb-loaded-servers>"
  exit
fi

QUERYFILE=`basename $FILE`
NBCLIENTS=(1 2 3 4 5 6 7 8 9 10 15 20 25 30 35 45 50 60 70 80 90 100)

# servers used by ulysses
# SERVERS="http://34.208.134.212/watDiv_100 http://52.10.10.208/watDiv_100" # AWS servers
SERVERS=("http://localhost:3000/watDiv_100" "http://localhost:3001/watDiv_100" "http://localhost:3002/watDiv_100") # local servers

mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

echo -n "clients,time" > $OUTPUT/execution_times.csv
for (( i=0; i<${#SERVERS[@]}; i++ )); do
  echo -n ",E$i" >> $OUTPUT/execution_times.csv
done

# add a \n
echo >> $OUTPUT/execution_times.csv

# run with each number of clients
for nb in ${NBCLIENTS[@]}; do
  pids=()
  echo -n "$nb," >> $OUTPUT/execution_times.csv

  # generate load for NBLOADED server(s)
  for (( c=1; c<=$nb; c++ )); do
    # ulysses clients already query N clients
    if [[ "$MODE" = "ulysses" ]]; then
      {
        while true; do
          bin/ulysses-tpf.js ${SERVERS[@]} -f $FILE -s > /dev/null 2> /dev/null
        done
      } &
      pids+=($!)
    else
      #  generate load for NBLOADED server(s)
      for (( x=0; x<$NBLOADED; x++)); do
        ./scripts/ldf_forever.sh ${SERVERS[x]} $FILE &
        pids+=($!)
      done
    fi
  done

  # give some time for clients to start processing
  sleep 5

  bin/ulysses-tpf.js ${SERVERS[@]} -f $FILE -m $OUTPUT/execution_times.csv > $OUTPUT/results/$QUERYFILE-$nb 2> $OUTPUT/errors/$QUERYFILE-$nb

  # kill clients
  kill -9 ${pids[@]} > /dev/null 2> /dev/null
done
