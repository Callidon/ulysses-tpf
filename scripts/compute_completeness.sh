#!/bin/bash
# Compute completeness between two files which contains results

reference=$1
results=$2
mode=$3

if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./compute_completeness.sh <reference-file> <results> <mode>"
  exit
fi

sort $reference > tempRef
sort $results > tempRes
# compute soundness rather than completeness
if [[ "$mode" = "sound" ]]; then
  groundTruth=`wc -l tempRes | sed 's/^[ ^t]*//' | cut -d' ' -f1`
else
  groundTruth=`wc -l tempRef | sed 's/^[ ^t]*//' | cut -d' ' -f1`
fi
commons=`comm -12 tempRef tempRes | wc -l`
completeness=`echo "scale=2; $commons/$groundTruth" | bc`
echo $completeness

rm -f tempRef tempRes
