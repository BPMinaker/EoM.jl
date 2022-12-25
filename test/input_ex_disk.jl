function input_ex_disk(; u = 0.1, m = 4, r = 0.5, g = 9.81)

    # The classic rolling disk problem
    #  Schwab,A.L., Meijaard,J.P., Dynamics Of Flexible Multibody Systems With Non-Holonomic Constraints: A Finite Element Approach, Multibody System Dynamics 10: (2003) pp. 107-123
    the_system = mbd_system("Rolling Disk")

    # vcrit=sqrt(gr/3)

    # Add the wheel
    item = body("wheel")
    item.mass = m
    item.moments_of_inertia = [0.25 * m * r^2, 0.5 * m * r^2, 0.25 * m * r^2]
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, r]
    item.velocity = [u, 0, 0]
    item.angular_velocity = [0, u / r, 0]
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    # Add ground contact, vertical and longitudinal forces
    item = rigid_point("contact")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 2
    item.moments = 0
    item.axis = [0, 1, 0]
    item.rolling_axis = [0, 1, 0]
    add_item!(item, the_system)

    # Add ground contact, lateral
    item = nh_point("rolling")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    # Add constant speed
    item = nh_point("constant speed")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location = [0, 0, r]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    # Add some inputs and outputs
    item = sensor("mgrϕ")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location[1] = [0, 0, r]
    item.location[2] = [0.1, 0, r]
    item.twist = 1
    item.gain = m * g * r
    item.units = "Nm"
    add_item!(item, the_system)

    item = sensor("mgrrψdot")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location[1] = [0, 0, r]
    item.location[2] = [0, 0, r + 0.1]
    item.twist = 1
    item.gain = m * g * r *r
    item.order = 2
    item.units = "Nm"
    add_item!(item, the_system)

    item = actuator("L")
    item.body[1] = "wheel"
    item.body[2] = "ground"
    item.location[1] = [0, 0, r]
    item.location[2] = [0.1, 0, r]
    item.twist = 1
    item.units = "Nm"
    add_item!(item, the_system)

    the_system

end
