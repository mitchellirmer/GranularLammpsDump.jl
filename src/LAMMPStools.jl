# // This module offers several tools for making LAMMPS dump files
# // more approachable.  
module LAMMPStools

export readdump, getNatoms, parsestep, dump2mat

using DelimitedFiles

# // Get the Natoms in the simulation
function getNatoms(inputfile)
    file = open(inputfile);
    for it in 1:4
        Natoms = readline(file)
    end
    close(file);
    Natoms = Int(Natoms);
    return Natoms
end

# // Convert the dumpfile to a massive dictionary
function readdump(inputfile)
    rawdump = readdlm(inputfile);
    Natoms = Int(rawdump[4,1]);
    ind = findall(a->!isempty(a), rawdump[:,8]);
    rawdump = rawdump[ind,1:11];
    ind = findall(a->a!="ITEM:",rawdump[:,1]);
    rawdump = rawdump[ind,:];
    
    # // Now like this: 
    # | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11
    # | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz
    
    # // First time step
    newstep = rawdump[1:Natoms,:];
    time = zeros(length(newstep[:,1]));
    newdump = [sortslices(newstep, dims=1) time];
    stepdict = Dict(0=>newdump);
    
    # // Now like this: 
    # | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11 | time
    # | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz | time
        
    # // Loop over the others
    for ts in 1:Int(length(rawdump[:,1])/Natoms - 1)
        newstep = rawdump[ts*Natoms+1:ts*Natoms+Natoms,:]
        time = ts .* ones(length(newstep[:,1]));
        newstep = [sortslices(newstep, dims=1) time];
        #newdump = [newdump; newstep] # // turn back on for giant matrix
        nextEntry = Dict(ts=>newstep);
        merge!(stepdict,nextEntry);
    end
    # writedlm("parseddump.csv",newdump,','); # // turn on to export to Matlab
    return stepdict #, newdump
end

# // Define a struct that can hold the useful stuff from each step.
mutable struct dumpstep
    ID::Vector{Any}
    group::Vector{Any}
    x::Vector{Any}
    y::Vector{Any}
    z::Vector{Any}
    vx::Vector{Any}
    vy::Vector{Any}
    vz::Vector{Any}
end

# // Parse a single step for analysis
function parsestep(d,ts)
    # // initialize the struct
    # // each step looks like this:
    # | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11 | time
    # | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz | time
    cs = dumpstep([],[],[],[],[],[],[],[]);
    ts = Int(ts);
    ds = get(d,ts,3);
    flow = findall(a->a==1,ds[:,2]);
    cs.ID = ds[flow,1];
    cs.x = ds[flow,3];
    cs.y = ds[flow,4];
    cs.z = ds[flow,5];
    cs.vx = ds[flow,6];
    cs.vy = ds[flow,7];
    cs.vz = ds[flow,8];
    return cs
end

# // make a giant matrix and optionally export as CSV
function dump2mat(stepdict, exportflag)
    mat = Matrix{Float64};
    for it in 0:length(stepdict) - 1
       newstep = get(d,it,3);
       mat = [mat; newstep];
    end
    mat = mat[2:end,:];
    if exportflag == 1
        writedlm("dump2mat.csv",mat,',');
    end
    return mat
end

end # module LAMMPStools


# // OLD STUFF DOWN HERE
# // Input file is a "shaped" dump file, output from 
# // dumpshaper.sh
#function readdum_old(inputfile, Natoms)
#    Natoms = Int(Natoms);
#    rawdump = readdlm(inputfile);
#    # // Starts like this: 
#    # | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11
#    # | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz
#    
#    # // First time step
#    newstep = rawdump[1:Natoms,:];
#    time = zeros(length(newstep[:,1]));
#    newdump = [sortslices(newstep, dims=1) time];
#    stepdict = Dict(0=>newdump);
#    
#    # // Now like this: 
#    # | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11 | time
#    # | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz | time
#        
#    # // Loop over the others
#    for ts in 1:Int(length(rawdump[:,1])/Natoms - 1)
#        newstep = rawdump[ts*Natoms+1:ts*Natoms+Natoms,:]
#        time = ts .* ones(length(newstep[:,1]));
#        newstep = [sortslices(newstep, dims=1) time];
#        #newdump = [newdump; newstep] # // turn back on for giant matrix
#        nextEntry = Dict(ts=>newstep);
#        merge!(stepdict,nextEntry);
#    end
#    # writedlm("parseddump.csv",newdump,','); # // turn on to export to Matlab
#    return stepdict #, newdump
#end
