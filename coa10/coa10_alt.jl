# Code of Advent

se_score(c) = [3,57,1197,25137][findfirst(==(c), ")]}>")]
ac_score(c) = findfirst(==(c), "([{<")
median_odd(v) = sort!(v)[(length(v)+1)÷2]

function remove_matched(line)
    new_line = replace(line, "()" => "", "[]" => "", "{}" => "", "<>" => "")
    line == new_line && return line
    remove_matched(new_line)
end

function coa10(input)
    ses, acs = 0, Int[]
    for left in remove_matched.(input)
        m = match(r"[\(\[{<]([\)\]}>])", left)
        isnothing(m) && (push!(acs, foldr((a,b)->ac_score(a)+5b, left, init=0)); continue)
        ses += se_score(m.captures[1][1])
    end
    (;syntax_error_score=ses, autocomplete_score=median_odd(acs))
end

input = readlines("input.txt")

@show coa10(input)
