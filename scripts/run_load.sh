#!/bin/bash
# Run a load experiment

FILE=$1 # i.e. file that contains the query
OUTPUT=$2

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_load.sh <file> <output-folder>"
  exit
fi

NBCLIENTS=(2 3 4 5 6 7 8 9 10 15 20 25 30 35 45 50 60 70 80 90 100)

echo "clients,time" > $OUTPUT/execution_times.csv
echo -n "1," >> $OUTPUT/execution_times.csv

# run with only one client first
./scripts/run_with_time_ref.sh $FILE $OUTPUT

# run with different number of clients
for nb in ${NBCLIENTS[@]}; do
  ./scripts/loaded_query.sh $FILE $OUTPUT $nb
done
