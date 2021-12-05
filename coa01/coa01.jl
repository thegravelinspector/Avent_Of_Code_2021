# Code of Advent 1

fname = "input01.txt"
input = parse.(Int, readlines(fname))

coa01_part1(data) = foldl(1:length(data)-1) do acc,i
     @inbounds acc += data[i] < data[i+1]
end

coa01_part2(data) = foldl(1:length(data)-3) do acc,i
    @inbounds acc += data[i] < data[i+3]
end

@show coa01_part1(input)
@show coa01_part2(input)

using BenchmarkTools

# Without slow disk IO
function benchit(input)
    coa01_part1(input), coa01_part2(input)
end

@btime benchit(input)
