# Code of Advent

using UnicodePlots, BenchmarkTools

vcl(f,x1) = x2->f.(x1,x2)
vcr(f,x2) = x1->f.(x1,x2)

function get_cavern(input)
    hcat((vcl(parse,Int)∘vcr(split, "")).(readlines(input))...)'
end

function large_map(c)
    s1, s2 = size(c)
    C = zeros(Int, 5 .* size(c))
    for i ∈ 0:4, j ∈ 0:4
        ii, jj = s1*i+1, s2*j+1
        C[ii:ii+s1-1, jj:jj+s2-1] = c .+ (i+j-1)
    end
    C .% 9 .+ 1
end

function walk!(a, A, S)
    sr, sc = size(A)
    SS(i,j) = 0<i<=sr && 0<j<=sc ? S[i,j] : typemax(Int64)÷20
    for c in sc:-1:1
        for r in 1:sr
            if r*c != 1
                S[r,c] = min(SS(r,c), SS(r,c-a)+ A[r,c], SS(r-a,c) + A[r,c])
            end
        end
    end
end

function get_min_costs(A)
    sr, sc = size(A)
    S = copy(A)
    SS(i,j) = 0<i<=sr && 0<j<=sc ? S[i,j] : typemax(Int64)÷20

    for c in 1:sc
        for r in 1:sr
            if r*c != 1
                S[r,c] = A[r,c] + min(SS(r,c-1), SS(r-1,c))
            end
        end
        for r in sr-1:-1:1
            S[r,c] = min(S[r,c], SS(r+1,c) + A[r,c])
        end
    end

    S_1 = zeros(Int, sr, sc)
    while S_1 != S
        S_1 = copy(S)
        walk!(-1, A, S)
        walk!(1, A, S)
    end
    S
end

function trace(S; start=nothing, stop=nothing, max_iter=nothing)
    max_cost = maximum(S)
    sr, sc = size(S)

    isnothing(start) && (start = [sr, sc])
    isnothing(stop) && (stop = [1, 1])
    isnothing(max_iter) && (max_iter = sr*sc)

    TT, TT_done = [[start]], []

    directions = [[-1,0], [1,0], [0,-1], [0,1]]
    SS(t) = 0<t[1]<=sr && 0<t[2]<=sc ? S[t[1],t[2]] : max_cost+1

    i = 1
    while i <= length(TT)
        T = TT[i]
        old_waypoint = copy(start)
        waypoint = start
        max_iter_count_down = 0

        while waypoint != stop
            next_possible_waypoints = [waypoint .+ dir for dir in directions]
            ball = SS.(setdiff!(next_possible_waypoints, T))
            isempty(ball) && @goto end_all
            cost, index = findmin(ball)
            a = findall(isequal(cost), ball)
            if length(a) > 1
                for i in a[2:end]
                    next_wp = next_possible_waypoints[i]
                    if next_wp ∉ T && ~isempty(next_wp)
                        new_T = copy(T)
                        push!(new_T, next_wp)
                        push!(TT, new_T)
                    end
                end
            end
            next_waypoint = next_possible_waypoints[index]
            if SS(next_waypoint) < max_cost && max_iter_count_down < max_iter && maximum(abs.((T[end] .- next_waypoint))) <= 1
                push!(T, next_waypoint)
                old_waypoint = copy(waypoint)
                waypoint = next_waypoint
                max_iter_count_down += 1
            else
                push!(TT_done, T)
                break
            end
        end
        i += 1
    end
    @label end_all
    TT
end

function show_trace(S, TT=trace(S))
    P = heatmap(S[end:-1:1,:], color=:grays)
    for T in TT
        line_width =  maximum(size(S)) < 20 ? 2 : 1
        P = plot!(P,last.(T), size(S,1) .- first.(T) .+ 1, lw=line_width, color=:red, leg=:none)
    end
    P
end

lowest_risk(costs) = costs[end,end] - costs[1,1]

function solution(map)
    S = get_min_costs(map)
    println("Lowest risk = ", S[end,end] - map[1,1])

    TT = trace(S)
    println("Sum of the trace = ", sum([map[t...] for t in TT[1]]) - map[1,1])

    show_trace(S, TT)
end

coa15_part1(cavern) = (;lowest_risk=lowest_risk(get_min_costs(cavern)))
coa15_part2(cavern) = (;lowest_risk=lowest_risk(get_min_costs(large_map(cavern))))

cavern = get_cavern("input.txt")

@show coa15_part1(cavern)
@show coa15_part2(cavern)

#plot(show_trace(get_min_costs(cavern)),
#     show_trace(get_min_costs(large_map(cavern))), size=(800,200))
