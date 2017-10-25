#!/bin/bash
# run three times the experiment with each mode

source ./scripts/config.cfg

# creates outputs directories

# mkdir -p $root_output/output-ldf-run1/ $root_output/output-ldf-run2/ $root_output/output-ldf-run3/
mkdir -p $root_output/output-mixed-3servers-run1/ $root_output/output-mixed-3servers-run2/ $root_output/output-mixed-3servers-run3/
mkdir -p $root_output/output-peneloop-3servers-run1/ $root_output/output-peneloop-3servers-run2/ $root_output/output-peneloop-3servers-run3/

# run exp with ldf mode
# ./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run1/ ref
# ./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run2/ ref
# ./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-ldf-run3/ ref

# run exp with peneloop mode
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-3servers-run1/ peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-3servers-run2/ peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-peneloop-3servers-run3/ peneloop

# run exp with tpf+peneloop mode
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-3servers-run1/ tpf+peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-3servers-run2/ tpf+peneloop
./scripts/launch_run.sh $ldf_config $latency $query_file $root_output/output-mixed-3servers-run3/ tpf+peneloop
