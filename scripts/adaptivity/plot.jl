# Draw load adaption plot
# Author: Thomas Minier
using Gadfly
using RDatasets
using CalliPlots

custom_theme = Theme(
    key_position = :none,
    bar_spacing = 5px,
    major_label_font_size=15px,
    major_label_font="Computer Modern",
    major_label_color=colorant"#000000",
    minor_label_color=colorant"#000000",
    key_label_color=colorant"#000000",
    bar_highlight=colorant"#000000"
)

Gadfly.push_theme(custom_theme)

function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#FF5733", colorant"#FFC300", colorant"#DAF7A6")
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

function process(filename)
    file = readtable(filename)
    #  rename servers and convert timestamp in second
    for row in eachrow(file)
        row[:target] = serversNames[row[:target]]
        row[:timestamp] = floor(row[:timestamp]/1000)
    end
    # gather number of HTTP calls per server per timestamp
    df = by(file, [:target, :timestamp]) do x
        return nrow(x)
    end
    # gather timestamp by period (0-4, 5-19,20+)
    df = by(df, [:target, :timestamp]) do x
        timeType = "0s to 19s"
        if x[:timestamp][1] >= 20 #&& x[:timestamp][1] <= 30
            timeType = "20s to end"
        # elseif x[:timestamp][1] >= 31
        #     timeType = "31s+"
        end
        return DataFrame(x1 = x[:x1][1], x2 = timeType)
    end
    # sum http calls per server per period
    df = by(df, [:target, :x2]) do x
        return Float64(sum(x[:x1]))
    end
    return df
end

files = [
    "scripts/adaptivity/load_increase_3servers_run1.csv",
    "scripts/adaptivity/load_increase_3servers_run2.csv",
    "scripts/adaptivity/load_increase_3servers_run3.csv"
]
load_3servers = meanDF(:x1, map(process, files)...)

p = plot(load_3servers, xgroup=:x2, x=:target, y=:x1, color=:target,
Geom.subplot_grid(Geom.bar, Scale.x_discrete, free_x_axis=true),
Guide.xlabel("Elapsed time (seconds)"), Guide.ylabel("# HTTP requests"), colors())
draw(PDF("scripts/adaptivity/load_adaptivity.pdf", 4inch, 3inch), p)
draw(PNG("scripts/adaptivity/load_adaptivity.png", 7inch, 3inch), p)
