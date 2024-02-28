include("getdumpsections.jl")

export readdump2

"""
    readdump2("inputfile")

Converts the contents of the dumpfile to one dictionary with section titles as keys and data dictionaries as values.

Compared to readdump(), this is SLOWER and MORE GENERAL.  readdump2() should work with ANY dump file.  The outputs are NOT indexed by atom ID.  Use readdump() for custom or atom dumps.
"""
function readdump2(inputfile)
    filepath = inputfile
    sections = getdumpsections(filepath)
    dump = Dict()
    for it in 1:length(sections)
        merge!(dump, Dict(get(sections,it,"0") => Dict()))
    end

    flag = mod(1,length(sections))
    stepcounter = 1
    minidata = 0
    width = 0


    file = open(filepath)
    trailflag = flag
    flag = mod(flag + 1,length(sections))
    if flag == 0
        flag = 4
    end
    while eof(file) == false
        readline(file)
        data = readuntil(file,get(sections,flag,0))
        data = split(data, '\n')
        data = data[1:end-1]
        width = split.(data[1])
        width = split.(width)
        matrix = zeros(length(data),length(width))
        for rows in 1:length(data)
            minidata = split.(data[rows])
            for columns in 1:length(minidata)
                matrix[rows,columns] = parse(Float64,minidata[columns])
            end
        end
        merge!(get(dump,get(sections,trailflag,0),0),Dict(stepcounter => matrix))
        trailflag = flag
        flag = mod(flag + 1, length(sections))
        if flag == 0
            flag = length(sections)
            stepcounter = stepcounter + 1
        end
    end
    close(file)
    return dump
end
