# Code of Advent

function fuelcost(pos, initial_positions, dragfnc=identity)
    sum(dragfnc∘abs, initial_positions .- pos)
end

crabdrag(n) = n*(n+1) ÷ 2

mean_high(v) = floor(Int, sum(v)/length(v))
median_low(v) = ceil(Int, sort!(v)[length(v)÷2])

function get_data(input)
    positions = parse.(Int, split(input, ','))
    (;positions, lo=median_low(positions), hi=mean_high(positions))
end

coa07_part1(data) = fuelcost(data.lo, data.positions)
coa07_part2(data) = fuelcost(data.hi, data.positions, crabdrag)

# The whale is like darnit

input = readline("input.txt")

data = get_data(input)
@show data.lo, data.hi

@show coa07_part1(data)
@show coa07_part2(data)

using BenchmarkTools

function benchit(input)
    data = get_data(input)
    coa07_part1(data),
    coa07_part2(data)
end

@btime benchit(input)
