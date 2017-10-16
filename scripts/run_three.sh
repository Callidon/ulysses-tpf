#!/bin/bash
# run three times the same workload

FILE=$1
OUTPUTREF=$2
OUTPUTPEN=$3
OUTPUTQUA=$4
OUTPUTALL=$5

if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_three.sh <file> <output-ref> <output-pen> <output-quartz> <output-all>"
  exit
fi

mkdir -p $OUTPUTREF/run1/ $OUTPUTREF/run2/ $OUTPUTREF/run3/
mkdir -p $OUTPUTPEN/run1/ $OUTPUTPEN/run2/ $OUTPUTPEN/run3/
mkdir -p $OUTPUTQUA/run1/ $OUTPUTQUA/run2/ $OUTPUTQUA/run3/
mkdir -p $OUTPUTALL/run1/ $OUTPUTALL/run2/ $OUTPUTALL/run3/

# run reference
# ./scripts/tpf/run_workload_file_ref.sh $FILE $OUTPUTREF/run1/
# ./scripts/tpf/run_workload_file_ref.sh $FILE $OUTPUTREF/run2/
# ./scripts/tpf/run_workload_file_ref.sh $FILE $OUTPUTREF/run3/

# run with prototype (peneloop only)
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTPEN/run1/ peneloop
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTPEN/run2/ peneloop
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTPEN/run3/ peneloop

# run with prototype (quartz only)
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTQUA/run1/ quartz
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTQUA/run2/ quartz
# ./scripts/tpf/run_workload_file.sh $FILE $OUTPUTQUA/run3/ quartz

# run with prototype (all)
./scripts/tpf/run_workload_file.sh $FILE $OUTPUTALL/run1/ all
./scripts/tpf/run_workload_file.sh $FILE $OUTPUTALL/run2/ all
./scripts/tpf/run_workload_file.sh $FILE $OUTPUTALL/run3/ all
