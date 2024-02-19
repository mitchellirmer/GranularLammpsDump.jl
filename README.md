# GranularLammpsDump.jl
For sheared granular flows: tools for parsing LAMMPS dumps (dump files), exporting the parsed dumps, and visualizing.  

### Reading and Parsing Dumps
1. Read an entire dump file into a dictionary with readdump(inputfile).  In principle, this works with any dump file with at least 6 outputs.  
> dump = readdump(inputfile)
2. Parse one step at a time into a mutable struct with parsestep -- iterate to analyze multiple steps.  By default, it is set up for x, y, z positions, and vx, vy, vz velocities.  The mutable struct could be modified for any custom outputs.  
> step = parsestep(dump, stepnumber)
3. Export an entire reshaped dump as Julia matrix and optionally as a CSV file to be read into MATLAB (c).  
> matrix = dump2mat(dump,exportflag)  # // 0 for no CSV, 1 to export a CSV

### Visualizing
1. Open Julia in, or cd() into, the project folder.  
2. Run the setdefaults() function to create a settings.conf menu file.  
> setdefaults()
3. Use menu() to open the settings menu in nano, or open settings.conf in the working directory in your favorite text editor.  
> menu()
>
>![examplemenu](https://github.com/mitchellirmer/GranularLammpsDump.jl/assets/81964320/f3fcdebe-523a-4936-bbfb-8ba1bb65f958)


4. Use dump = readdump(inputfile) to load a dump file.  
5. Run one of the makemovie functions to make a movie.  The "skips" variable takes every Nth timestep from the dump dictionary. E.g., use 1 for every timestep or 10 to take every 10th step.  The "allgrains" variant visualizes all grains with colorcoding by initial x position.  The "xslice" version takes one x slice, top to bottom, and color codes the particles based on "granular temperature" in the current step.
> makemovie_allgrains(dump, skips, moviename)
> 
> ![exampleviz1](https://github.com/mitchellirmer/GranularLammpsDump.jl/assets/81964320/7751af12-21f7-44c0-bd7c-c13d41d82ef3)
>
> makemovie_xslice(dump, skips, moviename)
> 
> ![exampleviz2](https://github.com/mitchellirmer/GranularLammpsDump.jl/assets/81964320/d62c8e85-2223-4e0c-b22f-2dcebf31a06d)
