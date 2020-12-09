function sort_system!(the_system, verbose = false)
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

    verbose && println("Sorting system...")

    ## Fill in some extra info in each item
    item_init!(the_system.item)

    ## Ground is added to the system, because it is not in the user-defined system
    push!(the_system.item, body("ground"))  ## Ground body is added last (important!)

    ## Find the type of each item, and sort into named fields
    locn(item) = getproperty(the_system,Symbol(string(typeof(item)) * "s"))
    push!.(locn.(the_system.item), the_system.item)

    ## Find the body number from the name
    verbose && println("Looking for connection info...")
    names = name.(the_system.bodys)
    find_bodynum!.(the_system.item, tuple(names))
    find_bodyframenum!.(the_system.loads, tuple(names))

    ## Find the actuator number from the name
    find_actnum!.(the_system.sensors, tuple(name.(the_system.actuators)))

    ## Find the radius of each connector
    verbose && println("Looking for location info...")
    find_radius!.(the_system.item, tuple(location.(the_system.bodys)))

    verbose && println("System sorted.")

end  ## Leave
