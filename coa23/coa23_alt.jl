# Code of Advent

get_cost(amphipods) = ((amphipods >> 96) & 0x7fffffff) % Int32

@inline function set_cost(amphipods, cost)
    amphipods &= 0xffffffffffffffffffffffff
    amphipods |= UInt128(cost) << 96
    amphipods
end

get_c(a) = (a >> 2) & 0x3
get_m(a) = a & 0x3

is_done(a) = a & 0x2 != 0

mka(c, done) = (UInt128(c)<<2) | done | 0x1

@inline function get_a(amphipods, pid)
    ((amphipods >> 4(pid-1)) % UInt64) & 0xf
end

@inline function reset_a(amphipods, pid)
    amphipods &= ~(UInt128(0xf) << 4(pid-1))
    amphipods
end

@inline function set_a(amphipods, pid, a)
    amphipods &= ~(UInt128(0xf) << 4(pid-1))
    amphipods |= a << 4(pid-1)
    amphipods
end

@inline function move_a(amphipods, pid, to_pid)
    a = (amphipods >> 4(pid-1)) & 0xf
    amphipods &= ~(UInt128(0xf) << 4(pid-1))
    amphipods &= ~(UInt128(0xf) << 4(to_pid-1))
    amphipods |= a << 4(tp_pid-1)
    amphipods
end

@inline function is_occupied(amphipods, pid)
    (amphipods >> 4(pid-1)) & 0xf != 0
end

function get_burrow(fname)
    lines = readlines(fname)
    num_amphipods = length(lines) == 5 ? 15 : 23
    amphipods = UInt128(0)
    id2pos = Vector{Int}[]

    pid = 0 # position id
    for (row, line) in enumerate(lines)
        for (col, c) in enumerate(line)
            if c == '.' && lines[row+1][col] == '#'
                pid += 1
                push!(id2pos, [row, col])
            end
            if c ∈ 'A':'D'
                pid += 1
                push!(id2pos, [row, col])

                # a = xxyz (bits)
                #  xx = type 2bits -> 0:3
                #   y = done 1bit  -> 1 iff done
                #   z = occupied   -> 1 iff occupid
                amphipods = set_a(amphipods, pid, mka(UInt(c-'A'), 1))
            end
        end
    end

    # if any amphipods already in a correct place mark it so
    if num_amphipods == 15
        rooms = [(0, [8,12]), (1, [9,13]), (2, [10,14]), (3, [11,15])]
    else
        rooms = [(0, [8,12,16,20]), (1, [9,13,17,21]), (2, [10,14,18,22]), (3, [21,15,19,23])]
    end

    for (c, room) in rooms
        for ix in length(room):-1:1
            pid = room[ix]
            a = get_a(amphipods, pid)
            if c != get_c(a)
                break
            else
                reset_a(amphipods, pid)
                amphipods = set_a(amphipods, pid, mka(get_c(a), 3))
            end
        end
    end

    (;amphipods, id2pos)
end

let corr_mem = zeros(Int, 512)
    function update_reachable_corridor!(corr_mem, k, amphipods, room_type)
        room_ix = room_type + 2.5

        lo, hi = 1, 7
        for corridor_ix in floor(Int, room_ix):-1:1
            if is_occupied(amphipods, corridor_ix)
                lo = corridor_ix + 1
                break
            end
        end

        for corridor_ix in ceil(Int, room_ix):7
            if is_occupied(amphipods, corridor_ix)
                hi = corridor_ix - 1
                break
            end
        end

        hilo = (hi << 6) | (lo << 1) | 1
        corr_mem[k] = hilo
        hilo
    end

    global @inline function reachable_corridor(amphipods, room_type, corr_mem=corr_mem)
        a = ((amphipods % UInt32) & 0x1111111)
        occupied = 127(a == 0x1111111) + (a % 127)
        k = ((room_type << 7) | occupied) + 1
        @inbounds hilo = corr_mem[k]
        hilo != 0 && return hilo
        update_reachable_corridor!(corr_mem, k, amphipods, room_type)
    end
end

