# Code of advent

input = readlines("input.txt")

coa08_part1(input) = sum(count(∈([2,4,3,7]), length.(split(split(line, '|')[2]))) for line in input)

@show coa08_part1(input)
