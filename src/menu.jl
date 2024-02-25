export menu()

"""
    menu()

Brings up the settings menu in system program nano.

Sneaky dependency: requires nano to be installed prior to use.
"""
function menu()
    run(`nano settings.conf`)
end
