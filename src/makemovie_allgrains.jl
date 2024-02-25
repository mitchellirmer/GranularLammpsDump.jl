export makemovie_allgrains

function makemovie_allgrains(dump,boxes,skips,dumpfile="allgrains")
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
