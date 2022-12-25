function input_ex_pendulum(; m = 10.0, l = 0.5, r = 0.05^0.5, Ix = 5.5 - m * r^2)

    # Copyright (C) 2021, Bruce Minaker

    # the pendulum example from Anderson Practice of Engineering Dynamics
    the_system = mbd_system("Pendulum")

    g = 9.807

    # add the body, and weight force in -ve z
    item = body("block")
    item.mass = m
    item.location = [0, 0, 1]
    item.moments_of_inertia = [Ix, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    # constrain the body to planar motion in yz
    item = rigid_point("planar")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location = [0, 0, 1]
    item.forces = 1
    item.moments = 2
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    # add a string to connect our body to ground, aligned with z-axis
    item = link("string")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1 + r]
    item.location[2] = [0, 0, 1 + r + l]
    add_item!(item, the_system)

    # the actuator is a `line item` and defined by two locations, location[1] attaches to body[1]...
    item = actuator("Y")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, -1, 1]
    item.units = "N"
    add_item!(item, the_system)

    # the sensor is also `line item` and defined by two locations, location[1] attaches to body[1]...
    item = sensor("mgy/(l+r)")
    item.body[1] = "block"
    item.body[2] = "ground"
    item.gain = m * g / (l + r)
    item.location[1] = [0, 0, 1]
    item.location[2] = [0, -1, 1]
    item.units = "N"
    add_item!(item, the_system)

    the_system

end
