# Code of Advent

function fuelcost(pos, initial_positions, dragfnc=identity)
    sum(dragfnc∘abs, initial_positions .- pos)
end

crabdrag(n) = n*(n+1) ÷ 2

mean(v) = sum(v)/length(v)
median(v) = mean(sort!(v)[(length(v)+1)÷2:length(v)÷2+1])

function coa07_part1(positions)
    fuelcost(round(Int, median(positions)), positions)
end

function coa07_part2(positions)
    lo = floor(Int, mean(positions))
    minimum(fuelcost(pos, positions, crabdrag) for pos in [lo,lo+1])
end

# The whale is like darnit

input = readline("input.txt")

positions = parse.(Int, split(input, ','))
@show coa07_part1(positions)
@show coa07_part2(positions)

using BenchmarkTools

function benchit(input)
    positions = parse.(Int, split(input, ','))
    coa07_part1(positions),
    coa07_part2(positions)
end

@btime benchit(input)
