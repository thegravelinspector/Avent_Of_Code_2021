# Code of Advent

using UnicodePlots

function get_target_area(line)
    rs = findall(r"-?\d+", line)
    v = parse.(Int, [line[r] for r in rs])
    (; x1=v[1], x2=v[2], y1=v[3], y2=v[4])
end

function plot_misson(x1, x2, y1, y2, x, y, h, ym)
    c = UnicodePlots.BrailleCanvas
    cols = [hit ? :red : :yellow for hit in h]
    P = lineplot([x1, x1, x2, x2, x1], [y1, y2, y2, y1, y1], xlim=(0,x2), ylim=(y1,ym), color=:blue; canvas=c)
    scatterplot!(P, x, y, color=cols)
end

function launch(x1, x2, y1, y2, vx0, vy0, x0=0, y0=0)
    x, y, vx, vy, h = Int[x0], Int[y0], Int[vx0], Int[vy0], [false]
    while x[end] <= x2 && y[end] >= y1
        push!(x, x[end] + vx[end])
        push!(y, y[end] + vy[end])
        push!(vx, vx[end] - sign(vx[end]))
        push!(vy, vy[end] - 1)
        hit = x1 <= x[end] <= x2 && y1 <= y[end] <= y2
        push!(h, hit)
    end
    ym, im = findmax(y)
    x, y, h, im, ym
end

input = readline("test.txt")

target_area = get_target_area(input)

function ballistics(x1, x2, y1, y2)
    max_y, v = typemin(Int64), Set([])
    local hx, hy, hh, vx, vy, hym
    for vx0 in 1:x2, vy0 in y1:-y1
        x, y, h, im, ym = launch(x1, x2, y1, y2, vx0, vy0)
        any(h) && push!(v, (vx0,vy0))
        if any(h) && ym > max_y
            max_y, vx, vy, hx, hy, hh, hym = ym, vx0, vy0, x, y, h, ym
        end
    end
    println("Max height = $max_y for v₀ = ($vx, $vy)")
    println("Number of hits = $(length(v))")
    plot_misson(x1, x2, y1, y2, hx, hy, hh, hym)
end

printstyled(ballistics(target_area...))
println()
