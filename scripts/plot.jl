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
time_ref[:approach] = "TPF only"

time_ulysses = computeMean(
    :time,
    "curio/run1/execution_times_ulysses.csv",
    "curio/run2/execution_times_ulysses.csv",
    "curio/run3/execution_times_ulysses.csv"
)
time_ulysses[:approach] = "PeNeLoop only"

time_mixed = computeMean(
    :time,
    "curio/run1/execution_times_mixed.csv",
    "curio/run2/execution_times_mixed.csv",
    "curio/run3/execution_times_mixed.csv"
)
time_mixed[:approach] = "PeNeLoop + TPF"

time_ulysses_3s = computeMean(
    :time,
    "curio/run1/execution_times_ulysses_3servers.csv",
    "curio/run2/execution_times_ulysses_3servers.csv",
    "curio/run3/execution_times_ulysses_3servers.csv"
)
time_ulysses_3s[:approach] = "PeNeLoop only"

time_mixed_3s = computeMean(
    :time,
    "curio/run1/execution_times_mixed_3servers.csv",
    "curio/run2/execution_times_mixed_3servers.csv",
    "curio/run3/execution_times_mixed_3servers.csv"
)
time_mixed_3s[:approach] = "PeNeLoop + TPF"

# RAW version
# p = plot([time_ref;time_mixed;time_ulysses], y=:time, x=:clients, color=:approach, Geom.line, Guide.xlabel("Number of clients"), Guide.ylabel("Execution time (s)"), Scale.x_discrete)
# Smooth version
p = plot([time_ref;time_mixed;time_ulysses], y=:time, x=:clients, color=:approach, Geom.smooth(method=:loess, smoothing=0.75),
Guide.xlabel("Number of clients executing the query in parallel"), Guide.ylabel("Execution time (s)"), Guide.colorkey("Type of clients"), Scale.x_discrete)
p_3s = plot([time_ref;time_mixed_3s;time_ulysses_3s], y=:time, x=:clients, color=:approach, Geom.smooth(method=:loess, smoothing=0.75),
Guide.xlabel("Number of clients executing the query in parallel"), Guide.ylabel("Execution time (s)"), Guide.colorkey("Type of clients"), Scale.x_discrete)

# execution times plots
draw(PDF("curio/execution_time_2servers.pdf", 15inch, 7inch), p)
draw(PDF("curio/execution_time_3servers.pdf", 15inch, 7inch), p_3s)
draw(PNG("curio/execution_time_2servers.png", 15inch, 7inch), p)
draw(PNG("curio/execution_time_3servers.png", 15inch, 7inch), p_3s)
