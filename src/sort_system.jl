function sort_system!(the_system::mbd_system, verb::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## sort_system.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## sort_system.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Sort the system into a new structure

    verb && println("Sorting system: $(the_system.name)...")

    ## Ground is added to the system, because it is not in the user-defined system
    push!(the_system.item, body("ground"))  ## Ground body is added last (important!)

    ## Find the type of each item, and sort into named fields
    sort_items!.(the_system.item, tuple(the_system))

    ## Find the body number
    verb && println("Looking for connection info...")
    # link each bodys name with its number in the list
    idx = Dict(getfield.(the_system.bodys, :name) .=> 1:length(the_system.bodys))
    find_bodynum!.(the_system.item, tuple(idx))
    find_bodyframenum!.(the_system.loads, tuple(idx))
    idx = Dict(getfield.(the_system.actuators, :name) .=> 1:length(the_system.actuators))
    find_actnum!.(the_system.sensors, tuple(idx))

    ## Find the radius of each connector
    verb && println("Looking for location info...")
    find_radius!.(the_system.item, tuple(getfield.(the_system.bodys, :location)))

    verb && println("System sorted.")

end  ## Leave
