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

coa16_part1(parsed_packet) = parsed_packet[end].sver

rpn = parse_packet(get_packets("input.txt")[1])

@show coa16_part1(rpn)
