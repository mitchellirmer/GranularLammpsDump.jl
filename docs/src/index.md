# GranularLammpsDump Quick Start

Tools for parsing LAMMPS dumps (dump files output with "atom" or "custom" arguments), exporting the parsed dumps, and visualizing the simulation as a .mp4 movie. Developed during research for a master's thesis in sheared, vibrated granular flows at the Naval Postgraduate School, Monterey CA. 

![exampleviz1](https://github.com/mitchellirmer/GranularLammpsDump.jl/assets/81964320/7751af12-21f7-44c0-bd7c-c13d41d82ef3)

### Installation
This library isn't in the official registry (yet?).  Add with:
> julia> ]  
> pkg> add https://github.com/mitchellirmer/GranularLammpsDump.jl.git  
> julia> using GranularLammpsDump  

Update with 
> julia> ]  
> pkg> update

### Reading and Parsing Dumps
1. Read an entire dump file into a dictionary with readdump(inputfile).  In principle, this works with any "atom" or "custom" mode LAMMPS dump, but is tested to work for this case in particular:
>|---------------------------------|  
>|ITEM: TIMESTEP                   |  
>|ITEM: NUMBER OF ATOMS            |  
>|ITEM: BOX BOUNDS pp pp ss        |  
>|ITEM: ATOMS id type x y z vx ... |  
>|---------------------------------|  
>
> dump, boxes, Natoms, times = readdump("inputfile")

2. Parse one step at a time into a mutable struct with parsestep -- iterate to analyze multiple steps.  By default, it is set up for x, y, z positions, and vx, vy, vz velocities.  The mutable struct could be modified for any custom outputs.   
> step = parsestep(dump, stepnumber)

3. Export an entire reshaped dump as Julia matrix and optionally as a CSV file to be read into MATLAB (c).  It can export the dump, boxes, and times dictionaries.  
> matrix = dump2mat(dictionary,exportflag)  # // 0 for no CSV, 1 to export a CSV

### Visualizing
1. Open Julia in, or cd() into, the project folder.  
2. Run the setdefaults() function to create a settings.conf menu file in the project folder.  
> setdefaults()

3. Use menu() to open the settings menu in nano, or open settings.conf in the working directory in your favorite text editor.  
> menu()

4. Use readdump(inputfile) to load a dump file.  
> dump, boxes, Natoms, times = readdump("inputfile")

5. Run one of the makemovie functions to make a movie.  The "skips" variable takes every Nth timestep from the dump dictionary. E.g., use 1 for every timestep or 10 to take every 10th step.  The "allgrains" variant visualizes all grains with colorcoding by initial x position.  The "xslice" version takes one x slice, top to bottom, and color codes the particles based on "granular temperature" in the current step.
> makemovie_allgrains(dump, skips, moviename)
>
> makemovie_xslice(dump, skips, moviename)

```@contents
Pages = ["index.md", "handling.md", "visualizing.md"]
Depth = 3
```


