# Code of Advent

function simulate_one(days)
    num = zeros(Int, days+1)
    num[1] = 1 # The zeroth day
    for i in 1:days
        num[i+9:7:end] .+= num[i]
    end
    cumsum(num)
end

function make_gauge_function(days)
    _gauge = simulate_one(days+8)
    init_state -> _gauge[end-init_state]
end

input = readline("input.txt")

init_state = parse.(Int, split(input, ","))

coa06(num_days, init_state; gauge=make_gauge_function(num_days)) = sum(gauge.(init_state))

# Thanx for the fish

@show coa06(80, init_state)
@show coa06(256, init_state)

using BenchmarkTools

function benchit(input)
    init_state = parse.(Int, split(input, ","))
    coa06(80, init_state), coa06(256, init_state)
end

@btime benchit(input)
