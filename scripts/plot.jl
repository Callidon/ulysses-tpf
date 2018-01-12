# Draw main plots for execution time & completeness
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

custom_theme = Theme(
    key_position = :top,
    line_width=2px,
    major_label_font_size=15px,
    key_title_font_size=18px,
    key_label_font_size=15px,
    major_label_font="Computer Modern",
    major_label_color=colorant"#000000",
    minor_label_color=colorant"#000000",
    key_label_color=colorant"#000000"
)

Gadfly.push_theme(custom_theme)

function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#FF5733", colorant"#FFC300", colorant"#b1d073")
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

layer_ref = layer(time_ref, y=:time, x=:clients, size=[5px], Geom.point, Geom.line, Theme(point_shapes=Function[Gadfly.diamond], default_color=colorant"#990000"))
layer_2s = layer(time_2s, y=:time, x=:clients, size=[5px], Geom.point, Geom.line, Theme(point_shapes=Function[Gadfly.square], line_style=:dash, default_color=colorant"#FF5733"))
layer_3s = layer(time_3s, y=:time, x=:clients, size=[5px], Geom.point, Geom.line, Theme(point_shapes=Function[Gadfly.cross], default_color=colorant"#FFC300"))
layer_20s = layer(time_20s, y=:time, x=:clients, size=[5px], Geom.point, Geom.line, Theme(point_shapes=Function[Gadfly.dtriangle], line_style=:dash, default_color=colorant"#b1d073"))

color_guide = Guide.manual_color_key("Number of servers",
                            ["1 (TPF) ", "2", "3", "4"],
                            [colorant"#990000", colorant"#FF5733", colorant"#FFC300", colorant"#b1d073"])

p = plot(layer_ref,layer_2s, layer_3s, layer_20s, Guide.xlabel("Number of concurrent clients executing the query"), Guide.ylabel("avg. execution time (s)", orientation=:vertical), Guide.xticks(ticks=[1, 10, 20, 50, 100]), color_guide)

# RAW version
# p = plot([time_ref;time_mixed;time_ulysses], y=:time, x=:clients, color=:approach, Geom.line, Guide.xlabel("Number of clients"), Guide.ylabel("Execution time (s)"), Scale.x_discrete)
# Smooth version
# p = plot(all, y=:time, x=:clients, color=:approach, Geom.point, Geom.line(), #method=:loess, smoothing=0.75
# )

draw(PDF("scripts/curio/execution_time_with_load.pdf", 7inch, 3inch), p)
draw(PNG("scripts/curio/execution_time_with_load.png", 7inch, 3inch), p)
