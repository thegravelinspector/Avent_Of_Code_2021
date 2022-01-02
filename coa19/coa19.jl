# Code of Advent, day 19

function get_scanner_data(fname)
    sd, i = Vector{Vector{Int}}[], 0
    for line in readlines(fname)
        if occursin("scanner", line)
            i += 1
            continue
        end
        if length(sd) < i
            push!(sd, Vector{Int}[])
            push!(sd[i], [0, 0, 0]) # Sensor position
        end
        m = match(r"(-?\d+),(-?\d+),(-?\d+)", line)
        isnothing(m) && continue
        push!(sd[i], parse.(Int, m.captures))
    end
    sd
end

function norm(d)
    sum(x->x^2, d)
end

function manhattan(s1, s2)
    sum(abs.(s2 .- s1))
end

function distrelc(sd, c)
    [d .- c for d in sd]
end

function similarity(nds1, nds2)
    guessix = zero(nds1)
    for (i, nd) in enumerate(nds1)
        ix = findall(==(0), nds2 .- nd)
        length(ix) > 1 && error("More then one match for distance")
        guessix[i] = length(ix) == 0 ? 0 : ix[1]
    end
    count(!=(0), guessix), guessix
end

function best_overlay(sd1, sd2)
    mins, mgix = 0, Int[]
    for c1 in sd1, c2 in sd2
        nrc1 = norm.(distrelc(sd1, c1))
        nrc2 = norm.(distrelc(sd2, c2))
        s, gix = similarity(nrc1, nrc2)
        if s > mins
            mins, mgix = s, gix
        end
    end
    mins, mgix
end

function x1_to_x2(x1, x2)
    M = zeros(Int, 3, 3)
    for (i, x) in enumerate(x2)
        ix = findfirst(==(abs(x)), abs.(x1))
        isnothing(ix) && return nothing
        M[i, ix] = sign(x*x1[ix])
    end
    M
end

function align!(sds)
    sensors = Vector{Vector{Int}}(undef, length(sds))
    sensors[1] = sds[1][1]
    verse = sds[1][2:end]
    not_done = collect(2:length(sds))
    for j in not_done
        verse = unique!(verse)
        mins, mg = best_overlay(verse, sds[j])
        mins < 2 && (push!(not_done, j); continue)
        ixi = findfirst(!=(0), mg)
        isnothing(ixi) && (push!(not_done, j); continue)
        ixj = mg[ixi]
        sds[j] .= [ds .- sds[j][ixj] for ds in sds[j]]
        _, ixj2 = findmax(p->norm(p[2]-sds[j][ixj])*(p[1] ∈ mg ? 1 : 0), collect(enumerate(sds[j])))
        x1 = sds[j][ixj2]
        x2 = verse[findfirst(==(ixj2), mg)]  .- verse[ixi]
        M = x1_to_x2(x1, x2)
        isnothing(M) && (push!(not_done, j); continue)
        sds[j] .= [M*ds for ds in sds[j]]
        sds[j] .= [ds .+ verse[ixi] for ds in sds[j]]
        append!(verse, sds[j][2:end])
        sensors[j] = sds[j][1]
    end
    unique!(verse), sensors
end

function largest_manhattan(sensors)
    lm = 0
    for (i, s1) in enumerate(sensors), s2 in sensors[i+1:end]
        m = manhattan(s1, s2)
        m > lm && (lm = m)
    end
    lm
end

sds = get_scanner_data("input.txt")

verse, sensors = align!(sds)

coa19_part1(verse) = length(verse)
coa19_part2(sensors) = largest_manhattan(sensors)

@show coa19_part1(verse)
@show coa19_part2(sensors)
