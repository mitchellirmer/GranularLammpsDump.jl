export dump2mat

"""
    dump2mat(dict,exportflag=1)

Converts the readdump dictionary to one giant matrix.  Optionally export as .csv file.

Export to .csv is on by default.  This will help you collaborate with Matlab users ;)  Set exportflag to 0 to turn off.  
"""
function dump2mat(stepdict, exportflag=1)
    mat = Matrix{Float64};
    for it in 0:length(stepdict) - 1
       newstep = get(stepdict,it,3);
       mat = [mat; newstep];
    end
    mat = mat[2:end,:];
    if exportflag == 1
        writedlm("dump2mat.csv",mat,',');
    end
    return mat
end
