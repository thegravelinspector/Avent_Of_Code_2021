# Code of Advent day 24

function symbolic_alu(prog, input ; memory=["0", "0", "0", "0"])
    data_pointer=1
    mem(a) = memory[a[1] - 'v']
    val(a) = a[1] ∈ 'w':'z' ? mem(a) : a
    sto(a, b) = memory[a[1] - 'v'] = b
    inp(a, b) = (sto(a, b); data_pointer += 1)

    @inline function add(a, b)
        mem(a) == "0" && (sto(a, val(b)); return)
        b      != "0" && (sto(a, "("*mem(a)*"+"*val(b)*")"); return)
    end

    @inline function mul(a, b)
        mem(a) == "0" && return
        b      == "0" && (sto(a, "0"); return)
        mem(a) == "1" && (sto(a, val(b)); return)
        b      != "1" && sto(a, "("*mem(a)*"*"*val(b)*")")
    end

    @inline function div(a, b)
        mem(a) == "0" && return
        b      != "1" && sto(a, "("*mem(a)*"÷"*val(b)*")")
    end

    @inline function mod(a, b)
        mem(a) == "0" && return
        mem(a) == "1" && return
        sto(a, "("*mem(a)*"%"*val(b)*")")
    end

    @inline function eql(a, b)
        mem(a) == val(b) && (sto(a, "1"); return)
        sto(a, "("*mem(a)*"=="*val(b)*")")
    end

    for line in prog
        op, a,  b = split(line*" ", ' ')
        op == "inp" && inp(a, input[data_pointer])
        op == "add" && add(a, b)
        op == "mul" && mul(a, b)
        op == "div" && div(a, b)
        op == "mod" && mod(a, b)
        op == "eql" && eql(a, b)
    end

   memory
end

function get_expressions(prog)
    inps = findall(s -> occursin("inp", s), prog)
    push!(inps, length(prog)+1)

    exps = Expr[]

    for (i, pos) in enumerate(inps[1:end-1])
        exp = Meta.parse.(symbolic_alu(prog[pos:inps[i+1]-1], ["i["*string(i)*"]" for n in 1:14]; memory=["w", "x", "y", "z"]))
        push!(exps, exp[end])
    end

    exps
end

function instantiate_return_partial_alu(prog)
    exp = "(w = 0; x = 0; y = 0; z = 0; n = 1;"
    for e in get_expressions(prog)
        exp *= "z = " * string(e) * ";"
        exp *= "n == N && return z; n += 1;"
    end
    exp *= "z;)"

    exp = Meta.parse(exp)

    @eval global rp_alu(i, N) = $exp
end

@inline tuplejoin(x, y) = (x..., y...)

using MacroTools

function find_sizes(expressions)
    size, sizes = 0, Int[]
    for e in expressions
        MacroTools.postwalk(e) do s
            @capture(s, *(z , T_)) && (size += 1)
            @capture(s, ÷(z , T_)) && (size -= 1)
            s
        end
        push!(sizes, size)
    end
    sizes
end

function iterate(N, size, sols0)
    n = N - length(sols0[1])
    sols = NTuple{N, Int64}[]
    for s1 in sols0, s2 in 1:9
        d = tuplejoin(s1, s2)
        f = rp_alu(d, N)
        f < size && push!(sols, d)
    end
    sols
end

function coa24(prog)
    expressions = get_expressions(prog)
    sizes = find_sizes(expressions)

    sols = [()]

    for (ix, size) in enumerate(sizes)
        sols = iterate(ix, 26^size, sols)
    end

    parse.(Int, join.(sols))
end

prog = readlines("input.txt")

instantiate_return_partial_alu(prog)

all_sols = coa24(prog)

@show extrema(all_sols);
