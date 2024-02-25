export getNatoms

"""
    getNatoms("inputfile")
Parses the total number of atoms into an integer.

Looks at the 4th line of the dump file and parses the number of atoms from the readline string into an integer.
"""
function getNatoms(inputfile)
    file = open(inputfile);
    for it in 1:4
        Natoms = readline(file)
    end
    close(file);
    Natoms = parse(Int,Natoms);
    return Natoms
end
