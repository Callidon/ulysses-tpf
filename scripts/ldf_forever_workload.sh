#!/bin/bash
# Execute a SPARQL query in loop using ldf-client

SERVER=$1
FILE=$2
MODE=$3

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./ldf_forever.sh <server> <queries-file> <mode>"
  exit
fi

LDFBIN="ldf-client"

if [[ "$MODE" = "ulysses" ]]; then
  LDFBIN="bin/ulysses-tpf.js"
fi

# preload file content in a variable
FILECONTENT=`cat ${FILE}`

while true; do
  while read -r line; do
    $LDFBIN $SERVER -q "${line}" -s > /dev/null 2> /dev/null
  done <<< "$FILECONTENT"
done
