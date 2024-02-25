export readdump

"""
    readdump("inputfile")

Converts the contents of the dumpfile to dictionaries indexed by step number.

# RETURNS
    dumpstep -> Dictionary where each value is an array of atom attributes for one timestep, sorted by Atom ID.
    boxes -> Dictionary where each value is an [xlo, xhi], [ylo, yhi], [zlo, zhi] array.
    Natoms -> The Int number of atoms in the simulation.
    timedict -> Dictionary where each value is the true timestep from the dump.

Reads the dumpfile into a matrix, shapes the matrix, and removes text lines.  The number of atoms is extracted and used internally but not returned.  The final dictionary form has timesteps as keys, and matrices sorted by particle ID number as values.  In principle, this works for any dumpfile with at least 6 columns of output, but has been tested with 6 output columns and 9 output columns.  
    
Each timestep looks something like this: 
    | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11 |
    | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz |
"""
function readdump(inputfile)
    file = open(inputfile);
    count = 0;
    dumpdict = Dict();
    boxdict = Dict();
    timedict = Dict();
    Natoms = 0;
    labels = [];
    while eof(file) == false
        while readline(file) != "ITEM: TIMESTEP"
            readline(file)
        end
        merge!(timedict, Dict(count => parse(Int,readline(file))))
        
        while readline(file) != "ITEM: NUMBER OF ATOMS"
            readline(file)
        end
        Natoms = parse(Int,readline(file))
        
        while contains(readline(file),"ITEM: BOX BOUNDS") == false
            readline(file)
        end
        x = split(readline(file))
        x = [parse(Float64,x[1]) parse(Float64,x[2])]
        y = split(readline(file))
        y = [parse(Float64,y[1]) parse(Float64,y[2])]
        z = split(readline(file))
        z = [parse(Float64,z[1]) parse(Float64,z[2])]
        
        readuntil(file, "ITEM: ATOMS ")
        labels = split(readline(file))
        dumpstep = zeros(Natoms,length(labels))
        for atom in 1:Natoms
            line = split(readline(file))
            for param in 1:length(labels)
                dumpstep[atom,param] = parse(Float64,line[param])
            end
        end
        dumpstep = sortslices(dumpstep,dims=1)
        merge!(dumpdict,Dict(count => dumpstep))
        box = [x;y;z];
        merge!(boxdict,Dict(count => box))
        count = count+1
    end
    close(file)
    return dumpdict, boxdict, Natoms, timedict
end
