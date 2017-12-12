# Compute Wilcoxon signed rank tests
# Author: Thomas Minier

using HypothesisTests
using DataFrames
using CalliPlots

# load data, compute mean execution time and then convert them to arrays
time_ref = Array(computeMean(
    :time,
    "/home/stagiaire-gdd/experiments-ulysses/reference-tpf-1servers-run1/execution_times_ref_1servers.csv"
)[:time])

ulysses_1s = Array(computeMean(
    :time,
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-1servers-run1/execution_times_ulysses_1servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-1servers-run2/execution_times_ulysses_1servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-1servers-run3/execution_times_ulysses_1servers.csv"
)[:time])

ulysses_2s = Array(computeMean(
    :time,
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-2servers-run1/execution_times_ulysses_2servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-2servers-run2/execution_times_ulysses_2servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-2servers-run3/execution_times_ulysses_2servers.csv"
)[:time])

ulysses_3s = Array(computeMean(
    :time,
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-3servers-run1/execution_times_ulysses_3servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-3servers-run2/execution_times_ulysses_3servers.csv",
    "/home/stagiaire-gdd/experiments-ulysses/ulysses-3servers-run3/execution_times_ulysses_3servers.csv"
)[:time])

pval_1s = pvalue(SignedRankTest(time_ref, ulysses_1s), tail=:left)
pval_2s = pvalue(SignedRankTest(time_ref, ulysses_2s), tail=:left)
pval_3s = pvalue(SignedRankTest(time_ref, ulysses_3s), tail=:left)
results = DataFrame(servers = [1, 2, 3], pvalue = [pval_1s, pval_2s, pval_3s])
println(results)
