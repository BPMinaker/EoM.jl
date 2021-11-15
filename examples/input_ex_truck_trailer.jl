function input_ex_truck_trailer(; u = 10, a = 1.289, b = 2.885 - 1.289, cf = 80000, cr = 80000, m = 16975 / 9.81, Iz = 3508, d = 2.7, e = 2.7, h = 0.3, ct = 80000, mt = 2000, It = 3000)

    ## Copyright (C) 2017, Bruce Minaker
    ## input_ex_truck_trailer.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_truck_trailer.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## The classic truck and trailer model
    ## a = front axle to truck cg
    ## b = rear axle to truck cg
    ## d = hitch to truck cg
    ## e = hitch to trailer cg
    ## h = trailer axle to trailer cg
    ## m = truck mass
    ## Iz = truck yaw inertia
    ## mt = trailer mass
    ## It = trailer yaw inertia
    ## cf = front cornering stiffness (total)
    ## cr = rear cornering stiffness (total)
    ## ct = trailer cornering stiffness (total)
    the_system = mbd_system("Truck Trailer")

    if (u == 0)
        error("Speed must be non-zero.")
    end

    ## Add the truck at the origin
    item = body("truck")
    item.mass = m
    item.moments_of_inertia = [0, 0, Iz]
    item.location = [0, 0, 0]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)

    ## Add the trailer, along the x-axis
    ## note that location unstable at -6.5, -6.9
    item = body("trailer")
    item.mass = mt
    item.moments_of_inertia = [0, 0, It]
    item.location = [-d - e, 0, 0]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)

    ## Add a damping, to connect our body to ground, aligned with y-axis, to model the tire
    ## Note that the damping decays with speed
    item = flex_point("front tire")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location = [a, 0, 0]
    item.damping = [cf / u, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = flex_point("rear tire")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location = [-b, 0, 0]
    item.damping = [cr / u, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)


    item = flex_point("trailer tire")
    item.body[1] = "trailer"
    item.body[2] = "ground"
    item.location = [-d - e - h, 0, 0]
    item.damping = [ct / u, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)


    ## Constrain truck to planar motion
    item = rigid_point("road")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 2
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    ## Constrain truck to trailer with hinge
    item = rigid_point("hitch")
    item.body[1] = "truck"
    item.body[2] = "trailer"
    item.location = [-d, 0, 0]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    # constrain chassis in the forward direction
    # the left/right symmetry of the chassis tells us that the lateral and longitudinal motions are decoupled anyway
    # could use nhpoint instead of rigid here, but just gives another zero eigenvalue, which causes grief elsewhere due to repeated zero roots
    item = rigid_point("speed")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = actuator("δ_f")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location[1] = [a, 0, 0]
    item.location[2] = [a, 0.1, 0]
    item.gain = cr * pi / 180
    item.units = "degree"
    add_item!(item, the_system)

    # measure the yaw rate
    item = sensor("r")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0, 0.1]
    item.twist = 1 # angular
    item.order = 2 # velocity
    item.gain = 180 / pi # radian to degree
    item.units = "degree/s"
    add_item!(item, the_system)

    item = sensor("β")
    item.body[1] = "truck"
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
    item.body[1] = "truck"
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

    item = sensor("γ")
    item.body[1] = "truck"
    item.body[2] = "trailer"
    item.location[1] = [-d, 0, 0]
    item.location[2] = [-d, 0, 0.1]
    item.twist = 1 # angular
    item.gain = 180 / pi # radian to degree
    item.units = "degree"
    add_item!(item, the_system)

    # measure the lateral acceleration in g
    item = sensor("a_y")
    item.body[1] = "truck"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0.1, 0]
    item.order = 3 # acceleration
    item.gain = 1 / 9.81 # g
    item.units = "g"
    add_item!(item, the_system)

    the_system

end ## Leave
