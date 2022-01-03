# Code of Advent, day 21 part 2

function get_random_start(fname)
    lines = readlines(fname)
    p1 = parse(Int, lines[1][end-1:end])
    p2 = parse(Int, lines[2][end-1:end])
    (; pos = [p1, p2])
end

function get_dirac_dice_branchings(diceset=[1:3, 1:3, 1:3])
    Ω = collect(Iterators.product(diceset...))
    ssd = collect(Iterators.flatten(sum.(Ω)))
    [(d,count(==(d), ssd)) for d in unique(ssd)]
end

function game_step(player, multiverse, branchings, wonn)
    next_step = Dict{Vector{Int64}, Int64}()
    for m_game in multiverse
        gamestate, multiplicity = first(m_game), last(m_game)
        for (dicesum, multitude) in branchings
            ng = copy(gamestate)
            ng[player] = mod1(ng[player] + dicesum, 10)
            ng[player+2] += ng[player]
            if ng[player+2] >= 21
                wonn[player] += multiplicity .* multitude
            else
                next_step[ng] = get(next_step, ng, 0) .+ multiplicity .* multitude
            end
        end
    end
    next_step
end

function multiverse_game(startpositions, branchings)
    pos_p1, pos_p2 = startpositions
    score_p1, score_p2 = 0, 0
    number_universes = 1

    multiverse = Dict([pos_p1, pos_p2, score_p1, score_p2] => number_universes)
    wonn = [0, 0]

    while ~isempty(multiverse)
        next_step = game_step(1, multiverse, branchings, wonn)
        multiverse = game_step(2, next_step, branchings, wonn)
    end
    wonn
end

coa_part2(start) = maximum(multiverse_game(start.pos, get_dirac_dice_branchings()))

start = get_random_start("input.txt")

@show coa_part2(start)

using BenchmarkTools

# @btime coa_part2(start)
