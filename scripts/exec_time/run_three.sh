#!/bin/bash
# run three times the experiment with each mode

source ./scripts/config.cfg

# build directories

TPF_1S="${root_output}/reference-tpf-1servers"
TPF_1S_1="${TPF_1S}-run1"
TPF_1S_2="${TPF_1S}-run2"
TPF_1S_3="${TPF_1S}-run3"

TPF_2S="${root_output}/reference-tpf-2servers"
TPF_2S_1="${TPF_2S}-run1"
TPF_2S_2="${TPF_2S}-run2"
TPF_2S_3="${TPF_2S}-run3"

TPF_3S="${root_output}/reference-tpf-3servers"
TPF_3S_1="${TPF_3S}-run1"
TPF_3S_2="${TPF_3S}-run2"
TPF_3S_3="${TPF_3S}-run3"

ULY_1S="${root_output}/ulysses-1servers"
ULY_1S_1="${ULY_1S}-run1"
ULY_1S_2="${ULY_1S}-run2"
ULY_1S_3="${ULY_1S}-run3"

ULY_2S="${root_output}/ulysses-2servers"
ULY_2S_1="${ULY_2S}-run1"
ULY_2S_2="${ULY_2S}-run2"
ULY_2S_3="${ULY_2S}-run3"

ULY_3S="${root_output}/ulysses-3servers"
ULY_3S_1="${ULY_3S}-run1"
ULY_3S_2="${ULY_3S}-run2"
ULY_3S_3="${ULY_3S}-run3"

mkdir -p TPF_1S_1 TPF_1S_2 TPF_1S_3
mkdir -p TPF_2S_1 TPF_2S_2 TPF_2S_3
mkdir -p TPF_3S_1 TPF_3S_2 TPF_3S_3

mkdir -p ULY_1S_1 ULY_1S_2 ULY_1S_3
mkdir -p ULY_2S_1 ULY_2S_2 ULY_2S_3
mkdir -p ULY_3S_1 ULY_3S_2 ULY_3S_3

# launch TPF servers
ldf-server $ldf_config 4000 4 &
pids+=($!)
ldf-server $ldf_config 4001 4 &
pids+=($!)
ldf-server $ldf_config 4002 4 &
pids+=($!)

sleep 5

# launch latency proxies
scripts/latency_proxy.js http://localhost:4000 $latency -p 3000 &
pids+=($!)
scripts/latency_proxy.js http://localhost:4001 $latency -p 3001 &
pids+=($!)
scripts/latency_proxy.js http://localhost:4002 $latency -p 3002 &
pids+=($!)

sleep 5

# run workload with TPF (1 & 2 & 3 servers)
./scripts/exec_time/run_workload_ref.sh $query_file TPF_1S_1 1
./scripts/exec_time/run_workload_ref.sh $query_file TPF_1S_2 1
./scripts/exec_time/run_workload_ref.sh $query_file TPF_1S_3 1

./scripts/exec_time/run_workload_ref.sh $query_file TPF_2S_1 2
./scripts/exec_time/run_workload_ref.sh $query_file TPF_2S_2 2
./scripts/exec_time/run_workload_ref.sh $query_file TPF_2S_3 2

./scripts/exec_time/run_workload_ref.sh $query_file TPF_3S_1 3
./scripts/exec_time/run_workload_ref.sh $query_file TPF_3S_2 3
./scripts/exec_time/run_workload_ref.sh $query_file TPF_3S_3 3

# run workload with ulysses (1 & 2 & 3 servers)
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_1S_1 1 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_1S_2 1 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_1S_3 1 $reference_results

./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_2S_1 2 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_2S_2 2 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_2S_3 2 $reference_results

./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_3S_1 3 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_3S_2 3 $reference_results
./scripts/exec_time/run_workload_ulysses.sh $query_file ULY_3S_3 3 $reference_results
