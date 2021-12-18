# Code of Advent

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

lowest_risk(costs) = costs[end,end] - costs[1,1]

coa15_part1(cavern) = (;lowest_risk=lowest_risk(get_min_costs(cavern)))
coa15_part2(cavern) = (;lowest_risk=lowest_risk(get_min_costs(large_map(cavern))))

cavern = get_cavern("input.txt")

@show coa15_part1(cavern)
@show coa15_part2(cavern)
