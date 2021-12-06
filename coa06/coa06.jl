# Code of Advent

function simulate_one(days)
    num = zeros(Int, days+1)
    num[1] = 1 # The zeroth day
    for i in 1:days
        num[i+9:7:end] .+= num[i]
    end
    cumsum(num)
end

function make_gauge_function(max_days)
    _gauge = simulate_one(max_days+8)
    (day, init_state) -> sum(_gauge[day+9 .- init_state])
end

input = readline("input.txt")

coa06(day, init_state; gauge=make_gauge_function(day)) = gauge(day, init_state)

# Thanx for the fish

init_state = parse.(Int, split(input, ','))
g = make_gauge_function(256)

@show coa06(80, init_state; gauge=g)
@show coa06(256, init_state; gauge=g)

using BenchmarkTools

function benchit(input)
    init_state = parse.(Int, split(input, ","))
    g = make_gauge_function(256)

    coa06(80, init_state; gauge=g),
    coa06(256, init_state; gauge=g)
end

@btime benchit(input)
