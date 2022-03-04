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
    done = true

    for c in 1:cols
        r = 1
        trench[end,c] = trench[1,c]
        while r <= rows
            if trench[r, c] == dir
                next_r = r + 1
                if trench[next_r, c] == Int8('.')
                    trench[r, c] = Int8('.')
                    trench[mod1(next_r, rows), c] = dir
                    r += 1
                    done = false
                end
            end
            r += 1
        end
    end
    done
end

function coa25(trench)
    for i in Iterators.countfrom(1)
        done = move!(trench, Int8('>'))
        move!(transpose(trench), Int8('v')) && done && return i
    end
end

trench = get_trench("input.txt")

using BenchmarkTools

@show coa25(trench);
@btime coa25(trench);
