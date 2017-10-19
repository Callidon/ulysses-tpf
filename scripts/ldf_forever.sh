#!/bin/bash
# Execute a SPARQL query in loop using ldf-client

SERVER=$1
FILE=$2
MODE=$3

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./ldf_forever.sh <server> <file> <mode>"
  exit
fi

LDFBIN="ldf-client"

if [[ "$MODE" = "peneloop" ]]; then
  LDFBIN="bin/peneloop-tpf.js"
fi

while true; do
  $LDFBIN $SERVER -f $FILE -s > /dev/null 2> /dev/null
done
