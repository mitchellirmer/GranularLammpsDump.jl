# // This module offers several tools for making LAMMPS dump files more approachable.
# // Also a couple of ways to make movies.  
module GranularLammpsDump

export getNatoms, readdump, parsestep, dump2mat, settingsloader, setdefaults, menu, makemovie_allgrains, makemovie_xslice

using DelimitedFiles, Plots, StatsBase, Colors


"""
    getNatoms("inputfile")
Parses the total number of atoms into an integer.

Looks at the 4th line of the dump file and parses the number of atoms from the readline string into an integer.
"""
function getNatoms(inputfile)
    file = open(inputfile);
    for it in 1:4
        Natoms = readline(file)
    end
    close(file);
    Natoms = parse(Int,Natoms);
    return Natoms
end

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

"""
    dump2mat(dict,exportflag=1)

Converts the readdump dictionary to one giant matrix.  Optionally export as .csv file.

Export to .csv is on by default.  This will help you collaborate with Matlab users ;)  Set exportflag to 0 to turn off.  
"""
function dump2mat(stepdict, exportflag=1)
    mat = Matrix{Float64};
    for it in 0:length(stepdict) - 1
       newstep = get(stepdict,it,3);
       mat = [mat; newstep];
    end
    mat = mat[2:end,:];
    if exportflag == 1
        writedlm("dump2mat.csv",mat,',');
    end
    return mat
end

# // Above -- dump handling
# // Below -- visualizing

"""
    settingsloader()

Loads the settings.conf file into a settings dictionary.

Used inside other functions, but not useful as a standalone function.
"""
function settingsloader()
   settings = Dict();
   settingsmatrix = readdlm("settings.conf");
   for it in 1:length(settingsmatrix[:,1])
       nextentry = Dict(settingsmatrix[it,1] => settingsmatrix[it,2]);
       merge!(settings,nextentry);
   end
   return settings
end

"""
    menu()

Brings up the settings menu in system program nano.

Sneaky dependency: requires nano to be installed prior to use.
"""
function menu()
    run(`nano settings.conf`)
end

"""
    setdefaults()
    
Create the first settings file for the project.
    
# Example
```julia-repl
julia> cd("/home/JuliaUser/Project")
julia> setdefaults()  
Default settings.conf created.  
Edit this using menu() or your favorite text editor.  
```
"""
function setdefaults()
    defaults = ["a" "a";
                "PLOT" "SETTINGS";
                "grainsize" 25;
                "bordersize" 2;
                "opacity" 0.5;
                "labelsfontsize" 24;
                "color1" "blue";
                "color2" "green";
                "color3" "yellow";
                "color4" "orange";
                "color5" "red";
                "b" "b";
                "MOVIE" "SETTNGS";
                "fps" 20;
                "radialview" 10;
                "azimuthalview" 5;
                "widthpx" 1200;
                "heightpx" 1200;
                "c" "c";
                "CUSTOM" "SETTINGS";
                "Tlower" 0.3;
                "Tlow" 0.75;
                "Thigh" 1.25;
                "Thigher" 3];
    file = open("settings.conf", "w");
    writedlm(file, defaults, ' '); # // delimiter is a space
    close(file);
    if isfile("settings.conf")
        display("Default settings.conf created.")
        display("Edit this using menu() or your favorite text editor.")
    end
end

