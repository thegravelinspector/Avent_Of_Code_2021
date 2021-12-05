struct Line
    x1::Int16; y1::Int16; x2::Int16; y2::Int16
end

ishor(l::Line) = l.y1==l.y2
isvert(l::Line) = l.x1==l.x2

function get_vent_lines(data)
    max_reach = 0
    lines = Vector{Line}()
    for datapoint in data
        x1, y1, x2, y2 = parse.(Int, SubString.(datapoint, findall(r"(\d+)", datapoint)))
        max_reach = max(max_reach, x1, x2, y1, y2)
        push!(lines, Line(x1,y1,x2,y2))
    end
    lines, max_reach
end

new_diagram(size) = zeros(Int8, size+1, size+1)

function mark!(diagram, l)
    i, j = l.y1+1, l.x1+1
    Δi, Δj = sign(l.y2-l.y1), sign(l.x2-l.x1)
    for _ in 0:max(abs(l.x2-l.x1), abs(l.y2-l.y1))
        diagram[i, j] += 1
        i += Δi
        j += Δj
    end
end

function coa05_part1!(diagram, vent_lines)
    for vl in vent_lines
        (ishor(vl)||isvert(vl)) && mark!(diagram, vl)
    end
    count(>(1), diagram)
end

function coa05_part2!(diagram, vent_lines)
    for vl in vent_lines
        !(ishor(vl)||isvert(vl)) && mark!(diagram, vl)
    end
    count(>(1), diagram)
end

input = readlines("input.txt")

# Danger level of vent zones

vent_lines, max_reach = get_vent_lines(input)
diagram = new_diagram(max_reach)

@show coa05_part1!(diagram, vent_lines)
@show coa05_part2!(diagram, vent_lines)

# Bench

using BenchmarkTools

function benchit(input)
    vent_lines, max_reach = get_vent_lines(input)
    diagram = new_diagram(max_reach)

    coa05_part1!(diagram, vent_lines),
    coa05_part2!(diagram, vent_lines)
end

@btime benchit(input)
