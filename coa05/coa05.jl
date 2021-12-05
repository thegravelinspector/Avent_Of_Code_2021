# Code of Ad(verse) Vent(s)

function get_vent_lines(data)
    max_reach = 0
    lines = Matrix{Int}(undef, length(data), 4)
    for (i,datapoint) in enumerate(data)
        lines[i,:] = parse.(Int, match(r"(\d+),(\d+) -> (\d+),(\d+)", datapoint))
        max_reach = max(max_reach, maximum(@view lines[i,:]))
    end
    lines, max_reach
end

new_diagram(size) = zeros(Int8, size, size)

function mark!(diagram, x1, y1, x2, y2)
    i, j = y1+1, x1+1
    Δi, Δj = sign(y2-y1), sign(x2-x1)
    for _ in 0:max(abs(x2-x1), abs(y2-y1))
        diagram[i, j] += 1
        i += Δi
        j += Δj
    end
end

function coa05_part1!(diagram, vent_lines)
    for (x1, y1, x2, y2) in eachrow(vent_lines)
        (y1 == y2 || x1 == x2) && mark!(diagram, x1, y1, x2, y2)
    end
    count(>(1), diagram)
end

function coa05_part2!(diagram, vent_lines)
    for (x1, y1, x2, y2) in eachrow(vent_lines)
        !(y1 == y2 || x1 == x2) && mark!(diagram, x1, y1, x2, y2)
    end
    count(>(1), diagram)
end

input = readlines("input.txt")

# Navigate

vent_lines, max_reach = get_vent_lines(input)
diagram = new_diagram(max_reach+1)

@show coa05_part1!(diagram, vent_lines)
@show coa05_part2!(diagram, vent_lines)

# Bench

using BenchmarkTools

function benchit(input)
    vent_lines, max_reach = get_vent_lines(input)
    diagram = new_diagram(max_reach+1)

    coa05_part1!(diagram, vent_lines),
    coa05_part2!(diagram, vent_lines)
end

@btime benchit(input)
