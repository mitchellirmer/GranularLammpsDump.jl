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
