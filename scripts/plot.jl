# Draw main plots for execution time & completeness
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

# Execution times

time_ref = computeMean(
    :time,
    "curio/run1/execution_times_ref.csv",
    "curio/run2/execution_times_ref.csv",
    "curio/run3/execution_times_ref.csv"
)
time_ref[:approach] = "TPF 1 server"

time_2s = computeMean(
    :time,
    "curio/run1/execution_times_2servers.csv",
    "curio/run2/execution_times_2servers.csv",
    "curio/run3/execution_times_2servers.csv"
)
time_2s[:approach] = "Ulysses 2 servers"

time_3s = computeMean(
    :time,
    "curio/run1/execution_times_3servers.csv",
    "curio/run2/execution_times_3servers.csv",
    "curio/run3/execution_times_3servers.csv"
)
time_3s[:approach] = "Ulysses 3 servers"

time_20s = computeMean(
    :time,
    "curio/run1/execution_times_20servers.csv",
    "curio/run2/execution_times_20servers.csv",
    "curio/run3/execution_times_20servers.csv"
)
time_20s[:approach] = "Ulysses 20 servers"


all = [time_ref;time_2s;time_3s;time_20s]

# RAW version
# p = plot([time_ref;time_mixed;time_ulysses], y=:time, x=:clients, color=:approach, Geom.line, Guide.xlabel("Number of clients"), Guide.ylabel("Execution time (s)"), Scale.x_discrete)
# Smooth version
p = plot(all, y=:time, x=:clients, color=:approach, Geom.smooth(method=:loess, smoothing=0.75),
Guide.xlabel("Number of clients executing the query in parallel"), Guide.ylabel("Execution time (s)"), Guide.colorkey("Type of clients"), Scale.x_discrete)

# execution times plots
draw(PDF("curio/execution_time_with_load.pdf", 15inch, 7inch), p)
# draw(PNG("curio/execution_time_with_load.png", 15inch, 7inch), p)
