# GranularLammpsDump.jl
For granular mechanics: tools for parsing LAMMPS dumps (dump files), exporting the parsed dumps, and visualizing.  

### Reading and Parsing Dumps
> Natoms = getNatoms(inputfile)

> dump = readdump(inputfile)

> step = parsedump(dump, stepnumber, warningflag)

### Visualizing
1. Open Julia in, or cd() into, the project folder.  
2. Run the setdefaults() function to create a settings.conf menu file.  
3. Use menu() to open the settings menu in nano, or open settings.conf in the working directory in your favorite text editor.
4. Use dump = readdump(inputfile) to load a dump file.
5. Run one of the makemovie functions to make a movie.  The "skips" variable takes every Nth timestep from the dump dictionary.  Use 1 for every timestep or 10 to take every 10th step.

> setdefaults()

> settings = settingsloader()

> menu()

> makemovie_allgrains(dump, skips, moviename)

> makemovie_xslice(dump, skips, moviename)

