# Draw fault tolerance plot
# Author: Thomas Minier
using Gadfly
using Compose
using RDatasets
using CalliPlots

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

annot_1 = Guide.annotation(compose(context(), line([(5.00,1),(5.0,400)]), fill(nothing), stroke("orange")))
annot_2 = Guide.annotation(compose(context(), line([(20.00,1),(20.0,400)]), fill(nothing), stroke("orange")))

p = plot(load_2servers, x=:timestamp, y=:x1, color=:approach, Geom.line, annot_1, annot_2)
draw(PDF("scripts/fault/fault_tolerance.pdf", 15inch, 7inch), p)
