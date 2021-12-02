# Code of Advent 1

fname = "input01.txt"
input = parse.(Int, readlines(fname))

coa01a(data) = foldl(1:length(data)-1) do acc,i
     @inbounds acc += data[i] < data[i+1]
end

coa01b(data) = foldl(1:length(data)-3) do acc,i
    @inbounds acc += data[i] < data[i+3]
end

@show coa01a(input)
@show coa01b(input);

