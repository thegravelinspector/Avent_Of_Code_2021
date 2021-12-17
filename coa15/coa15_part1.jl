# Code of Advent

vcl(f,x1) = x2->f.(x1,x2)
vcr(f,x2) = x1->f.(x1,x2)

function get_cavern(input)
    cavern = hcat((vcl(parse,Int)∘vcr(split, "")).(readlines(input))...)'
    pcavern = fill(Inf, size(cavern).+(2,2))
    pcavern[2:end-1,2:end-1] = cavern
    (;map=pcavern)
end

function lowest_risk(map)
    c = copy(map)
    c[2,1] = 0
    for j ∈ 2:size(c,2)-1, i ∈ 2:size(c,1)-1
        cost = [c[i-1,j], c[i,j-1]]
        c[i,j] += minimum(cost)
    end
    Int(c[end-1,end-1]-c[2,2]), c
end

function make_map(c)
    map = fill('.', size(c))
    map[end-1,end-1] = '#'
    i, j = size(map) .- (1,1)
    while (i, j) != (2,1)
        if c[i-1,j] < c[i,j-1]
            i, j = i-1, j
        else
            i, j = i, j-1
        end
        map[i,j] = '#'
    end
    [join.(map[i, 2:end-1]) for i ∈ 2:size(map,1)-1]
end

cavern = get_cavern("input.txt")

coa15_part1(cavern) = lowest_risk(cavern...)

risk, costs = coa15_part1(cavern)

println("Lowest total risk of any path: $risk")
println.(join.(make_map(costs)));
