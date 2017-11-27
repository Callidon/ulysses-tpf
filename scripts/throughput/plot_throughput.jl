# Draw throughput plots
# Author: Thomas Minier
using Gadfly
using Compose
using RDatasets
using CalliPlots

function process(filename, approach)
    file = readtable(filename)
    for x in eachrow(file)
        x[:timestamp] = floor(x[:timestamp]/1000)
    end
    df = by(file, :timestamp, nrow)
    df[:approach] = approach
    return df
end

ref = process("reference.csv", "normal")
first = process("results.csv", "first")

annot_1 = Guide.annotation(compose(context(), line([(15.00,1),(15.0,100)]), fill(nothing), stroke("orange")))
annot_2 = Guide.annotation(compose(context(), line([(20.00,1),(20.0,100)]), fill(nothing), stroke("orange")))
annot_3 = Guide.annotation(compose(context(), line([(25.00,1),(25.0,100)]), fill(nothing), stroke("orange")))
annot_4 = Guide.annotation(compose(context(), line([(30.00,1),(30.0,100)]), fill(nothing), stroke("orange")))

p = plot([ref;first], x=:timestamp, y=:x1, color=:approach, Geom.line, annot_1, annot_2, annot_3, annot_4)
draw(PDF("throughput.pdf", 15inch, 7inch), p)
