# Code of Advent, day 18

using DataStructures

get_snailnumbers(fname) = readlines(fname)

function tree2routes(ts)
    l, D = 0, OrderedDict{Vector{Int}, Int}()
    r, i = Int[], 0
    while i < length(ts) - 1
        i += 1
        c = ts[i]
        c == '[' && (push!(r, 1); continue)
        c == ']' && (pop!(r); r[end] = 1; continue)
        c == ',' && (r[end] = 2; continue)
        range = findfirst(r"\d+", ts[i:end]) .+ i .- 1
        D[copy(r)] = parse(Int, (ts[range]))
        i += range.stop - range.start
    end
    D
end

function explode!(rn)
    sort!(rn)
    sk = collect(keys(rn))
    fks = filter(k->length(k[2])>4, collect(enumerate(sk)))
    length(fks) < 2 && return false
    for (i, k) in fks
        v, d = rn[k], k[end]
        delete!(rn, k); pop!(k); rn[k] = 0
        d == 1 && i > 1 && haskey(rn, sk[i-1]) && (rn[sk[i-1]] += v)
        d == 2 && i < length(sk) && haskey(rn, sk[i+1]) && (rn[sk[i+1]] += v)
    end
    true
end

function split!(rn)
    ks = collect(enumerate(keys(rn)))
    ix = findfirst(p->rn[p[2]] >= 10, ks)
    isnothing(ix) && return false
    i, k = ks[ix]
    n = rn[k]; delete!(rn, k)
    rn[[k;1]] = n÷2
    rn[[k;2]] = iseven(n) ? n÷2 : n÷2 + 1  
    true
end

function reduce!(rn)
    while true
        explode!(rn) && continue
        split!(rn) && continue
        break
    end
    rn
end

function addsn(rn1, rn2)
    D = OrderedDict{Vector{Int}, Int}()
    for (k, v) in collect(rn1) D[[1; k]] = v end
    for (k, v) in collect(rn2) D[[2; k]] = v end
    sort!(D)
end

function add_all(sns)
    sns = tree2routes.(reverse!(sns))
    while length(sns) > 1
        rn1 = sns[end]
        rn2 = sns[end-1]
        trn = addsn(rn1, rn2)
        pop!(sns)
        reduce!(trn)
        sns[end] = trn
    end
    sns[end]
end

function magnitude(rn)
    rn = deepcopy(rn)
    while true
        for k in keys(rn)
            k[end] != 1 && continue
            k2 = [k[1:end-1]; 2]
            ~haskey(rn, k2) && continue
            length(k) == 1 && return 3rn[[1]] + 2rn[[2]]
            rn[k[1:end-1]] = 3rn[k] + 2rn[k2]
            delete!(rn, k)
            delete!(rn, k2)
            break
        end
    end
end

function largest(sns)
    sns = tree2routes.(sns)
    lm = typemin(Int)
    for (i, sn1) in enumerate(sns)
        for sn2 in sns[i+1:end]
            tsn = reduce!(addsn(sn1, sn2))
            tsnm = magnitude(tsn)
            tsnm > lm && (lm = tsnm)
            tsn = reduce!(addsn(sn2, sn1))
            tsnm = magnitude(tsn)
            tsnm > lm && (lm = tsnm)
        end
    end
    lm
end

coa18_part1(sns) = magnitude(add_all(sns))
coa18_part2(sns) = largest(sns)

sns = get_snailnumbers("input.txt")

@show coa18_part1(sns)
@show coa18_part2(sns)
