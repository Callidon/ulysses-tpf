# Draw main plots for http calls per triple pattern per query with partial replication
# Author: Thomas Minier
using Compose
using Gadfly
using RDatasets
using CalliPlots

custom_theme = Theme(
    key_position = :top,
    bar_spacing = 7px,
    major_label_font_size=18px,
    minor_label_font_size=12px,
    major_label_font="Computer Modern",
    major_label_color=colorant"#000000",
    minor_label_color=colorant"#000000",
    key_label_color=colorant"#000000"
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
    dfs = map(df -> by(df, [:target, :strpattern], nrow), map(readtable, files))
    sumCalls = Dict()
    dfs = map(dfs) do df
        patternPerServer = Dict()
        # patterns names are per query
        patternNames = Dict()
        patterns = Set()
        patternCpt = 0
        # rename servers & pattern
        for row in eachrow(df)
            row[:target] = serversNames[row[:target]]
            # register pattern per server
            if (! haskey(patternPerServer, row[:target]))
                patternPerServer[row[:target]] = Set()
            end

            # rename pattern
            if (! haskey(patternNames, row[:strpattern]))
                patternCpt += 1
                patternNames[row[:strpattern]] = "tp$patternCpt"
                patterns = union(patterns, Set(["tp$patternCpt"]))
            end
            row[:strpattern] = patternNames[row[:strpattern]]
            patternPerServer[row[:target]] = union(patternPerServer[row[:target]], Set([row[:strpattern]]))
            # register nb calls per pattern
            if (! haskey(sumCalls, row[:strpattern]))
                sumCalls[row[:strpattern]] = 0
            end
            sumCalls[row[:strpattern]] += row[:x1]
        end
        # fill missing values
        for (s, p) in patternPerServer
            missings = setdiff(patterns, p)
            for pattern in p
                push!(df, [s, pattern, 0])
            end
        end
        return df
    end
    return (meanDF(:x1, dfs...), sumCalls)
end

# Build dataframes

(calls_q90, sumCalls90) = loadCalls(
    "scripts/http_calls/expensive_queries/q90_http_calls_4servers_partial.csv"
)
calls_q90[:query] = "Q90"

(calls_q48, sumCalls48) = loadCalls(
    "scripts/http_calls/expensive_queries/q48_http_calls_4servers_partial.csv"
)
calls_q48[:query] = "Q48"

(calls_q17, sumCalls17) = loadCalls(
    "scripts/http_calls/expensive_queries/q17_http_calls_4servers_partial.csv"
)
calls_q17[:query] = "Q17"

(calls_q54, sumCalls54) = loadCalls(
    "scripts/http_calls/expensive_queries/q54_http_calls_4servers_partial.csv"
)
calls_q54[:query] = "Q54"

(calls_q52, sumCalls52) = loadCalls(
    "scripts/http_calls/expensive_queries/q52_http_calls_4servers_partial.csv"
)
calls_q52[:query] = "Q52"

all = [calls_q90;calls_q48;calls_q17;calls_q54;calls_q52]
group1 = [calls_q90;calls_q48;calls_q52]
group2 = [calls_q17;calls_q54]

# Build plots

plot1 = plot(group1, xgroup="query", y="x1", x="strpattern", color="target",
Geom.subplot_grid(Geom.bar(position=:stack), free_x_axis=true, Guide.xticks(orientation=:vertical)),
Guide.xlabel("Triple pattern by query"), Guide.ylabel("# HTTP requests"),
Guide.colorkey("TPF servers"), colors())

plot2 = plot(group2, xgroup="query", y="x1", x="strpattern", color="target",
Geom.subplot_grid(Geom.bar(position=:stack), free_x_axis=true, Guide.xticks(orientation=:vertical)),
Guide.xlabel("Triple pattern by query"), Guide.ylabel("# HTTP requests"),
Guide.colorkey("TPF servers"), colors())

draw(PDF("scripts/curio/http_calls_partial.pdf", 10inch, 4inch), hstack(plot1, plot2))
