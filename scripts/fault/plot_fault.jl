# Draw fault tolerance plot
# Author: Thomas Minier
using Gadfly
using Compose
using RDatasets
using CalliPlots

custom_theme = Theme(
    major_label_font_size=18px,
    minor_label_font_size=15px,
    major_label_font="Computer Modern",
    major_label_color=colorant"#000000",
    minor_label_color=colorant"#000000"
)

Gadfly.push_theme(custom_theme)

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

function process(filename, approach)
    file = readtable(filename)
    for x in eachrow(file)
        x[:timestamp] = floor(x[:timestamp]/1000)
    end
    df = by(file, :timestamp, nrow)
    df[:approach] = approach
    return df
end

function process2(filename, approach)
    file = readtable(filename)
    #  rename servers
    for row in eachrow(file)
        row[:target] = serversNames[row[:target]]
        row[:timestamp] = floor(row[:timestamp]/1000)
    end
    df = by(file, :timestamp, x -> mean(x[:realTime]))
    df[:approach] = approach
    return df
end

load_2servers = process2("scripts/fault/fault_tolerance_3servers.csv", "normal")

annot_1 = Guide.annotation(compose(context(), text(2.0, 390.0, "Failure of S1"), fontsize(15pt)))
annot_2 = Guide.annotation(compose(context(), text(16.0, 475.0, "Failure of S3"), fontsize(15pt)))
circle_1 = Guide.annotation(compose(context(), circle(5.0, load_2servers[6, :x1], 0.4), fill("red")))
circle_2 = Guide.annotation(compose(context(), circle(20.0, load_2servers[21, :x1], 0.4), fill("red")))

p = plot(load_2servers, x=:timestamp, y=:x1, Geom.line, Geom.point, annot_1, annot_2, circle_1, circle_2,
Guide.xticks(ticks=[0,5,10,15,20,25,30,35,40,45,50]), Guide.xlabel("Elapsed time (seconds)"),
Guide.ylabel("avg. HTTP response time (ms)", orientation=:vertical))
draw(PDF("scripts/fault/fault_tolerance.pdf", 6inch, 3.5inch), p)
