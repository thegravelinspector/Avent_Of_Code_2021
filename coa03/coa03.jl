# Code of Advent

# Part 1

using StaticArrays

diagnostics = readlines("input.txt")

function coa03(diagnostics)
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

# Run diagnostics

@show coa03(diagnostics)
