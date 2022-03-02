# Code of Advent, day 23

function get_burrow(fname)
    lines = readlines(fname)
    all_rooms = Int[]
    amphipods = Tuple{Char, Int, Int}[]
    types = Char[]
    id2pos = Vector{Int}[]

    pid = 0 # position id
    for (row, line) in enumerate(lines)
        for (col, c) in enumerate(line)
            if c == '.' && lines[row+1][col] == '#'
                pid += 1
                push!(id2pos, [row, col])
            end
            if c ∈ 'A':'Q'
                pid += 1
                push!(types, c)
                push!(all_rooms, pid)
                push!(id2pos, [row, col])

                # a = (type, mnum, pid)
                #  type ∈ 'A':'D
                #  mnum ∈ 0:2,
                #   0 -> move out amphipod
                #   1 -> move down amphipod
                #   2 -> amphipod in its correct place
                push!(amphipods, (c, 0, pid))
            end
        end
    end

    # bitfield pos = 2^(ids-1), == 1 if occupied position
    occupied = (2^length(all_rooms)-1) << 7

    num_types = length(unique(types))

    # position id -> room type
    criteria = Vector{Char}(undef, length(all_rooms))
    for (i, pid) in enumerate(all_rooms)
        criteria[pid-7] = '@'+mod1(i, num_types)
    end

    rooms = [Int[] for _ in 1:4]
    for pid in 1:length(criteria)
        c = criteria[pid]
        room = rooms[c-'@']
        push!(room, pid+7)
        sort!(room)
    end

    # if any amphipods already in a correct place mark it so
    for room in rooms
        for ix in length(room):-1:1
            pid = room[ix]
            aix = findfirst(a->last(a)==pid, amphipods)
            a = amphipods[aix]
            if criteria[pid-7] != first(a)
                break
            else
                # already in its correct place
                amphipods[aix] = (a[1], 2, a[3])
            end
        end
    end

    (; rooms, amphipods, id2pos, criteria, occupied)
end

function update_reachable_corridor!(corr_mem, k, occupied, room_type)
    room_ix = room_type - '@' + 1.5

    # <corridor index> == >position id>, 1:7

    lo, hi = 1, 7
    for corridor_ix in floor(Int, room_ix):-1:1
        if occupied & 1 << (corridor_ix-1) != 0
            lo = corridor_ix + 1
            break
        end
    end

    for corridor_ix in ceil(Int, room_ix):7
        if occupied & 1 << (corridor_ix-1) != 0
            hi = corridor_ix - 1
            break
        end
    end

    # Shorter moves first!,add 2 position ids at end - boundary of reachable positions
    moves = sort(lo:hi, lt=(a,b)->abs(a-room_ix) < abs(b-room_ix))
    push!(moves, lo-1, hi+1)
    corr_mem[k] = moves
    moves
end

@inline function reachable_corridor(occupied, room_type, corr_mem #= =fill([0], 512)=#)
    k = ((room_type - 'A') << 7) | (occupied & 0x7f) + 1
    @inbounds moves = corr_mem[k]
    length(moves) != 1 && return moves
    update_reachable_corridor!(corr_mem, k, occupied, room_type)
end

function move_back(pid, c, rooms, occupied, amphipods, corr_mem)
    moves = reachable_corridor(occupied & ~(1<<(pid-1)), c, corr_mem)
    length(moves) <= 2 && return 0

    if moves[end-1] <= pid <= moves[end]
        ix, room = 0, rooms[c-'@']
        for (i, to_pid) in enumerate(room)
            if occupied & 1 << (to_pid-1) == 0
                ix += 1
            else
                ix == 0 && return 0
                for to_pid in (@view room[i:end])
                    occupied & 1 << (to_pid-1) == 0 && return 0
                    aix = findfirst(a->last(a)==to_pid && first(a)==c, amphipods)
                    isnothing(aix) && return 0
                end
                break
            end
        end
        return ix
    end
    0
end

function move_out(pid, rooms, criteria, occupied, corr_mem)
    c = criteria[pid-7]
    moves = reachable_corridor(occupied, c, corr_mem)

    for rpid in rooms[c-'@']
        rpid == pid && break
        occupied & (1 << (rpid-1)) == 0 && continue
        rpid < pid && return @view moves[1:0]
    end

    @view moves[1:end-2]
end

@inbounds @inline function steps(pid, to_pid, id2pos)
    p1, p2 = id2pos[pid], id2pos[to_pid]
    abs(p1[1]-p2[1]) + abs(p1[2]-p2[2])
end

function update_min_additional_cost!(ad_cost_mem, k, pid, c, rooms, id2pos)
    cur_pos = id2pos[pid]
    dest_pos = id2pos[rooms[c-'@'][1]]
    and_some = 1

    if pid > 7 # current pos in a room
        corridor_pos1 = id2pos[1]
        and_some += cur_pos[1] - corridor_pos1[1]
        if cur_pos[2] == dest_pos[2]
            and_some += 2
        end
    end

    cost = (abs(dest_pos[2] - cur_pos[2]) + and_some) * 10^(c - 'A')
    ad_cost_mem[k] = cost
    cost
end

@inline function min_additional_cost(pid, c, rooms, id2pos, ad_cost_mem #= = zeros(Int, 256) =# )
    k = ((c - 'A') << 5) | pid
    @inbounds cost = ad_cost_mem[k]
    cost != 0 && return cost
    update_min_additional_cost!(ad_cost_mem, k, pid, c, rooms, id2pos)
end

function recurse!(min_cost, amphipods, rooms, criteria, id2pos, occupied, cost, ad_cost_mem, corr_mem, chatt)
    ad_cost, num_in_correct_rooms = 0, 0
    for (i, (c, mnum, pid)) in enumerate(amphipods)

        if mnum >= 2
            num_in_correct_rooms += 1
            if num_in_correct_rooms == length(criteria)
                if cost < min_cost[1]
                    min_cost[1] = cost
                    chatt && println("Sol: $cost")
                    chatt && flush(stdout)
                end
                break
            end
            continue
        end

        ad_cost += min_additional_cost(pid, c, rooms, id2pos, ad_cost_mem)
        cost + ad_cost >= min_cost[1] && break

        if mnum == 0
            moves = move_out(pid, rooms, criteria, occupied, corr_mem)
        else
            ix = move_back(pid, c, rooms, occupied, amphipods, corr_mem)
            moves = @view rooms[c-'@'][max(1,ix):ix]
        end
        for to_pid in moves # Short moves first.. so we can break out of loop all together, (don't actually matter much for speed..)
            move_cost = steps(pid, to_pid, id2pos) * 10^(c - 'A')
            cost + move_cost >= min_cost[1] && break
            amphipods[i] = (c, mnum+1, to_pid)
            recurse!(min_cost, amphipods, rooms, criteria, id2pos, (occupied | 1<<(to_pid-1)) & ~(1<<(pid-1)), cost+move_cost, ad_cost_mem, corr_mem, chatt)
            amphipods[i] = (c, mnum, pid)
        end
    end
end

function coa23(burrow; chatt=false)
    min_cost = [typemax(Int)]
    ad_cost_mem =  zeros(Int, 256)
    corr_mem = fill([0], 512)

    recurse!(min_cost, burrow.amphipods, burrow.rooms, burrow.criteria, burrow.id2pos, burrow.occupied, 0, ad_cost_mem, corr_mem, chatt)
    min_cost[1]
end

@show @time cost_part1 = coa23(get_burrow("input.txt"))
@show @time cost_part2 = coa23(get_burrow("input_large.txt"))
