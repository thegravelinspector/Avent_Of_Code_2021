# Code of Advent part 2

function get_polymer(input)
    template = input[1]
    rules = Tuple.((a->[a[1][1:2],a[2][1]]).(split.(input[3:end], " -> ")))
    elements = sort!(unique(hcat(collect.(first.(rules))...)))
    all_pairs = [join([e1,e2]) for e1 in elements for e2 in elements]
    (;template, rules, elements, all_pairs)
end

# All arguments passed make utiliy functions ..
pairs_in(template) = [template[i:i+1] for i in 1:length(template)-1]
elm2id(e; elements, all_pairs) = findfirst(==(e), elements) .+ length(all_pairs)
pair2id(pair; all_pairs) = findfirst(==(pair), all_pairs)
pair2elm(pair) = collect(pair)

function add_rule!(r ;R, elements, all_pairs)
    rid = pair2id(String(r[1]); all_pairs=all_pairs)
    adds = [pair2id.([join([r[1][1],r[2]]), join([r[2],r[1][2]])]; all_pairs=all_pairs); elm2id.(pair2elm(r[2]); elements=elements, all_pairs=all_pairs)]
    for add ∈ adds R[rid, add] += 1 end
    R[rid, rid] -= 1
end

function step_count!(counter, count_rules, elements, all_pairs)
    Δ = zeros(Int, length(all_pairs) + length(elements))
    for (i, cr) in enumerate(eachrow(count_rules))
        m = counter[i]
        m > 0 && (Δ .+= m .* cr)
    end
    counter .+= Δ
end

function use_computer(n, template, rules, elements, all_pairs)
    counter = zeros(Int, length(all_pairs) + length(elements))
    for pair ∈ pairs_in(template) counter[pair2id(pair; all_pairs=all_pairs)]+=1 end
    for (i, e) ∈ enumerate(elements) counter[length(all_pairs)+i] = count(==(e), template) end

    count_rules = zeros(Int, length(all_pairs), length(all_pairs) + length(elements))
    add_rule!.(rules; R=count_rules, elements=elements, all_pairs=all_pairs)

    for i ∈ 1:n step_count!(counter, count_rules, elements, all_pairs) end
    counter[length(all_pairs) + 1:end]
end

span((min, max)) = max - min

coa14_part2(polymer, n) = (span∘extrema∘use_computer)(n, polymer...)


input = readlines("input.txt")

polymer = get_polymer(input)

@show coa14_part2(polymer, 40)

using BenchmarkTools

@btime coa14_part2(polymer, 40)
