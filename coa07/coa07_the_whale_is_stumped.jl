# Code of Advent
#
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

function fuelcost(pos, initial_positions, dragfnc)
    sum(dragfnc∘abs, initial_positions .- pos)
end

function coa07(input, dragfnc= identity)
    init = parse.(Int, split(input, ','))
    find_a_trough(pos->fuelcost(pos, init, dragfnc), extrema(init)...)
end

crabdrag(n) = n*(n+1) ÷ 2

# The whale is like darnit

input = readline("input.txt")

@show coa07(input)
@show coa07(input, crabdrag)

using BenchmarkTools
@btime coa07(input), coa07(input, crabdrag)
