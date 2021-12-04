using DelimitedFiles, StaticArrays

mutable struct Tombola
    boards::Matrix{Int64}
    numbers::Vector{Int64}
end

get_numbers(fname) = parse.(Int, split(readline(fname), ','))
get_boards(fname) = readdlm(fname, Int, skipstart=2)

function Tombola(fname)
    numbers = get_numbers(fname)
    boards = get_boards(fname)
    Tombola(boards, numbers)
end

get_board(tombola, bix) = @view tombola.boards[bix:bix+4,:]
get_winnings(board) = -board[1,1]
isbingo(board) = board[1,1] < -1

function next_bingo!(tombola, bix, nix)
    X = -1
    BINGO = SVector(X, X, X, X, X)
    while true
        board = get_board(tombola, bix)
        if !isbingo(board)
            ix = findfirst(==(tombola.numbers[nix]), board)
            if !isnothing(ix)
                board[ix] = X
                if board[ix[1],:] == BINGO || board[:,ix[2]] == BINGO
                    board[1,1] = - tombola.numbers[nix] * sum(board[board .> 0])
                    return bix, nix
                end
            end
        end
        bix += 5
        if bix > size(tombola.boards,1)
            bix = 1
            nix += 1
        end
    end
end

function Base.iterate(it::Tombola, (bix, nix)=(1, 1))
    all(<(-1), it.boards[1:5:end,1]) && return nothing
    bix, nix = next_bingo!(it, bix, nix)
    nix > length(it.numbers) && return nothing
    return  (get_board(it, bix), (bix, nix))
end

function play_bingo(tombola; save_the_sub=false)
    local bingo_board
    for outer bingo_board in tombola
        save_the_sub || break
    end
    get_winnings(bingo_board)
end

# To cheat the giant squid or not..

@show play_bingo(Tombola("input.txt"); save_the_sub=false)
@show play_bingo(Tombola("input.txt"); save_the_sub=true);
