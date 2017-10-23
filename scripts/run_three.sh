#!/bin/bash
# run three times the experiment with each mode

FILE=$1
ROOT=$2
CONFIG=$3
LATENCY=$4
QUERYFILE=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_three.sh <file> <root-output> <ldf-server-config-file> <servers-latency> <query-file>"
  exit
fi

# creates outputs directories

mkdir -p $ROOT/output-ldf-run1/ $ROOT/output-ldf-run2/ $ROOT/output-ldf-run3/
mkdir -p $ROOT/output-mixed-run1/ $ROOT/output-mixed-run2/ $ROOT/output-mixed-run3/
mkdir -p $ROOT/output-peneloop-run1/ $ROOT/output-peneloop-run2/ $ROOT/output-peneloop-run3/

# run exp with ldf mode
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-ldf-run1/ ref
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-ldf-run2/ ref
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-ldf-run3/ ref

# run exp with peneloop mode
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-peneloop-run1/ peneloop
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-peneloop-run2/ peneloop
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-peneloop-run3/ peneloop

# run exp with tpf+peneloop mode
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-mixed-run1/ tpf+peneloop
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-mixed-run2/ tpf+peneloop
./scripts/launch_run.sh $CONFIG $LATENCY $QUERYFILE $ROOT/output-mixed-run3/ tpf+peneloop
