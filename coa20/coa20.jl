# Code of Advent, day 20

function get_imaging(fname)
    lines = readlines(fname)
    to_10s(l) = parse.(Int, split(replace(l, '.' => 0, '#' => 1), ""))
    img = Matrix{Int}(undef, length(lines)-2, length(lines)-2)
    for (i, l) in enumerate(lines[3:end]) img[i,:] .= to_10s(l) end
    (; img, algo=to_10s(lines[1]))
end

function padd(M, n=8)
    nM = zeros(Int, size(M) .+ (n,n))
    nM[n÷2+1:end-n÷2,n÷2+1:end-n÷2] .= M
    nM
end

CI = CartesianIndex
I = CartesianIndices((3,3)) .- CI(2,2)
I = [I[1,:]; I[2,:]; I[3,:]]

bits2ix(img, i, j) = evalpoly(2, reverse!([img[CI(i,j) + xi] for xi in I])) + 1

function fill_the_rim!(img)
    img[1,:] = img[2,:]
    img[end,:] = img[end-1,:]
    img[:,1] = img[:,2]
    img[:,end] = img[:,end-1]
end

function enhance(img, algo)
    new_img = zero(img)
    for i in 2:size(img, 1)-1, j in 2:size(img, 2)-1
        new_img[i,j] = algo[bits2ix(img, i, j)]
    end
    fill_the_rim!(new_img)
    new_img
end

function coa_part1(img, algo)
    img = padd(img)
    img = enhance(img, algo)
    img = enhance(img, algo)
    count(==(1), img)
end

function coa_part2(img, algo)
    img = padd(img)
    for i in 1:50
        img = enhance(img, algo)
        img = padd(img, 2)
        fill_the_rim!(img)
    end
    count(==(1), img)
end

imaging = get_imaging("input.txt")

@show coa_part1(imaging...)
@show coa_part2(imaging...)
