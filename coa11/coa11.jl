# Code of Advent

function get_molluscs(input)
    A = mapreduce(line->parse.(Int, collect(line)), hcat, input)
    M = fill(-1, size(A).+2)
    M[2:end-1, 2:end-1] = A
    (;M, ixs=CartesianIndices((2:size(A,1)+1, 2:size(A,2)+1)), num_flashes=Ref{Int}(0), step=Ref{Int}(0))
end

neigh(ix) = ix - CartesianIndex(1,1):ix + CartesianIndex(1, 1)
reset_border!(m) = (m.M[[1,end],:] .= -1, m.M[:,[1,end]] .= -1)

function step!(m)::Bool
    m.step[] += 1
    m.M .+= 1
    reset_border!(m)

    has_flashed = falses(size(m.M))
    while true
        new_flashes = (m.M .* .~has_flashed) .> 9
        ~any(new_flashes) && break
        map(ix->m.M[neigh(ix)] .+= 1, CartesianIndices(m.M)[new_flashes])
        reset_border!(m)
        has_flashed .|= new_flashes
    end
    m.num_flashes[] += count(has_flashed)
    m.M[has_flashed] .= 0

    all(has_flashed[2:end-1, 2:end-1])
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
