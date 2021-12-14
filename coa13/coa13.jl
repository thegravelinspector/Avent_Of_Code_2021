function get_orgami(input)
    m = findfirst(==(""), input)
    mkpoint(s) = Tuple(parse.(Int, split(s, ',')) .+ (1,1))
    mkfold(s) = (Int('z') - Int(s[1][end]), parse(Int, s[2]))
    (;sheet=mkpoint.(input[1:m-1]), folds=mkfold.(split.(input[m+1:end], '=')))
end

function trans(n)
    0 < n > 1 && return ' '
    nodot_dot = "⋅#"
    nodot_dot[nextind(nodot_dot,1,abs(n))]
end

ascii(A) = join.(eachrow(Char.(map(trans, Int.(A)))))

function inspect_folded_sheet(sheet; chatty=false)
    M = zeros(Int, maximum(first.(origami.sheet)), maximum(last.(origami.sheet)))
    M[CartesianIndex.(sheet)] .= 1
    num_dots = count(==(1), M)
    chatty && println.(ascii(M'))
    chatty && println("Number of dots visible = $num_dots")
    chatty && println()
    num_dots
end

function do_folds!(sheet, folds; chatty=false, chatt_last=false)
    number_visible_dots = Int[]
    push!(number_visible_dots, inspect_folded_sheet(sheet; chatty=chatty))
    for (dim, o) ∈ folds
        for (i,point) in enumerate(sheet)
            if point[(dim%2)+1] > o
                sheet[i] = @. dim==2 ? 2(o+1,0)-point*(1,-1) : 2(0,o+1)-point*(-1,1)
            end
        end
        push!(number_visible_dots, inspect_folded_sheet(sheet; chatty=chatty))
    end
    chatt_last && inspect_folded_sheet(sheet; chatty=true)
    number_visible_dots
end

coa13_part1(origami; chatty=false) = do_folds!(origami...; chatty=chatty)[2]
coa13_part2(origami; chatt_last=false) = do_folds!(origami...; chatt_last=chatt_last)

input = readlines("test.txt")

origami = get_orgami(input)
coa13_part1(origami; chatty=true);

input = readlines("input.txt")

origami = get_orgami(input)
@show coa13_part1(origami)
println()

origami = get_orgami(input)
@show coa13_part2(origami; chatt_last=true);
