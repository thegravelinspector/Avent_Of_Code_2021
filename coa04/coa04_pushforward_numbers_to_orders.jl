# Code of Advent

get_numbers(data) = parse.(Int, split(data[1], ',')), @view data[3:end]

function get_boards(data)
    len = 5(length(data)+1)÷6
    boards = Matrix{Int}(undef, len, 5)
    ix = 1
    for d in data
        isempty(d) && continue
        boards[ix,:] = parse.(Int, split(d))
        ix += 1
    end
    boards, ""
end

function get_tombola(data)
    numbers, data = get_numbers(data)
    boards, _     = get_boards(data)
    numbers, boards
end

function pushforward(numbers)
    orders = Vector{eltype(numbers)}(undef, length(numbers))
    orders[numbers .+ 1] = 1:length(numbers)
    orders
end

function get_order_function(numbers)
    orders = pushforward(numbers)
    n::Int -> orders[n + 1]
end

order(n::Int) = _order(n)
order(x::AbstractArray{Int, 1}) = maximum(Iterators.map(_order, x))
order(b::AbstractArray{Int, 2}) = min(minimum(order(col) for col in eachcol(b)), minimum(order(row) for row in eachrow(b)))

function extrema(numbers, boards)
    min, max = typemax(eltype(boards)), 0#
    min_bix, max_bix = 0, 0
    for bix in 1:5:size(boards,1)
        o = order(@view boards[bix:bix+4,:])
        o < min && (min = o; min_bix = bix)
        o > max && (max = o; max_bix = bix)
    end
    (min, min_bix), (max, max_bix)
end

winnings(nix, bix) = sum(n -> n ∈ (@view numbers[1:nix]) ? 0 : n, @view boards[bix:bix+4,:]) * numbers[nix]

play_bingo_to(strategy) = winnings(strategy...)

coa04_part1(winn) = play_bingo_to(winn)
coa04_part2(lose) = play_bingo_to(lose)

# Cheat or not to cheat

input = readlines("input.txt")

numbers, boards = get_tombola(input)
_order = get_order_function(numbers)
winn, lose = extrema(numbers, boards)

@show coa04_part1(winn)
@show coa04_part2(lose)

# Bench

using BenchmarkTools

function benchit(input)
    numbers, boards = get_tombola(input)
    _order = get_order_function(numbers)
    winn, lose = extrema(numbers, boards)

    coa04_part1(winn),
    coa04_part2(lose)
end

@btime benchit(input)
