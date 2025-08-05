function sort_system!(the_system::mbd_system, verb::Bool = false)

    # Sort the system into a new structure

    verb && println("Sorting system: $(the_system.name)...")

    # Ground is added to the system, because it is not in the user-defined system
    push!(the_system.item, body("ground"))  ## Ground body is added last (important!)

    # Find the type of each item, and sort into named fields
    sort_items!.(the_system.item, [the_system])

    the_system.bodys_name = Dict(getfield.(the_system.bodys, :name) .=> the_system.bodys)
    the_system.links_name = Dict(getfield.(the_system.links, :name) .=> the_system.links)
    the_system.springs_name = Dict(getfield.(the_system.springs, :name) .=> the_system.springs)
    the_system.rigid_points_name = Dict(getfield.(the_system.rigid_points, :name) .=> the_system.rigid_points)
    the_system.flex_points_name = Dict(getfield.(the_system.flex_points, :name) .=> the_system.flex_points)
    the_system.nh_points_name = Dict(getfield.(the_system.nh_points, :name) .=> the_system.nh_points)
    the_system.beams_name = Dict(getfield.(the_system.beams, :name) .=> the_system.beams)
    the_system.loads_name = Dict(getfield.(the_system.loads, :name) .=> the_system.loads)
    the_system.sensors_name = Dict(getfield.(the_system.sensors, :name) .=> the_system.sensors)
    the_system.actuators_name = Dict(getfield.(the_system.actuators, :name) .=> the_system.actuators)

    the_system.bidx = Dict(getfield.(the_system.bodys, :name) .=> eachindex(the_system.bodys))
    the_system.aidx = Dict(getfield.(the_system.actuators, :name) .=> eachindex(the_system.actuators))
    the_system.sidx = Dict(getfield.(the_system.sensors, :name) .=> eachindex(the_system.sensors))

    # Find the body number
    verb && println("Looking for connection info...")
    find_bodynum!.(the_system.item, [the_system.bidx])
    find_bodyframenum!.(the_system.loads, [the_system.bidx])
    find_actnum!.(the_system.sensors, [the_system.aidx])

    # Find the radius of each connector
    verb && println("Looking for location info...")
    find_radius!.(the_system.item, [getfield.(the_system.bodys, :location)])

    verb && println("System sorted.")

end  ## Leave