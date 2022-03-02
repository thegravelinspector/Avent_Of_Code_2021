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

function find_expr_type(expressions)
    size, sizes, types = 0, Int[], Int[]
    for e in expressions
        MacroTools.postwalk(e) do s
            if @capture(s, *(z , T_))
                size += 1
                push!(types, 1)
            elseif @capture(s, ÷(z , T_))
                size -= 1
                push!(types, -1)
            end
            s
        end
        push!(sizes, size)
    end
    sizes, types
end

function iterate(prog, N, size, typ, sols0)
    n = N - length(sols0[1])
    sols = NTuple{N, Int64}[]
    for s1 in sols0
        for s2 in Iterators.product(fill(1:9, n)...)
            d = tuplejoin(s1, s2)
            f = rp_alu(d, N)
            if typ == -1 && f < size
                push!(sols, d)
            elseif typ == 1 && f > size÷26
                push!(sols, d)
            end
        end
    end
    sols
end

function coa24(prog)
    expressions = get_expressions(prog)
    sizes, expr_types = find_expr_type(expressions)

    sols = [()]

    for (ix, typ) in enumerate(expr_types)
        sols = iterate(prog, ix, 26^sizes[ix], typ, sols)
    end

    parse.(Int, join.(sols[[1, length(sols)]]))
end

prog = readlines("input.txt")
expressions = get_expressions(prog)

instantiate_return_partial_alu(prog)

@show min_max = coa24(prog);
