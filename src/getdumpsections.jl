export getdumpsections

"""
    getdumpsections(in)
    
Reads the first timestep of a dumpfile and returns section headings.
"""
function getdumpsections(in)
    counter = 1
    file = open(in)
    x = readline(file)
    line = x
    sections = Dict(counter => line)
    while readline(file) != x
        line = readline(file)
        if contains(line,"ITEM") == true
            counter = counter + 1
            merge!(sections,Dict(counter => line))
        end
    end
    close(file)
    return sections
end
