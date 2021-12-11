# Code of Advent

function get_molluscs(input)
    M = mapreduce(line->parse.(Int, collect(line)), hcat, input)
    outside = Tuple(setdiff(CartesianIndices((0:size(M,1)+1,0:size(M,2)+1)), CartesianIndices(M)))
    (;M, outside, num_flashes=Ref{Int}(0), step=Ref{Int}(0))
end

neigh(ix, exclude) = setdiff(ix - CartesianIndex(1,1):ix + CartesianIndex(1, 1), exclude)

function step!(m)::Bool
    m.step[] += 1
    m.M .+= 1

    has_flashed = falses(size(m.M))
    while true
        new_flashes = m.M .> 9 .&& .~has_flashed
        ~any(new_flashes) && break
        map(ix->m.M[neigh(ix, m.outside)] .+= 1, CartesianIndices(m.M)[new_flashes])
        has_flashed .|= new_flashes
    end
    m.num_flashes[] += count(has_flashed)
    m.M[has_flashed] .= 0

    all(has_flashed)
end

function coa11_part1!(m)
    for i in 1:100
        step!(m)
    end
end

function coa11_part2!(m)
    while true
        step!(m) && return m
    end
    nothing
end

input = readlines("input.txt")

molluscs = get_molluscs(input)

coa11_part1!(molluscs)
@show solution_part1 = molluscs.num_flashes[]

coa11_part2!(molluscs)
@show solution_part2 = molluscs.step[];
