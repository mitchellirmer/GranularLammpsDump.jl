module GranularLammpsDump

using DelimitedFiles, Plots, StatsBase, Colors, ColorSchemes

include("readdump.jl")
include("parsestep.jl")
include("dump2mat.jl")
include("getNatoms.jl")
include("menu.jl")
include("setdefaults.jl")
include("settingsloader.jl")
include("makemovie_allgrains.jl")
include("makemovie.jl")

end #module
