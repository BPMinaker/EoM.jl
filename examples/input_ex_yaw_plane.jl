function input_ex_yaw_plane(; u = 10.0, a = 1.189, b = 2.885 - 1.189, cf = 80000.0, cr = 80000.0, m = 16975 / 9.81, Iz = 3508.0)

    ## Copyright (C) 2017, Bruce Minaker
    ## input_ex_yaw_plane.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_yaw_plane.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    # The classic yaw plane model
    # a = front axle to truck cg
    # b = rear axle to truck cg
    # m = mass
    # I = yaw inertia
    # cf = front cornering stiffness (total)
    # cr = rear cornering stiffness (total)
    the_system = mbd_system("Yaw Plane Vehicle")

    if (u == 0)
        error("Speed must be non-zero!")
    end

    # add one rigid body
    item = body("chassis")
    item.mass = m
    item.moments_of_inertia = [0, 0, Iz]
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, 0]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)

    # add a damping, to connect our body to ground, aligned with y-axis (front tire)
    item = flex_point("front tire")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [a, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    item.damping = [cf / u, 0]
    add_item!(item, the_system)

    # rear tire
    item = flex_point("rear tire")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [-b, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    item.damping = [cr / u, 0]
    add_item!(item, the_system)

    # add an actuator to apply the steering force
    item = actuator("δ_f")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [a, 0, 0]
    item.location[2] = [a, 0.1, 0]
    item.gain = cf * pi / 180 # degree to radian
    item.units = "degree"
    add_item!(item, the_system)

    # rear wheel steer, off by default
    item = actuator("δ_r")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [-b, 0, 0]
    item.location[2] = [-b, -0.1, 0]
    item.gain = cr * pi / 180
    #add_item!(item,the_system)

    # constrain to planar motion
    item = rigid_point("road")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 2
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    # constrain chassis in the forward direction
    # the left/right symmetry of the chassis tells us that the lateral and longitudinal motions are decoupled anyway
    # could use nhpoint instead of rigid here, but just gives another zero eigenvalue, which causes grief elsewhere due to repeated zero roots
    item = rigid_point("speed")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    # measure the yaw rate
    item = sensor("r")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0, 0.1]
    item.twist = 1 # angular
    item.order = 2 # velocity
    item.gain = 180 / pi # radian to degree
    item.units = "degree/s"
    add_item!(item, the_system)

    # measure the body slip angle
    item = sensor("β")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0.1, 0]
    item.order = 2 # velocity
    item.frame = 0 # local frame
    item.gain = 180 / pi / u # radian to degree
    item.units = "degree"
    add_item!(item, the_system)

    # measure the understeer angle
    item = sensor("α_u")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0, 0.1]
    item.twist = 1 # angular
    item.order = 2 # velocity
    item.gain = -180 * (a + b) / pi / u # radian to degree
    item.actuator = "δ_f"
    item.actuator_gain = 1 # input is already in degrees
    item.units = "degree"
    add_item!(item, the_system)

    # measure the lateral acceleration in g
    item = sensor("a_y")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0.1, 0]
    item.order = 3 # acceleration
    item.gain = 1 / 9.81 # g
    item.units = "g"
    add_item!(item, the_system)

    # note that the y location will not reach steady state with constant delta input, so adding the sensor will give an error if the steady state gain is computed, but is included so that a time history can be computed
    item = sensor("y")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0.1, 0]
    item.units = "m"
    add_item!(item, the_system)

    # also won't reach steady state with constant delta input
    item = sensor("θ")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0, 0.1]
    item.twist = 1 # angular
    item.gain = 180 / pi
    item.units = "degree"
    add_item!(item, the_system)

    the_system

end
