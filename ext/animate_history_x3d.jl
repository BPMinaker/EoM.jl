function EoM.animate_history(
    system::mbd_system,
    yout::EoM.lti_soln,
    verbose::Bool=false;
    folder="output",
    filename::String=system.name
)
    ## Copyright (C) 2017, Bruce Minaker
    ## animate_history.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## animate_history.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## This function takes the time history of the system, and passes it to the animator

    verbose && println("Animating history...")

    dir_date = EoM.setup(; folder)
    dir = joinpath(dir_date, filename, "x3d")
    isdir(dir) || mkpath(dir)

    l = 1:50:length(yout.t)  ## Reduce the number of points to animate
    tout = yout.t[l]
    pout = hcat(yout.y[l]...)

    n = length(system.bodys) - 1

    pout = pout[end - 6*n + 1:end, :]

    # Add static location to displacement
    for j in 1:n
        pout[6*j.+(-5:-3), :] .+= system.bodys[j].location
    end

    pout = item_locations(system, pout)'
    x3d_body!(system)
    x3d_connections!(system)
    
    timestamp = Dates.format(now(), "HH-MM-SS-s")
    history_file = joinpath(dir, "history_$(timestamp).html")
    x3d_animate(system, tout, pout, history_file)

    verbose && println("Animations complete.")
    nothing
end