"""
    makemovie_allgrains(dump, skips, dumpfile="allgrains")

Makes an mp4 movie with 5 groups color coded by initial x position.  

The "skips" variable takes every Nth timestep from the dump dictionary. E.g., use 1 for every timestep or 10 to take every 10th step.

Output is an .mp4 video in the project directory.  The optional dumpfile argument allows matching the output.mp4 to the input file name.
"""
function makemovie_allgrains(dump,boxes,skips,dumpfile="allgrains")
    if !isfile("settings.conf")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
        display("Run setdefaults() and try again!")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
    end
     settings = settingsloader();
    gr(size=(get(settings, "widthpx", 1200), get(settings, "heightpx", 1200))); # // define the output size
    default(legend = false) # // turn off legend in the movie
    
    # make box
    mat = dump2mat(boxes, 0);
    x = mat[1:3:end,:];
    xmin = floor(minimum(x[:,1]));
    xmax = ceil(maximum(x[:,2]));
    y = mat[2:3:end,:];
    ymin = floor(minimum(y[:,1]));
    ymax = ceil(maximum(y[:,2]));
    z = mat[3:3:end,:];
    zmin = floor(minimum(z[:,1]));
    zmax = ceil(maximum(z[:,2]));
    
    init = get(dump,0,3);
    c1 = findall(a->a>=-5 && a < -3,init[:,3]);
    c2 = findall(a->a>=-3 && a < -1,init[:,3]);
    c3 = findall(a->a>=-1 && a < 1,init[:,3]);
    c4 = findall(a->a>=1 && a < 3,init[:,3]);
    c5 = findall(a->a>=3 && a <= 5,init[:,3]);

    # vizualizating settings
    grainsize = get(settings, "grainsize", 25);
    bordersize = get(settings, "bordersize", 2);
    opacity = get(settings, "opacity", 0.5);
    camera_angle = (get(settings, "radialview", 10), get(settings,"aziumuthalview", 5));

    # // make the plots that form the movie
    anim = @animate for ts in 0:skips:length(dump) - 1
        steps = get(dump,ts,3);
        # // add something here about sorting into a color by x position
        scatter(
            steps[c1,3],steps[c1,4],steps[c1,5], 
            xlims = (xmin,xmax),
            xlabel = "x",
            ylims = (ymin,ymax),
            ylabel = "y",
            zlabel = "z",
            guidefont=font(get(settings,"labelsfontsize", 24)),
            zlims = (zmin, zmax),
            camera = camera_angle, # // measured in degrees
            aspect_ratio = :equal,
            msize = grainsize, 
            mcolor = get(settings,"color1", "blue"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c2,3],steps[c2,4],steps[c2,5], 
            msize = grainsize, 
            mcolor = get(settings,"color2", "green"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c3,3],steps[c3,4],steps[c3,5], 
            msize = grainsize, 
            mcolor = get(settings,"color3", "yellow"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c4,3],steps[c4,4],steps[c4,5], 
            msize = grainsize, 
            mcolor = get(settings,"color4", "orange"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c5,3],steps[c5,4],steps[c5,5], 
            msize = grainsize, 
            mcolor = get(settings,"color5", "red"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
    end
    mp4(anim, fps=get(settings,"fps",20) , loop=0, verbose=false, show_msg=true);
    return movie
end

"""
    makemovie_xslice(dump, skips, dumpfile="xslice")

Makes an mp4 movie from one x slice, top to bottom, and color codes the particles based on "granular temperature" in the current step. 

The "skips" variable takes every Nth timestep from the dump dictionary. E.g., use 1 for every timestep or 10 to take every 10th step.

Output is an .mp4 video in the project directory.  The optional dumpfile argument allows matching the output.mp4 to the input file name.
"""
function makemovie_xslice(dump,boxes,skips,dumpfile="xslice")
     if !isfile("settings.conf")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
        display("Run setdefaults() and try again!")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
    end
    settings = settingsloader();
    gr(size=(get(settings, "widthpx", 1200), get(settings, "heightpx", 1200))); # // define the output size
    default(legend = false) # // turn off legend in the movie
    
    # make box
    mat = dump2mat(boxes, 0);
    x = mat[1:3:end,:];
    xmin = floor(minimum(x[:,1]));
    xmax = ceil(maximum(x[:,2]));
    y = mat[2:3:end,:];
    ymin = floor(minimum(y[:,1]));
    ymax = ceil(maximum(y[:,2]));
    z = mat[3:3:end,:];
    zmin = floor(minimum(z[:,1]));
    zmax = ceil(maximum(z[:,2]));
   
    init = get(dump,0,3);
    sample = findall(a->a>=-5 && a < -3,init[:,3]);
    
    # vizualizating settings
    grainsize = get(settings, "grainsize", 25);
    bordersize = get(settings, "bordersize", 2);
    opacity = get(settings, "opacity", 0.5);
    camera_angle = (get(settings, "radialview", 10),get(settings,"aziumuthalview", 5));

    # // make the plots that form the movie
    anim = @animate for ts in 0:skips:length(dump) - 1
        steps = get(dump,ts,3);
        steps = steps[sample,:];
        meanvy = mean(steps[:,7]);
        Ty = (steps[:,7] .- meanvy).^2;
        maxTy = maximum(Ty);
        meanTy = mean(Ty);
        c1 = findall(a->a>=0 && a < get(settings,"Tlower", 0.3)*meanTy, Ty);
        c2 = findall(a->a>=get(settings,"Tlower", 0.3)*meanTy && a < get(settings,"Tlow", 0.75)*meanTy, Ty);
        c3 = findall(a->a>=get(settings,"Tlow", 0.75)*meanTy && a < get(settings,"Thigh", 1.25)*meanTy, Ty);
        c4 = findall(a->a>= get(settings,"Thigh", 1.25)*meanTy && a < get(settings,"Thigher", 3)*meanTy, Ty);
        c5 = findall(a->a>= get(settings,"Thigher", 3)*meanTy && a <= maxTy, Ty);
        # // add something here about sorting into a color by x position
        scatter(
            steps[c1,3],steps[c1,4],steps[c1,5], 
            xlims = (xmin,xmax),
            xlabel = "x",
            ylims = (ymin,ymax),
            ylabel = "y",
            zlabel = "z",
            guidefont=font(get(settings,"labelsfontsize", 24)),
            zlims = (zmin, zmax),
            camera = camera_angle, # // measured in degrees
            aspect_ratio = :equal,
            msize = grainsize, 
            mcolor = get(settings,"color1", "blue"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c2,3],steps[c2,4],steps[c2,5], 
            msize = grainsize, 
            mcolor = get(settings,"color2", "green"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c3,3],steps[c3,4],steps[c3,5], 
            msize = grainsize, 
            mcolor = get(settings,"color3", "yellow"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c4,3],steps[c4,4],steps[c4,5], 
            msize = grainsize, 
            mcolor = get(settings,"color4", "orange"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
        scatter!(
            steps[c5,3],steps[c5,4],steps[c5,5], 
            msize = grainsize, 
            mcolor = get(settings,"color5", "red"),
            malpha = opacity,
            mscolor = "black",
            mswidth = bordersize
            )
    end
    mp4(anim, string(dumpfile,".mp4"), fps=get(settings,"fps",20) , loop=0, verbose=false, show_msg=true)
end 
     
     
end #module
