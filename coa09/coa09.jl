function get_data(input)
    A = hcat([parse.(Int, collect(line)) for line in input]...)
    r, c = size(A)
    M = fill(9, r+2, c+2)
    M[2:end-1, 2:end-1] = A
    (;M, ixs=CartesianIndices((2:r+1, 2:c+1)))
end

neighbourhood(ix) = [ix + neighbour for neighbour in CartesianIndex.(((-1,0), (1,0), (0,-1), (0,1)))]

function is_trough(M, ix)
    all(M[neighbourhood(ix)] .> M[ix])
end

function coa09_part1(data)
    sum, trougs = 0, CartesianIndex{2}[]
    for ix ∈ data.ixs
        if is_trough(data.M, ix)
            sum += data.M[ix]+1
            push!(trougs, ix)
        end
    end
    (;M=data.M, sum_of_risk_levels=sum, trougs)
end

function size_of_basin(M, ix, i)
    size = 0
    function recusivfill(ix)
        depth = M[ix]
        if depth ∈ 0:8
            M[ix] = -M[ix] - 1
            size += 1
            for ix ∈ neighbourhood(ix)
                recusivfill(ix)
            end
        end
    end
    recusivfill(ix)
    size
end

function coa09_part2(data)
    largest3 = partialsort!([size_of_basin(data.M, ix, -i) for (i, ix) ∈ enumerate(data.trougs)], 1:3, rev=true)
    (;M=data.M, product_of_basin_sizes=prod(largest3))
end

input = readlines("input.txt")

data = get_data(input)

data = coa09_part1(data)
@show data.sum_of_risk_levels

data = coa09_part2(data)
@show data.product_of_basin_sizes
