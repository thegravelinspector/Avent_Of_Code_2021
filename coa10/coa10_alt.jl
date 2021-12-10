# Code of Advent

se_score(c) = [3,57,1197,25137][findfirst(==(c), ")]}>")]
ac_score(c) = findfirst(==(c), "([{<")

function error_match(line)
    left = replace(line, "()" => "", "[]" => "", "{}" => "", "<>" => "")
    line == left && return left, match(r"[\(\[{<]([\)\]}>])", left)
    error_match(left)
end

function coa10(input)
    ses, acs = 0, Int[]
    for (left, error) in error_match.(input)
        isnothing(error) && (push!(acs, foldr((a,b)->ac_score(a)+5b, left, init=0)); continue)
        ses += se_score(error.captures[1][1])
    end
    (;syntax_error_score=ses, autocomplete_score=sort!(acs)[(length(acs)+1)÷2])
end

input = readlines("input.txt")

@show coa10(input)
