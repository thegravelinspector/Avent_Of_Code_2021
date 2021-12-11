# Code of Advent

function get_molluscs(input)
    A = hcat([parse.(Int, collect(line)) for line in input]...)
    r, c = size(A)
    M = fill(-1, r+2, c+2)
    M[2:end-1, 2:end-1] = A
    (;M, ixs=CartesianIndices((2:r+1, 2:c+1)), num_flashes=[0])
end

function trans(n)
    0 < n > 20 && return ' '   
    circlednumbers = "⓿⓵⓶⓷⓸⓹⓺⓻⓼⓽❿⓫⓬⓭⓮⓯⓰⓱⓲⓳⓴"
    return circlednumbers[nextind(circlednumbers,1,abs(n))]
end

ascii(A) = join.(eachrow(Char.(map(trans, Int.(A)))))
chatt(molluscs) = println(join(ascii(molluscs.M[2:end-1,2:end-1]'),"\n"),"\n")

neigh(ix) = ix - CartesianIndex(1,1):ix + CartesianIndex(1, 1)
reset_border!(m) = (m.M[[1,end],:] .= -1, m.M[:,[1,end]] .= -1)

function raise!(m)
    m.M .+= 1
    reset_border!(m)
end

function flash!(m)
    has_flashed = falses(size(m.M))
    while true
        new_flashes = (m.M .* .~has_flashed) .> 9
        ~any(new_flashes) && break
        map(ix->m.M[neigh(ix)] .+= 1, CartesianIndices(m.M)[new_flashes])
        reset_border!(m)
        has_flashed .|= new_flashes
    end
    m.num_flashes .+= count(has_flashed)
    m.M[has_flashed] .= 0
end

function simulate!(m)
    println("Before any steps:")
    chatt(m)
    for i in 1:100
        raise!(m)
        flash!(m)
        if i <= 10 || i%10==0
            println("After step $i:")
            chatt(m)
        end
    end
end

input = readlines("test.txt")

molluscs = get_molluscs(input)
simulate!(molluscs)
println("After 100 steps, there have been a total of $(molluscs.num_flashes[]) flashes.")
