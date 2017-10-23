# Draw main plots for execution time & completeness
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

# Execution times

time_ref = computeMean([
    "curio/run1/execution_times_ref.csv",
    "curio/run2/execution_times_ref.csv",
    "curio/run3/execution_times_ref.csv"
]) do df
    df[:approach] = "TPF"
end

time_peneloop = computeMean([
    "curio/run1/execution_times.csv",
    "curio/run2/execution_times.csv",
    "curio/run3/execution_times.csv"
]) do df
    df[:approach] = "TPF + PeNeLoop"
end

# time_ref = readtable("curio/execution_times_ref.csv")
# time_peneloop = readtable("curio/execution_times.csv")
#
# time_ref[:approach] = "TPF"
# time_peneloop[:approach] = "TPF + PeNeLoop"

p = plot([time_ref;time_peneloop], y=:mean_value, x=:clients, color=:approach, Geom.line, Guide.xlabel("Number of clients"), Guide.ylabel("Execution time (s)"), Scale.x_discrete)

# execution times plots
draw(PDF("curio/execution_time.pdf", 15inch, 7inch), p)
