# Code of Advent day 25

function get_trench(fname)
    lines = readlines(fname)
    cucumbers = hcat([first.(split(line, "")) for line in lines]...)
    trench = fill('.', size(cucumbers) .+ (1,1))
    trench[1:size(cucumbers,1),1:size(cucumbers,2)] .= cucumbers
    trench
end

function step!(trench)
    not_done = false
    rows, cols = size(trench) .- (1,1)

    r, c = 1, 1
    trench[end,:] .= @view trench[1,:]
    while true
        if trench[r, c] == '>'
            next_r = r + 1
            if trench[next_r, c] == '.'
                trench[r, c] = '.'
                trench[mod1(next_r, rows), c] = '>'
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

    r, c = 1, 1
    trench[:,end] .= @view trench[:,1]
    while true
        if trench[r, c] == 'v'
            next_c = c + 1
            if trench[r, next_c] == '.'
                trench[r, c] = '.'
                trench[r, mod1(next_c, cols)] = 'v'
                c += 1
                not_done = true
            end
        end
        c += 1
        if c > cols
            c = 1
            r += 1
            if r > rows
                break
            end
        end
    end
    not_done
end

function coa25(trench)
    i = 1
    while step!(trench)
        i += 1
    end
    i
end

trench = get_trench("input.txt")
@show coa25(trench);
