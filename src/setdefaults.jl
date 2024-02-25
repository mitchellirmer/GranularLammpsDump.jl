export setdefaults

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
                "--Global" "Options";
                "grainsize" 33;
                "labelsfontsize" 24;
                "colorscheme" "viridis";
                "--Interest" "Group";
                "bordersize_i" 0.75;
                "opacity_i" 0.875;
                "borderopacity_i" 0.95;
                "--Fill" "Group";
                "graincolor_f" "white";
                "bordersize_f" 0.75;
                "borderopacity_f" 0.75;
                "opacity_f" 0.40;
                "b" "b";
                "MOVIE" "SETTNGS";
                "fps" 20;
                "radialview" 10;
                "azimuthalview" 5;
                "widthpx" 1200;
                "heightpx" 1200;
                "c" "c";
                "DATA" "SETTINGS";
                "Tref" "0:1/4:6";
                "stepfraction" 0.125];
    file = open("settings.conf", "w");
    writedlm(file, defaults, ' '); # // delimiter is a space
    close(file);
    if isfile("settings.conf")
        display("Default settings.conf created.")
        display("Edit this using menu() or your favorite text editor.")
    end
end
