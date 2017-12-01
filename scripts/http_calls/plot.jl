# Draw main plots for execution time & completeness
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

custom_theme = Theme(
    key_position = :none,
    bar_spacing = 5px
)

Gadfly.push_theme(custom_theme)

function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#ff4000", colorant"#ffbf00")
end

serversNames = Dict(
    "http://curiosiphi:4000/watDiv_100" => "S1",
    "http://curiosiphi:4001/watDiv_100" => "S2",
    "http://curiosiphi:4002/watDiv_100" => "S3",
    "http://curiosiphi:4003/watDiv_100" => "S4",
    "http://curiosiphi:4004/watDiv_100" => "S5",
    "http://curiosiphi:3000/watDiv_100" => "S1",
    "http://curiosiphi:3001/watDiv_100" => "S2",
    "http://curiosiphi:3002/watDiv_100" => "S3",
    "http://curiosiphi:3003/watDiv_100" => "S4",
    "http://curiosiphi:3004/watDiv_100" => "S5",
)

function loadCalls(files...)
    dfs = map(df -> by(df, :target, x -> convert(Float64, nrow(x))), map(readtable, files))
    #rename servers
    dfs = map(dfs) do df
        for row in eachrow(df)
            row[:target] = serversNames[row[:target]]
        end
        return df
    end
    return meanDF(:x1, dfs...)
end

# Build dataframes

calls_ref = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_1server.csv",
    "scripts/curio/run2/http_calls/http_calls_1server.csv",
    "scripts/curio/run3/http_calls/http_calls_1server.csv"
)
calls_ref[:approach] = "1 server"

# Homogeneous setup
calls_2_homo = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_2servers_homo.csv",
    "scripts/curio/run2/http_calls/http_calls_2servers_homo.csv",
    "scripts/curio/run3/http_calls/http_calls_2servers_homo.csv"
)
calls_2_homo[:approach] = "2 servers"

calls_3_homo = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_3servers_homo.csv",
    "scripts/curio/run2/http_calls/http_calls_3servers_homo.csv",
    "scripts/curio/run3/http_calls/http_calls_3servers_homo.csv"
)
calls_3_homo[:approach] = "3 servers"

calls_4_homo = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_4servers_homo.csv",
    "scripts/curio/run2/http_calls/http_calls_4servers_homo.csv",
    "scripts/curio/run3/http_calls/http_calls_4servers_homo.csv"
)
calls_4_homo[:approach] = "4 servers"

# Heterogeneous setup

calls_2_hetero = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_2servers_hetero.csv",
    "scripts/curio/run2/http_calls/http_calls_2servers_hetero.csv",
    "scripts/curio/run3/http_calls/http_calls_2servers_hetero.csv"
)
calls_2_hetero[:approach] = "2 servers"

calls_3_hetero = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_3servers_hetero.csv",
    "scripts/curio/run2/http_calls/http_calls_3servers_hetero.csv",
    "scripts/curio/run3/http_calls/http_calls_3servers_hetero.csv"
)
calls_3_hetero[:approach] = "3 servers"

calls_4_hetero = loadCalls(
    "scripts/curio/run1/http_calls/http_calls_4servers_hetero.csv",
    "scripts/curio/run2/http_calls/http_calls_4servers_hetero.csv",
    "scripts/curio/run3/http_calls/http_calls_4servers_hetero.csv"
)
calls_4_hetero[:approach] = "4 servers"

all_homo = [calls_ref;calls_2_homo;calls_3_homo;calls_4_homo]
all_hetero = [calls_ref;calls_2_hetero;calls_3_hetero;calls_4_hetero]

# Build plots

plot_homo = plot(all_homo, xgroup=:approach, y=:x1, x=:target, color=:approach,
Geom.subplot_grid(Geom.bar, Scale.x_discrete, free_x_axis=true),
Guide.xlabel("Number of homogeneous TPF servers"), Guide.ylabel("Number of HTTP requests"),
Guide.colorkey(""), colors())

plot_hetero = plot(all_hetero, xgroup=:approach, y=:x1, x=:target, color=:approach,
Geom.subplot_grid(Geom.bar, Scale.x_discrete, free_x_axis=true),
Guide.xlabel("Number of heterogeneous TPF servers"), Guide.ylabel("Number of HTTP requests"),
Guide.colorkey(""), colors())

draw(PDF("scripts/curio/http_calls_homo.pdf", 5inch, 3inch), plot_homo)
draw(PDF("scripts/curio/http_calls_hetero.pdf", 5inch, 3inch), plot_hetero)
