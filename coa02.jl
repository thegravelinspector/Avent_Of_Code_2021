# Code of Adven

# Part 1

fname = "input02.txt"
input = readlines(fname)

mutable struct Submarine
    hpos::Int
    depth::Int
end

accumulate(data) = foldl(1:length(data), init=Submarine(0,0)) do acc, i
    commando = match(r"(forward|up|down) (\d)", data[i])
    isnothing(commando) && error("Input format error!")
    commando[1] == "forward" && (acc.hpos += parse(Int, commando[2]))
    commando[1] == "up"      && (acc.depth -= parse(Int, commando[2]))
    commando[1] == "down"    && (acc.depth += parse(Int, commando[2]))
    acc
end

multiply(acc) = acc.hpos * acc.depth

aoc02a(data) = multiply(accumulate(data))

# Part 2

mutable struct dasBoot
    aim::Int64
    hpos::Int64
    depth::Int64
end

function update!(acc, action, value)
    if action[1] == 'd'
        acc.aim += value
    elseif action[1] == 'u'
        acc.aim -= value
    else
        acc.hpos += value
        acc.depth += acc.aim * value
    end
    acc
end

accumulate2(data) = foldl(1:length(data), init=dasBoot(0,0,0)) do acc, i
    commando = match(r"(forward|up|down) (\d)", data[i])
    isnothing(commando) && error("Input format error!")
    update!(acc, commando[1], parse(Int, commando[2]))
end

multiply(acc) = acc.hpos * acc.depth

aoc02b(data) = multiply(accumulate2(data))

# Dive!

@show aoc02a(input)
@show aoc02b(input);
