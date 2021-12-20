# Code of Advent

function hex2bin(p)
    p = parse.(Int, split(p, ""), base=16)
    p = string.(p, base=2, pad=4)
    p = split.(p, "")
    p = vcat(p...)
    [Int(pp[1])-Int('0') for pp in p]
end

get_packets(fname) = hex2bin.(readlines(fname))

macro retrpn(nt) esc(quote push!(rpn, $nt); return rpn end) end
value(frag, base=2) = evalpoly(base, reverse(frag))

function parse_packet(p, sver=0, rpn=[])
    length(p) < 3 && @retrpn((;sver, info=1))
    ver = value(p[1:3])
    length(p) < 6 && @retrpn((;sver, info=2))
    typ = value(p[4:6])
    if typ == 4 && length(p) >= 11
        literal = Int[]
        local i
        for outer i ∈ 7:5:length(p)
            length(p) < i+4 && @retrpn((;sver, info=3))
            push!(literal, value(p[i+1:i+4]))
            p[i] == 0 && break
        end
        push!(rpn, (; ver, typ, literal=value(literal, 16), len=i+4))
        return parse_packet(p[i+5:end], sver+ver, rpn)
    end
    length(p) < 7 && @retrpn((;sver, info=4))
    I = p[7]
    if I == 0 && length(p) >= 22
        push!(rpn, (; ver, typ, I, slen=value(p[8:22]), len=22))
        return parse_packet(p[23:end], sver+ver, rpn)
    end
    if I == 1 && length(p) >= 18
        push!(rpn, (; ver, typ, I, snum=value(p[8:18]), len=18))
        return parse_packet(p[19:end], sver+ver, rpn)
    end
    @retrpn((;sver, info=5))
end

function execute!(rpn, ix, asm)
    op = rpn[ix]
    if hasfield(typeof(op), :snum)
        len = sum(getfield.(rpn[ix:ix+op.snum], :len))
        args = [popat!(rpn, ix+1).literal for _ in ix+1:ix+op.snum]
        rpn[ix] = (; ver=0, typ=4, literal=asm(args...), len)
    elseif hasfield(typeof(op), :slen)
        slen, len, i = op.slen, 0, ix
        for outer i in ix+1:length(rpn)
            len += rpn[i].len
            slen == len && break
        end
        args = [popat!(rpn, ix+1).literal for _ in ix+1:i]
        rpn[ix] = (; ver=0, typ=4, literal=asm(args...), len=len+op.len)
    end
end

function compute(rpn)
    sver = pop!(rpn).sver
    while true
        op_ix = findprev(op->op.typ!=4, rpn, length(rpn))
        isnothing(op_ix) && break
        op = rpn[op_ix]
        op.typ == 5 && execute!(rpn, op_ix, Int∘>)
        op.typ == 6 && execute!(rpn, op_ix, Int∘<)
        op.typ == 7 && execute!(rpn, op_ix, Int∘==)
        op.typ == 0 && execute!(rpn, op_ix, +)
        op.typ == 1 && execute!(rpn, op_ix, *)
        op.typ == 2 && execute!(rpn, op_ix, min)
        op.typ == 3 && execute!(rpn, op_ix, max)
    end
    rpn[1].literal
end

coa16_part1(parsed_packet) = parsed_packet[end].sver
coa16_part2(parsed_packet) = compute(rpn)

rpn = parse_packet(get_packets("input.txt")[1])

@show coa16_part1(rpn)
@show coa16_part2(rpn)
