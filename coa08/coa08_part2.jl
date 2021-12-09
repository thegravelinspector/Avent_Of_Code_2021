# Code of Advent

█, ░ = true, false

#             a b c d e f g
clearrepr = [█ █ █ ░ █ █ █;  # 0
             ░ ░ █ ░ ░ █ ░;  # 1
             █ ░ █ █ █ ░ █;  # 2
             █ ░ █ █ ░ █ █;  # 3
             ░ █ █ █ ░ █ ░;  # 4
             █ █ ░ █ ░ █ █;  # 5
             █ █ ░ █ █ █ █;  # 6
             █ ░ █ ░ ░ █ ░;  # 7
             █ █ █ █ █ █ █;  # 8
             █ █ █ █ ░ █ █;] # 9

function decode(line, clearrepr=clearrepr)
    ciperrepr = falses(14, 7)

    i = 1
    for repr in collect.(Int8, split(line))
        repr == [124] && continue
        ciperrepr[i, repr.-96] .= true
        i += 1
    end

    swaprows!(i, j, cb=ciperrepr) = cb[i,:], cb[j,:] = cb[j,:], cb[i,:] # >= julia v1.7
    i = 1
    while i <= 10
        bit_sum = sum(@view ciperrepr[i,:])
        i != 2 && bit_sum == 2 && (swaprows!(i, 2); continue)
        i != 5 && bit_sum == 4 && (swaprows!(i, 5); continue)
        i != 8 && bit_sum == 3 && (swaprows!(i, 8); continue)
        i != 9 && bit_sum == 7 && (swaprows!(i, 9); continue)
        i += 1
    end

    done = [2,5,8,9]

    hamming_dists(i, code, subset) = [count((@view code[i,:]) .⊻ (@view code[j,:])) for j ∈ subset]
    findcode(i) = findfirst(==(hamming_dists(i, clearrepr, done)), [hamming_dists(j, ciperrepr, done) for j in 1:10])

    for i in setdiff(1:10, done)
        swaprows!(findcode(i),  i)
    end

    sum(10^(4-i) * (findfirst(==(@view ciperrepr[10+i,:]), eachrow(ciperrepr))-1) for i in 1:4)
end

input = readlines("input.txt")

@show sum(decode.(input))
