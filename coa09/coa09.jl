using PaddedViews

function get_data(input)
    A = hcat([parse.(Int, collect(line)) for line in input]...)
    r, c = size(A)
    (;M=PaddedView(9, A, (1:r+2,1:c+2), (2:r+1,2:c+1)), ixs=CartesianIndices((2:r+1, 2:c+1)))
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

function floodfill!(M, ix)
    function _recursivefill!(ix)
        depth = M[ix]
        if depth ∈ 0:8
            M[ix] = -M[ix]-1
            for ix ∈ neighbourhood(ix)
                _recursivefill!(ix)
            end
        end
    end
    _recursivefill!(ix)
    M
end

function size_of_basin(M, ix)
    M = floodfill!(copy(M), ix)
    size = count(<(0), M)
    size
end

function coa09_part2(data)
    largest3 = partialsort!([size_of_basin(data.M, ix) for ix ∈ data.trougs], 1:3, rev=true)
    (;product_of_basin_sizes=prod(largest3))
end

input = readlines("input.txt")

data = get_data(input)

data = coa09_part1(data)
@show data.sum_of_risk_levels

data = coa09_part2(data)
@show data.product_of_basin_sizes
