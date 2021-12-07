# Code of Advent

function find_a_trough(fnc, lo::Int, hi::Int)
    @assert lo <= hi
    if lo==hi == 1
        return fnc(lo)
    end
    x = (lo+hi) ÷ 2
    while x != lo && x != hi
        if fnc(x) > fnc(x-1)
            hi = x + 1
        elseif fnc(x) > fnc(x+1)
            lo = x - 1
        else
            break
        end
        x = (lo+hi)÷2
    end
    if x == lo && fnc(lo+1) < fnc(lo)
        x = lo + 1
    end
    fnc(x)
end

function fuelcost(pos, initial_positions, dragfnc=identity)
    sum(dragfnc∘abs, initial_positions .- pos)
end

crabdrag(n) = n*(n+1) ÷ 2

function get_data(input)
    positions = parse.(Int, split(input, ','))
    lo, hi = extrema(positions)
    (;positions, lo, hi)
end

coa07_part1(data) = fuelcost((sort!(data.positions)[length(data.positions)÷2]), data.positions)
coa07_part2(data) = find_a_trough(pos->fuelcost(pos, data.positions, crabdrag), data.lo, data.hi)

# The whale is like darnit

input = readline("input.txt")

data = get_data(input)
@show coa07_part1(data)
@show coa07_part2(data)

using BenchmarkTools

function benchit(input)
    data = get_data(input)
    coa07_part1(data),
    coa07_part2(data)
end

@btime benchit(input)
