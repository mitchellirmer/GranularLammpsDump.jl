export settingsloader

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
    makemovie_allgrains(dump, skips, dumpfile="allgrains")

Makes an mp4 movie with 5 groups color coded by initial x position.  

The "skips" variable takes every Nth timestep from the dump dictionary. E.g., use 1 for every timestep or 10 to take every 10th step.

Output is an .mp4 video in the project directory.  The optional dumpfile argument allows matching the output.mp4 to the input file name.
"""
