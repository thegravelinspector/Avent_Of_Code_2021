# Code of Advent

# Part 1

mutable struct Submarine
    hpos::Int64
    depth::Int64
end

dive_part1(data) = foldl(data, init=Submarine(0,0)) do submarine, order
    commando = match(r"^(forward|up|down)\s(\d)$", order)
    isnothing(commando) && error("Input format error!")
    direction, speed = commando[1], parse(Int, commando[2])
    direction == "forward" && (submarine.hpos += speed)
    direction == "up"      && (submarine.depth -= speed)
    direction == "down"    && (submarine.depth += speed)
    submarine
end

luckystar(submarine) = submarine.hpos * submarine.depth

aoc02a(data) = luckystar(dive_part1(data))

# Part 2

mutable struct dasBoot
    aim::Int64
    hpos::Int64
    depth::Int64
end

function update!(submarine, direction, speed)
    direction == 'd' && (submarine.aim += speed; return submarine)
    direction == 'u' && (submarine.aim -= speed; return submarine)
    submarine.hpos += speed
    submarine.depth += submarine.aim * speed
    submarine
end

dive_part2(data) = foldl(data, init=dasBoot(0,0,0)) do submarine, order
    commando = match(r"^(forward|up|down)\s(\d)$", order)
    isnothing(commando) && error("Input format error!")
    update!(submarine, first(commando[1]), parse(Int, commando[2]))
end

aoc02b(data) = luckystar(dive_part2(data))

# Dive!

fname = "input.txt"
input = readlines(fname)

@show aoc02a(input)
@show aoc02b(input);