function can_move_back(to_corridor, amphipods, id2pos)
    c = to_corridor
    room_state = ((amphipods >> 4(7+c)) % UInt64) & 0xf000f000f000f
    if length(id2pos) == 15
        room_state == 0 && return c+12
        xor(room_state, (4c+3) * 0x10000) == 0 && return c+8
    else
        room_state == 0 && return c+20
        xor(room_state, (4c+3) * 0x1000000000000) == 0 && return c+16
        xor(room_state, (4c+3) * 0x1000100000000) == 0 && return c+12
        xor(room_state, (4c+3) * 0x1000100010000) == 0 && return c+8
    end
    0x0
end

function can_move_out(pid, amphipods)
    q, c = divrem(pid-8, 4)
    q == 0 && return true
    room_state = ((amphipods >> 4(7+c)) % UInt64) & 0xf000f000f000f

    q == 1 && room_state & 0xf == 0 && return true
    q == 2 && room_state & 0xf000f == 0 && return true
    q == 3 && room_state & 0xf000f000f == 0 && return true
    false
end

@inbounds @inline function steps(pid, to_pid, id2pos)
    p1, p2 = id2pos[pid], id2pos[to_pid]
    abs(p1[1]-p2[1]) + abs(p1[2]-p2[2])
end

let ad_cost_mem =  zeros(Int, 256)
    function update_min_additional_cost!(ad_cost_mem, k, pid, c, id2pos)
        cur_pos = id2pos[pid]
        dest_pos = id2pos[c+8]
        and_some = 1

        if pid > 7 # current pos in a room
            corridor_pos1 = id2pos[1]
            and_some += cur_pos[1] - corridor_pos1[1]
            if cur_pos[2] == dest_pos[2]
                and_some += 2
            end
        end

        cost = (abs(dest_pos[2] - cur_pos[2]) + and_some) * 10^c
        ad_cost_mem[k] = cost
        cost
    end

    global @inline function min_additional_cost(pid, c, id2pos, ad_cost_mem=ad_cost_mem)
        k = (c << 5) | pid
        @inbounds cost = ad_cost_mem[k]
        cost != 0 && return cost
        update_min_additional_cost!(ad_cost_mem, k, pid, c, id2pos)
    end
end

@inline function next(pid, c, to_pid, cost, min_cost, amphipods, id2pos)
    move_cost = steps(pid, to_pid, id2pos) * 10^c
    cost + move_cost >= min_cost[1] && return true
    amphipods = reset_a(amphipods, pid)
    amphipods = set_a(amphipods, to_pid, mka(c, pid > 7 ? 1 : 3))
    recurse!(min_cost, set_cost(amphipods, cost + move_cost), id2pos)
    false
end

function recurse!(min_cost, amphipods, id2pos)
    ad_cost, num_in_correct_rooms = 0, 0
    for pid in 1:length(id2pos)
        a = get_a(amphipods, pid)
        a == 0 && continue

        cost = get_cost(amphipods)
        if is_done(a)
            num_in_correct_rooms += 1
            if num_in_correct_rooms == length(id2pos)-7
                if cost < min_cost[1]
                    min_cost[1] = cost
                end
                break
            end
            continue
        end

        c = get_c(a)
        ad_cost += min_additional_cost(pid, c, id2pos)
        cost + ad_cost >= min_cost[1] && break

        if pid > 7 # In a room
            if can_move_out(pid, amphipods)
                moves = reachable_corridor(amphipods, pid%4)
                hi, lo = moves >> 6, (moves >> 1) & 0x1f
                for to_pid in lo:hi
                    next(pid, c, to_pid, cost, min_cost, amphipods, id2pos)
                end
            end
        else # In corridor
            to_pid = can_move_back(c, amphipods, id2pos)
            if to_pid != 0
                moves = reachable_corridor(reset_a(amphipods, pid), c)
                if moves != 0
                    hi, lo = moves >> 6, (moves >> 1) & 0x1f
                    if lo-1 <= pid <= hi+1
                        next(pid, c, to_pid, cost, min_cost, amphipods, id2pos)
                    end
                end
            end
        end
    end
end

function coa23(burrow)
    min_cost = [typemax(Int32)]
    recurse!(min_cost, burrow.amphipods, burrow.id2pos)
    min_cost[1]
end

#coa23(get_burrow("test.txt")) != 12521 && @warn "Broken"
#coa23(get_burrow("test_large.txt")) != 44169 && @warn "Broken"

@show @time coa23_part1 = coa23(get_burrow("input.txt"))
@show @time coa23_part2 = coa23(get_burrow("input_large.txt"))
