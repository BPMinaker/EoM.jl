function input_ex_smd(; m = 1.0, c = 0.1, k = 10.0)

    # a classic spring mass damper problem
    the_system = mbd_system("Spring Mass Damper")

    # add the body
    item = body("block")
    item.mass = m
    item.location = [0, 0, 1]
    add_item!(item, the_system)

    # constrain the body to one translation in z, and no rotations
    item = rigid_point("slider 1")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location = [0, 0, 1]
    item.forces = 2
    item.moments = 3
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    # add a flex_point, with damping, to connect our body to ground, aligned with z-axis
    item = flex_point("spring 1")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location = [0, 0, 0.5]
    item.stiffness = [k, 0]
    item.damping = [c, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    # the actuator is a `line item` and defined by two locations, location[1] attaches to body[1]...
    item = actuator("f")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, 0, 0]
    item.units = "N"
    add_item!(item, the_system)

    # the sensor is also `line item` and defined by two locations, location[1] attaches to body[1]...
    item = sensor("z")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, 0, 0]
    item.units = "m"
    add_item!(item, the_system)

    item = sensor("z dot")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, 0, 0]
    item.order = 2 # velocity
    item.units = "m/s"
    add_item!(item, the_system)

    item = sensor("kz")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, 0, 0]
    item.gain = k
    item.units = "N"
    add_item!(item, the_system)

    the_system

end
