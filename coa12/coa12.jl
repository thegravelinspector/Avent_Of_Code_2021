# Code of Advent

function get_transistions(input)
    D = Dict{String, Vector{String}}()
    add(e) = (e[1]!="end" && e[2]!="start") && (D[e[1]] = get(D, e[1], Vector{String}()) ∪ [e[2]])
    map(e->add.([e, reverse(e)]), split.(input, '-'))
    (;transitions=D, walks=Vector{String}[["start"]])
end

function grow!(predicate, trans, walks)
    for walk ∈ walks
        walk[end] == "end" && continue
        append!(walks, [[walk; t] for t in trans[walk[end]] if isuppercase(t[1]) || predicate(t, walk)])
    end
    filter!(walk->walk[end]=="end", walks)
end

reset_walks(graph) = (resize!(graph.walks, 0); push!(graph.walks, ["start"]))
freqs_ok(t, walk) = t ∉ walk || count(count(==(lid), walk)>1 for lid ∈ filter!(islowercase∘first, [walk; t])) <= 1

coa12_part1!(graph) = length(grow!((t,walk) -> t ∉ walk, graph...))
coa12_part2!(graph) = length(grow!(freqs_ok, graph...))

input = readlines("input.txt")

graph = get_transistions(input)
@show coa12_part1!(graph)

reset_walks(graph)
@show coa12_part2!(graph)
