using Documenter, GranularLammpsDump

makedocs(
    sitename="GranularLammpsDump Documentation",
    pages = [
        "Home" => "index.md",
        "Handling Dump Files" => "handling.md",
        "Visualizing Dump Files" => "visualizing.md"
        ]
        )

#deploydocs(
#    repo = "github.com/mitchellirmer/GranularLammpsDump.jl.git",
#)
