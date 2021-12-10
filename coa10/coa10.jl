# Code of Advent

matching(c) = ")]}>"[findfirst(==(c), "([{<")]
error_score(c) = [3,57,1197,25137][findfirst(==(c), ")]}>")]

function coa10_part1(data; chatt=false)
    not_corrupted_lines = []
    syntax_error_score = 0
    for line in data.lines
        pars = Char[]
        for c in line
            if c in "([{<"
                push!(pars, c)
            else
                mc = matching(pars[end])
                if c == mc
                    pop!(pars)
                else
                    chatt && println(" - $line - Expected $mc, but found $c instead.")
                    syntax_error_score += error_score(c)
                    @goto skip_corrupted
                end
            end
        end
        push!(not_corrupted_lines, line)
        @label skip_corrupted
    end
    (;not_corrupted_lines, syntax_error_score)
end

function remove_matched(line)
    newline = replace(line, "()" => "", "[]" => "", "{}" => "", "<>" => "")
    line == newline && return line
    remove_matched(newline)
end

match_score(c) = findfirst(==(c), "([{<")
median_odd(v) = sort!(v)[(length(v)+1)÷2]

function coa10_part2(data)
    autocomplete_scores = Int[]
    for line in data.not_corrupted_lines
        to_match = remove_matched(line)
        push!(autocomplete_scores, foldr((a,b)->match_score(a)+5b, to_match, init=0))
    end
    autocomplete_score = median_odd(autocomplete_scores)
    (;autocomplete_score)
end

# Debug the navigation subsystem

data = (;lines=readlines("input.txt"))

data = coa10_part1(data)
@show data.syntax_error_score

data = coa10_part2(data)
@show data.autocomplete_score
