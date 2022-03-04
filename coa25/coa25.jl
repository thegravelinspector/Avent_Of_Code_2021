# Code of Advent day 25

function get_trench(fname)
    lines = readlines(fname)
    cucumbers = hcat([first.(split(line, "")) for line in lines]...)
    trench = fill('.', size(cucumbers) .+ (1,1))
    trench[1:size(cucumbers,1),1:size(cucumbers,2)] .= cucumbers
    Int8.(trench)
end

function move!(trench, dir)
    rows, cols = size(trench) .- (1,1)
    r, c = 1, 1
    not_done = false

    trench[end,:] .= @view trench[1,:]
    while true
        if trench[r, c] == dir
            next_r = r + 1
            if trench[next_r, c] == Int8('.')
                trench[r, c] = Int8('.')
                trench[mod1(next_r, rows), c] = dir
                r += 1
                not_done = true
            end
        end
        r += 1
        if r > rows
            r = 1
            c += 1
            if c > cols
                break
            end
        end
    end
    not_done
end

function step!(trench)
    not_done = move!(trench, Int8('>'))
    move!(transpose(trench), Int8('v')) || not_done
end

function coa25(trench)
    i = 1
    while step!(trench)
        i += 1
    end
    i
end

trench = get_trench("input.txt")

using BenchmarkTools

@show coa25(trench);
@btime coa25(trench)
