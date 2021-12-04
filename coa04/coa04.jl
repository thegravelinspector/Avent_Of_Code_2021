# Code of Advent

using DelimitedFiles, StaticArrays

# Part 1: Cheat the squid

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

function choose_board(numbers, boards)
    for n in numbers
        for bix in 1:5:size(boards, 1)
            board = @view boards[bix:bix+4,:]
            is_bingo!(board, n) && return board, n
        end
    end
    error("The sub sank!")
end

winnings(board) = sum(board[board .> 0])

function profit(tombola)
    winning_board, number = choose_board(tombola...)
    winnings(winning_board) * number
end

coa04_part1(fname) = profit(get_tombola(fname))

# Part 2: Save the sub

function choose_board_in_favor_of_squid(numbers, boards)
    remove!(board) = board[1,1] = -board[1,1] - 3
    isremoved_board(boards, bix) = boards[bix,1] <= -2
    restore!(board) = board[1,1] = -(board[1,1] + 3)

    last_bingo_board_ix = 0
    last_winning_number = 0
    for n in numbers
        for bix in 1:5:size(boards, 1)
            isremoved_board(boards, bix) && continue
            board = @view boards[bix:bix+4,:]
            if is_bingo!(board, n)
                remove!(board)
                last_bingo_board_ix = bix
                last_winning_number = n
            end
        end
    end
    board = @view boards[last_bingo_board_ix:last_bingo_board_ix+4,:]
    restore!(board)
    board, last_winning_number
end

function save_the_sub(tombola)
    losing_board, number = choose_board_in_favor_of_squid(tombola...)
    winnings(losing_board) * number
end

coa04_part2(fname) = save_the_sub(get_tombola(fname))

# Cheat or not to cheat

@show coa04_part1("input.txt")
@show coa04_part2("input.txt")
