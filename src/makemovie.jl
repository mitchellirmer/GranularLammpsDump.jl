export makemovie

"""
    makemovie(dump,boxes,Tref,skips,moviename="granularmovie")
    
Makes an .mp4 movie with all grains shown depicting temperature.

Grains outside the slice of interest are shown as transparent with black borders.

# ARGUMENTS
> Tref is a string, like "0:1/4:6" that sets the powers in 10^Tref
"""
function makemovie(dump, boxes, Tref, skips, moviename="granularmovie")

    if !isfile("settings.conf")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
        display("Run setdefaults() and try again!")
        display("+_+_+_+_+_+_+_+_+_+_+_+_+_+_+")
    end
    settings = settingsloader();
    pyplot(size=(height=get(settings,"heightpx",1200), width=get(settings,"widthpx",1200)));
    default(legend = false) # // turn off legend in the movie
    
    # make box
    boundarytype = get(settings, "boundarytype", "mean");
    if contains(boundarytype,"extreme") == true
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
    else
        mat = dump2mat(boxes, 0);
        x = mat[1:3:end,:];
        xmin = floor(mean(x[:,1]));
        xmax = ceil(mean(x[:,2]));
        y = mat[2:3:end,:];
        ymin = floor(mean(y[:,1]));
        ymax = ceil(mean(y[:,2]));
        z = mat[3:3:end,:];
        zmin = floor(mean(z[:,1]));
        zmax = ceil(mean(z[:,2]));
    end 
   
    init = get(dump,0,3);
    samplegroup = findall(a->a>=-5 && a < -3,init[:,3]);
    antisample = findall(a->a>=-3,init[:,3]);
    
    # vizualizating settings
    grainsize = get(settings, "grainsize", 25);
    bordersize = get(settings, "bordersize", 2);
    opacity = get(settings, "opacity", 0.5);
    camera_angle = (get(settings, "radialview", 10),get(settings,"aziumuthalview", 5));
    
    colors = colorschemes[Symbol(get(settings, "colorscheme", Symbol("lajolla")))];
    
    Tref = split(Tref,":")
    low = parse(Float64,Tref[1])
    if contains(Tref[2], "/") == true
        z = split(Tref[2], "/")
        inc = parse(Float64,z[1]) / parse(Float64,z[2])
        else
        inc = parse(Float64,Tref[2])
    end
    hi = parse(Float64,Tref[3])
    exponents = low:inc:hi;
    edges = zeros(length(exponents));
    for (i,val) in enumerate(exponents)
        edges[i] = 10^-val
    end
    edges = reverse(edges);
    includedsteps = floor((length(dump) - 1)*get(settings,"stepfraction",0.125));
    # // make the plots that form the movie
    anim = @animate for ts in 0:skips:includedsteps
        steps = get(dump,ts,3);
        leftovers = steps[antisample,:];
        steps = steps[samplegroup,:];
        meanvy = mean(steps[:,7]);
        Ty = (steps[:,7] .- meanvy).^2;
        #Ty = (steps[:,7]).^2;
        maxTy = maximum(Ty);
        meanTy = mean(Ty);
        groups = Dict(0 => findall(a->a>= 0 && a < edges[1], Ty));
        for it in 1:length(edges)-1
            nextentry = findall(a->a>= edges[it] && a < edges[it+1], Ty)
            merge!(groups,Dict(it => nextentry))
        end
        nextentry = findall(a->a>= edges[end], Ty)
        merge!(groups,Dict(length(edges) => nextentry))
        
        # // add something here about sorting into a color by x position
        scatter(
            leftovers[:,3],leftovers[:,4],leftovers[:,5], 
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
            mcolor = get(settings,"graincolor_f", "silver"),
            malpha = get(settings,"opacity_f",0.0),
            mscolor = "black",
            msalpha = get(settings,"borderopacity_f",0.5),
            mswidth = get(settings,"bordersize_f",0.5)
            )
         
         for it in 0:length(groups)-1
             scatter!(
                steps[get(groups,it,0),3],steps[get(groups,it,0),4],steps[get(groups,it,0),5], 
                msize = grainsize, 
                mcolor = colors[Int(it * floor(length(colors)/length(groups)) + 1)],
                malpha = get(settings,"opacity_i",0.67),
                mscolor = "black",
                msalpha = get(settings,"borderopacity_i",0.5),
                mswidth = get(settings,"bordersize_i",2),
                )
         end
    end
    mp4(anim, string(dumpfile,".mp4"), fps=get(settings,"fps",20) , loop=0, verbose=false, show_msg=true)
end 
