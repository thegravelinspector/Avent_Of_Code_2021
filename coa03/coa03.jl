# Code of Advent

# Part 1

using StaticArrays

function coa03_part1(diagnostics)
    rate = SVector(repeat([0], length(diagnostics[1]))...)
    len = 0
    for diag in diagnostics
        rate += collect(diag) .== '1'
        len += 1
    end
    mostcommon = rate .> len÷2
    foldl((a,b)->2a+b, mostcommon) *
    foldl((a,b)->2a+b, mostcommon .⊻ true)
end

# Part 2

function prune!(diagnostics, bitno, reference_level::Bool)
    rate, len = 0, 0
    for diag in diagnostics
        rate += diag[bitno] == '1'
        len += 1
    end
    mostcommon = (rate >= len-rate)⊻reference_level ? '0' : '1'
    filter!(data->data[bitno]==mostcommon, diagnostics)
end

function diagnose(data, reference_level::Bool)
    bitno, data = 1, copy(data)
    while length(data) > 1
        prune!(data, bitno, reference_level)
        bitno += 1
    end
    parse(Int, data[1], base=2)
end

function aoc03_part2(test_data)
    oxygen_generator_rating = diagnose(test_data, true)
    CO2_scrubber_rating = diagnose(test_data, false)
    oxygen_generator_rating * CO2_scrubber_rating
end

# Run diagnostics

input = readlines("input.txt")

@show coa03_part1(input)
@show aoc03_part2(input)
