export parsestep

"""
    mutable struct dumpstep
        
Stores a dumpstep in a struct.
    
Change this to fit your unique dump file layout.
"""
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

"""
    parsestep(d,ts)
    
Stores critical info from a dump step in a mutable struct.
    
Iterate this in a loop to step through a simulation.
"""
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
