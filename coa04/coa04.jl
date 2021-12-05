# Code of Advent

using StaticArrays

# Part 1: Cheat the squid and lose the sub

get_numbers(data) = parse.(Int, split(data[1], ',')), @view data[3:end]

function get_boards(data)
    len = 5(length(data)+1)÷6
    boards = Matrix{Int64}(undef, len, 5)
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

function is_bingo!(board, number)
    X = -1
    BINGO = SVector(X,X,X,X,X)
    ix = findfirst(==(number), board)
    isnothing(ix) && return false

    board[ix] = X
    board[ix[1],:] == BINGO && return true
    board[:,ix[2]] == BINGO
end

winnings(board) = sum(board[board .> 0])

function first_bingo_score(numbers, boards)
    for n in numbers, bix in 1:5:size(boards, 1)
        board = @view boards[bix:bix+4,:]
        is_bingo!(board, n) && return winnings(board) * n
    end
    error("The sub sank anyway!")
end

coa04_part1(fname) = first_bingo_score(get_tombola(fname)...)

# Part 2: Save the sub

function last_bingo_score(numbers, boards)
    remove!(board, n) = board[1,1] = -2
    isremoved_board(boards, bix) = boards[bix,1] <= -2

    last_bingo_score = 0
    for n in numbers, bix in 1:5:size(boards, 1)
        isremoved_board(boards, bix) && continue
        board = @view boards[bix:bix+4,:]
        if is_bingo!(board, n)
            last_bingo_score = winnings(board) * n
            remove!(board, n)
        end
    end
    last_bingo_score
end

coa04_part2(fname) = last_bingo_score(get_tombola(fname)...)

# Cheat or not to cheat

input = readlines("input.txt")

@show coa04_part1(input)
@show coa04_part2(input)

using BenchmarkTools

# Without slow disk IO
function benchit(input)
    coa04_part1(input), coa04_part2(input)
end

@btime benchit(input)
