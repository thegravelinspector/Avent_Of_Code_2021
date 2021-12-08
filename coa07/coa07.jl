# Code of Advent

function fuelcost(pos, initial_positions, dragfnc)
    sum(dragfnc∘abs, initial_positions .- pos)
end

function coa07(input, dragfnc= identity)
    init = parse.(Int, split(input, ','))
    cost, _ = findmin(pos->fuelcost(pos, init, dragfnc), UnitRange(extrema(init)...))
    cost
end

crabdrag(n) = n*(n+1) ÷ 2

# The whale is like nom nom nom

input = readline("input.txt")

@show coa07(input)
@show coa07(input, crabdrag)

using BenchmarkTools
@btime coa07(input), coa07(input, crabdrag)
