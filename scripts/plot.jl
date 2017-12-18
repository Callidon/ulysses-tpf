# Draw main plots for execution time & completeness
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

custom_theme = Theme(
    key_position = :top,
    major_label_font_size=15px,
    major_label_font="Computer Modern",
    major_label_color=colorant"#000000",
    minor_label_color=colorant"#000000",
    key_label_color=colorant"#000000"
)

Gadfly.push_theme(custom_theme)

function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#ff4000", colorant"#ffbf00")
end

# Execution times

time_ref = computeMean(
    :time,
    "scripts/curio/run1/execution_times_ref.csv",
    "scripts/curio/run2/execution_times_ref.csv",
    "scripts/curio/run3/execution_times_ref.csv"
)
time_ref[:approach] = "1 (TPF) "

time_2s = computeMean(
    :time,
    "scripts/curio/run1/execution_times_2servers.csv",
    "scripts/curio/run2/execution_times_2servers.csv",
    "scripts/curio/run3/execution_times_2servers.csv"
)
time_2s[:approach] = "2"

time_3s = computeMean(
    :time,
    "scripts/curio/run1/execution_times_3servers.csv",
    "scripts/curio/run2/execution_times_3servers.csv",
    "scripts/curio/run3/execution_times_3servers.csv"
)
time_3s[:approach] = "3"

time_20s = computeMean(
    :time,
    "scripts/curio/run1/execution_times_20servers.csv",
    "scripts/curio/run2/execution_times_20servers.csv",
    "scripts/curio/run3/execution_times_20servers.csv"
)
time_20s[:approach] = "20"


all = [time_ref;time_2s;time_3s;time_20s]

# RAW version
# p = plot([time_ref;time_mixed;time_ulysses], y=:time, x=:clients, color=:approach, Geom.line, Guide.xlabel("Number of clients"), Guide.ylabel("Execution time (s)"), Scale.x_discrete)
# Smooth version
p = plot(all, y=:time, x=:clients, color=:approach, Geom.smooth(method=:loess, smoothing=0.75),
Guide.xlabel("Number of concurrent clients executing the query"), Guide.ylabel("avg. execution time (s)"), Guide.xticks(ticks=[1, 10, 20, 50, 100]),
Guide.colorkey("Number of server(s)"), colors())

draw(PDF("scripts/curio/execution_time_with_load.pdf", 5inch, 3inch), p)
# draw(PNG("scripts/curio/execution_time_with_load.png", 15inch, 7inch), p)
