# Code of Advent, day 22

function get_cuboids(fname)
    cuboids = Pair{Vector{UnitRange{Int64}}, Int64}[]
    for line in readlines(fname)
        v = line[1:2] == "on" ? 1 : -1
        c = [parse(Int, line[r]) for r in findall(r"(-?\d+)", line)]
        c = [c[ix]:c[ix+1] for ix in 1:2:length(c)] => v
        push!(cuboids, c)
    end
    cuboids
end

function n(r1::UnitRange, r2::UnitRange)
    if r1.start > r2.start
        r1, r2 = r2, r1
    end
    r2.start > r1.stop + 1 && return nothing
    r2.stop > r1.stop && return r2.start:r1.stop
    r2.start:r2.stop
end

function count_on(C)
    l(r) = r.stop-r.start+1
    on = 0
    for (rs, sign) in C
        on += sign * prod(l.(rs))
    end
    on
end

function add_cuboid!(C, sign, r)
    ~haskey(C, r) && (C[r] = sign; return)
    C[r] == -sign && (delete!(C, r); return)
    C[r] += sign
end

function add_cuboid!(C, sign, (r1x, r1y, r1z), (r2x, r2y, r2z))
    r = [n(r1x, r2x), n(r1y, r2y), n(r1z, r2z)]
    ~any(isnothing.(r)) && add_cuboid!(C, sign, r)
end

function inc_exc(cuboids)
    C = Dict{Vector{UnitRange}, Int}(cuboids[1])
    for (r, sign_r) in cuboids[2:end]
        nC = Dict{Vector{UnitRange}, Int}()
        for (c, sign_c) in collect(C)
            sign_r*sign_c == 1 && (add_cuboid!(nC, -sign_r, r, c); continue)
            add_cuboid!(nC, sign_r, r, c)
        end
        for (nc, sign_nc) in collect(nC) add_cuboid!(C, sign_nc, nc) end
        sign_r == 1 && add_cuboid!(C, sign_r, r)
    end
    C
end

outside(r::UnitRange) = r.stop < -50 || r.start > 59
is_inner_region(c) = ~any(outside.(c[1]))

cuboids = get_cuboids("input.txt")

coa_part1(cuboids) = count_on(inc_exc(filter(is_inner_region, cuboids)))
coa_part2(cuboids) = count_on(inc_exc(cuboids))

@show coa_part1(cuboids)
@show coa_part2(cuboids)
