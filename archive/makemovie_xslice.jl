# // DEPRECATED
# // export makemovie_xslice

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
    pyplot(size=(get(settings, "widthpx", 1200), get(settings, "heightpx", 1200))); # // define the output size
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
