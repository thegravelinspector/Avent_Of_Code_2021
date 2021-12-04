# Code of Advent

using DelimitedFiles, StaticArrays

# Part 1: Cheat the squid and lose the sub

get_numbers(fname) = parse.(Int, split(readline(fname), ','))
get_boards(fname) = readdlm(fname, Int, skipstart=2)

function get_tombola(fname)
    numbers = get_numbers(fname)
    boards = get_boards(fname)
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
            remove!(board, n)
            last_bingo_score = winnings(board) * n
        end
    end
    last_bingo_score
end

coa04_part2(fname) = last_bingo_score(get_tombola(fname)...)

# Cheat or not to cheat

@show coa04_part1("input.txt")
@show coa04_part2("input.txt")
