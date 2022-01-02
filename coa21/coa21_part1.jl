# Code of Advent, day 21 part 1

function get_random_start(fname)
    lines = readlines(fname)
    p1 = parse(Int, lines[1][end-1:end])
    p2 = parse(Int, lines[2][end-1:end])
    (; pos = [p1, p2])
end

function get_deterministic_dice()
    face = 0
    return ()->(face += 1; face = mod1(face, 100); return face)
end

function game(startpositions, dice)
    positions, scores, turn = startpositions, [0, 0], 0
    while all(scores .< 1000)
        turn += 3
        player = mod1(turn, 2)
        d = [dice(), dice(), dice()]
        positions[player] = mod1(positions[player] + sum(d), 10)
        scores[player] += positions[player]
    end
    scores, positions, turn
end

function coa_part1(start)
    scores, positions, turn = game(start.pos, get_deterministic_dice())
    minimum(scores) * turn
end

start = get_random_start("input.txt")

@show coa_part1(start)
