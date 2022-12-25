function sort_system!(the_system::mbd_system, verb::Bool = false)

    # Sort the system into a new structure

    verb && println("Sorting system: $(the_system.name)...")

    # Ground is added to the system, because it is not in the user-defined system
    push!(the_system.item, body("ground"))  ## Ground body is added last (important!)

    # Find the type of each item, and sort into named fields
    sort_items!.(the_system.item, (the_system,))

    # Find the body number
    verb && println("Looking for connection info...")
    # link each bodys name with its number in the list
    idx = Dict(getfield.(the_system.bodys, :name) .=> eachindex(the_system.bodys))
    find_bodynum!.(the_system.item, (idx,))
    find_bodyframenum!.(the_system.loads, (idx,))
    idx = Dict(getfield.(the_system.actuators, :name) .=> eachindex(the_system.actuators))
    find_actnum!.(the_system.sensors, (idx,))

    # Find the radius of each connector
    verb && println("Looking for location info...")
    find_radius!.(the_system.item, (getfield.(the_system.bodys, :location),))

    verb && println("System sorted.")

end  ## Leave