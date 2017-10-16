#!/bin/bash
# Execute a SPARQL query in loop using ldf-client

SERVER=$1
FILE=$2

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./ldf_forever.sh <server> <file>"
  exit
fi

while true; do
  ldf-client $SERVER -f $FILE > /dev/null 2> /dev/null
done
