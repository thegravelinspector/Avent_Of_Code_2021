# Code of Advent part 1

function get_polymer(input)
    template = input[1]
    rules = Tuple.((a->[a[1][1:2],a[2][1]]).(split.(input[3:end], " -> ")))
    (;template, rules)
end

pairs(template) = [template[i:i+1] for i in 1:length(template)-1]
polymerization!(rule; polymerizate, template) = polymerizate[2 .* findall(p->p==rule[1], pairs(template))] .= rule[2]

function step_equipment(template, rules)
    polymerizate = fill(' ', 2length(template)-1)
    polymerizate[1:2:end] .= collect(template)[1:end]
    polymerization!.(rules; polymerizate, template)
    replace(join(polymerizate), ' ' => "")
end

use_equipment(polymer, n_steps) = reduce((template,i)->step_equipment(template, polymer.rules), 1:n_steps, init=polymer.template)

freqs(p) = [count(==(e), p) for e in unique(p)]
span((min, max)) = max - min

# Actual polymerization

coa14_part1(polymer, n) = (span∘extrema∘freqs)(use_equipment(polymer, n))

input = readlines("test.txt")

polymer = get_polymer(input)

@show coa14_part1(polymer, 10)

using UnicodePlots

N = 20

printstyled(lineplot([length(use_equipment(polymer, n)) for n in 1:N], title="Polymer lengths", xlabel="# steps", ylabel="length"))
println()
