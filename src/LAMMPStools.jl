# // This module offers several tools for making LAMMPS dump files
# // more approachable.  
module LAMMPStools

export readdump, getNatoms, parsestep, dump2mat, dataloader, makemovie_type1, makemovie_type2

using DelimitedFiles, Plots, Colors

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

# // simple dataloader before visualizing
function dataloader(inputfile)
# // read in the bashed dump file
# // dump is read in like this:
# | 1  |  2    | 3 | 4 | 5 | 6  | 7  | 8  | 9  | 10 | 11 | time
# | ID | GROUP | x | y | z | vx | vy | vz | ux | uy | uz | time
    dump = readdump(inputfile);
    return dump
end

# // Make an mp4 movie with 5 groups color coded by initial x position
function makemovie_type1(dump,skips)
    # // Call other libraries to help visualizeext()
    gr(size=(1200,1200)); # // define the output size
    default(legend = false) # // turn off legend in the movie
    init = get(dump,0,3);
    c1 = findall(a->a>=-5 && a < -3,init[:,3]);
    c2 = findall(a->a>=-3 && a < -1,init[:,3]);
    c3 = findall(a->a>=-1 && a < 1,init[:,3]);
    c4 = findall(a->a>=1 && a < 3,init[:,3]);
    c5 = findall(a->a>=3 && a <= 5,init[:,3]);

    # vizualizating settings
    grainsize = 25;
    bordersize = 2;
    opacity = 0.50;
    camera_angle = (10,5);

    # // make the plots that form the movie
    anim = @animate for ts in 0:skips:length(dump) - 1
        steps = get(dump,ts,3);
        # // add something here about sorting into a color by x position
        scatter(
            steps[c1,3],steps[c1,4],steps[c1,5], 
            xlims = (-5,5),
            xlabel = "x",
            ylims = (-5,5),
            ylabel = "y",
            zlabel = "z",
            guidefont=font(24),
            zlims = (0,14),
            camera = camera_angle, # // measured in degrees
            aspect_ratio = :equal,
            msize = grainsize, 
            mcolor = "purple",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c2,3],steps[c2,4],steps[c2,5], 
            msize = grainsize, 
            mcolor = "red",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c3,3],steps[c3,4],steps[c3,5], 
            msize = grainsize, 
            mcolor = "orange",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c4,3],steps[c4,4],steps[c4,5], 
            msize = grainsize, 
            mcolor = "green",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c5,3],steps[c5,4],steps[c5,5], 
            msize = grainsize, 
            mcolor = "blue",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
    end
    mp4(anim, fps=20, loop=0, verbose=false, show_msg=true)
end

# // Make an mp4 movie with 5 groups color coded by current vy
function makemovie_type2(dump,skips)
    # // Call other libraries to help visualizeext()
    gr(size=(1200,1200)); # // define the output size
    default(legend = false) # // turn off legend in the movie
    init = get(dump,0,3);
    sample = findall(a->a>=-5 && a < -3,init[:,3]);
    
    # vizualizating settings
    grainsize = 25;
    bordersize = 2;
    opacity = 0.50;
    camera_angle = (10,5);

    # // make the plots that form the movie
    anim = @animate for ts in 0:skips:length(dump) - 1
        steps = get(dump,ts,3);
        steps = steps[sample,:];
        maxvy = maximum(abs.(steps[:,7]));
        c1 = findall(a->a>=-maxvy && a < -maxvy/2, steps[:,7]);
        c2 = findall(a->a>=-maxvy/2 && a < -maxvy/10, steps[:,7]);
        c3 = findall(a->a>=-maxvy/10 && a < maxvy/10, steps[:,7]);
        c4 = findall(a->a>= maxvy/10 && a < maxvy/2, steps[:,7]);
        c5 = findall(a->a>= maxvy/2 && a <= maxvy, steps[:,7]);
        # // add something here about sorting into a color by x position
        scatter(
            steps[c1,3],steps[c1,4],steps[c1,5], 
            xlims = (-5,5),
            xlabel = "x",
            ylims = (-5,5),
            ylabel = "y",
            zlabel = "z",
            guidefont=font(24),
            zlims = (0,14),
            camera = camera_angle, # // measured in degrees
            aspect_ratio = :equal,
            msize = grainsize, 
            mcolor = "red",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c2,3],steps[c2,4],steps[c2,5], 
            msize = grainsize, 
            mcolor = "purple",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c3,3],steps[c3,4],steps[c3,5], 
            msize = grainsize, 
            mcolor = "blue",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c4,3],steps[c4,4],steps[c4,5], 
            msize = grainsize, 
            mcolor = "green",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c5,3],steps[c5,4],steps[c5,5], 
            msize = grainsize, 
            mcolor = "yellow",
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
    end
    mp4(anim, fps=20, loop=0, verbose=false, show_msg=true)
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
