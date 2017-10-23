#!/bin/bash
# run three times the experiment with each mode

source ./scripts/config.cfg

# if [ "$#" -ne 5 ]; then
#   echo "Illegal number of parameters."
#   echo "Usage: ./run_three.sh <root-output> <ldf-server-config-file> <servers-latency> <query-file>"
#   exit
# fi

# creates outputs directories

mkdir -p $root_output/output-ldf-run1/ $root_output/output-ldf-run2/ $root_output/output-ldf-run3/
mkdir -p $root_output/output-mixed-run1/ $root_output/output-mixed-run2/ $root_output/output-mixed-run3/
mkdir -p $root_output/output-peneloop-run1/ $root_output/output-peneloop-run2/ $root_output/output-peneloop-run3/

# run exp with ldf mode
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run1/ ref
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run2/ ref
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run3/ ref

# run exp with peneloop mode
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-run1/ peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-run2/ peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-run3/ peneloop

# run exp with tpf+peneloop mode
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-run1/ tpf+peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-run2/ tpf+peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-run3/ tpf+peneloop
