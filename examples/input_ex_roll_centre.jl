function input_full_car_rc(; u=0, a=1.189, b=2.885 - 1.189, tf=1.595, tr=1.631, kf=17000, kr=19000, cf=1000, cr=1200, m=16975 / 9.81, Ix=818, Iy=3267, Iz=3508, kt=180000, muf=35, mur=30, hf=0.1, hr=0.2, hG=0.4, krf=100, krr=100, cfy=0, cry=0, r = 0.3)

    ## Copyright (C) 2017, Bruce Minaker
    ## input_ex_full_car.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_full_car.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    the_system = mbd_system("Full Car Model with Swing Axles")

    # add one body representing the chassis
    item = body("chassis")
    item.mass = m
    item.moments_of_inertia = [Ix, Iy, Iz]  ## Only the Iy term matters here
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, hG]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = body("LF wheel")
    item.mass = muf
    item.location = [a, tf / 2, r]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = body("LR wheel")
    item.mass = mur
    item.location = [-b, tr / 2, r]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)


    item = body("LF axle")
    item.mass = 0
    item.location = [a, tf / 2 - 0.15, r]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = body("LR axle")
    item.mass = 0
    item.location = [-b, tr / 2 - 0.15, r]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = rigid_point("fixed speed")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, hG]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)


    item = rigid_point("LF wheel bearing")
    item.body[1] = "LF wheel"
    item.body[2] = "LF axle"
    item.location = [a, tf / 2, r]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = rigid_point("LR wheel bearing")
    item.body[1] = "LR wheel"
    item.body[2] = "LR axle"
    item.location = [-b, tr / 2, r]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)


    item = rigid_point("LF wheel, X")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.location = [a, tf / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = rigid_point("LR wheel, X")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.location = [-b, tr / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)


    # suspension constraints
    item = rigid_point("LF susp")
    item.body[1] = "LF axle"
    item.body[2] = "chassis"
    item.location = [a, 0, hf]
    item.forces = 3
    item.moments = 2
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = rigid_point("LR susp")
    item.body[1] = "LR axle"
    item.body[2] = "chassis"
    item.location = [-b, 0, hr]
    item.forces = 3
    item.moments = 2
    item.axis = [1, 0, 0]
    add_item!(item, the_system)


    # item = rigid_point("LR susp")
    # item.body[1] = "LR wheel"
    # item.body[2] = "chassis"
    # item.location = [-b, tr / 2, hr]
    # item.forces = 2
    # item.moments = 3
    # item.axis = [0, 0, 1]
    # add_item!(item, the_system)


    # anti-roll
    item = body("LF anti-roll arm")
    item.location = [a - 0.2, tf / 2 - r / 2, r - 0.1]
    add_item!(item, the_system)

    item = body("LR anti-roll arm")
    item.location = [-b + 0.2, tr / 2 - r / 2, r - 0.1]
    add_item!(item, the_system)


    item = rigid_point("LF anti-roll hinge")
    item.body[1] = "LF anti-roll arm"
    item.body[2] = "chassis"
    item.location = [a - 0.2, tf / 2 - r / 2, r - 0.1]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = rigid_point("LR anti-roll hinge")
    item.body[1] = "LR anti-roll arm"
    item.body[2] = "chassis"
    item.location = [-b + 0.2, tr / 2 - r / 2, r - 0.1]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)


    item = link("LF drop link")
    item.body[1] = "LF anti-roll arm"
    item.body[2] = "LF axle"
    item.location[1] = [a, tf / 2 - r / 2, r - 0.1]
    item.location[2] = [a, tf / 2 - r / 2, r]
    add_item!(item, the_system)

    item = link("LR drop link")
    item.body[1] = "LR anti-roll arm"
    item.body[2] = "LR axle"
    item.location[1] = [-b, tr / 2 - r / 2, r - 0.1]
    item.location[2] = [-b, tr / 2 - r / 2, r]
    add_item!(item, the_system)


    # anti-roll bars
    # note that the right side entries will come from the mirror
    item = spring("F anti-roll")
    item.body[1] = "LF anti-roll arm"
    item.body[2] = "RF anti-roll arm"
    item.location[1] = [a - 0.2, tf / 2 - 0.2, r - 0.1]
    item.location[2] = [a - 0.2, -tf / 2 + 0.2, r - 0.1]
    item.stiffness = krf
    item.twist = 1
    add_item!(item, the_system)

    item = spring("R anti-roll")
    item.body[1] = "LR anti-roll arm"
    item.body[2] = "RR anti-roll arm"
    item.location[1] = [-b + 0.2, tr / 2 - 0.2, r - 0.1]
    item.location[2] = [-b + 0.2, -tr / 2 + 0.2, r - 0.1]
    item.stiffness = krr
    item.twist = 1
    add_item!(item, the_system)


    # front suspension
    item = spring("LF spring")
    item.body[1] = "LF axle"
    item.body[2] = "chassis"
    item.location[1] = [a, tf / 2 - 0.15, r]
    item.location[2] = [a, tf / 2 - 0.15, 2 * r + 0.1]
    item.stiffness = kf
    item.damping = cf
    add_item!(item, the_system)

    # rear suspension
    item = spring("LR spring")
    item.body[1] = "LR axle"
    item.body[2] = "chassis"
    item.location[1] = [-b, tr / 2 - 0.15, r]
    item.location[2] = [-b, tr / 2 - 0.15, 2 * r + 0.1]
    item.stiffness = kr
    item.damping = cr
    add_item!(item, the_system)


    # tire vertical stifness
    item = flex_point("LF tire, Z")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.stiffness = [kt, 0]
    item.damping = [0, 0]
    item.location = [a, tf / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    item.rolling_axis = [0, 1, 0]
    add_item!(item, the_system)

    item = flex_point("LR tire, Z")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.stiffness = [kt, 0]
    item.damping = [0, 0]
    item.location = [-b, tr / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    item.rolling_axis = [0, 1, 0]
    add_item!(item, the_system)


    item = flex_point("LF tire, Y")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.damping = [cfy / u, 0]
    item.location = [a, tf / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = flex_point("LR tire, Y")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.damping = [cry / u, 0]
    item.location = [-b, tr / 2, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)



    # tire lateral force
    item = actuator("LF tire, Y")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.location[1] = [a, tf / 2, 0]
    item.location[2] = [a, tf / 2 - 0.1, 0]
    item.units = "N"
    add_item!(item, the_system)

    item = actuator("LR tire, Y")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.location[1] = [-b, tr / 2, 0]
    item.location[2] = [-b, tr / 2 - 0.1, 0]
    item.units = "N"
    add_item!(item, the_system)


    # tire measure vertical force
    item = sensor("LF tire, Z")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.gain = kt
    item.location[1] = [a, tf / 2, 0.1]
    item.location[2] = [a, tf / 2, 0]
    item.units = "N"
    add_item!(item, the_system)

    item = sensor("LR tire, Z")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.gain = kt
    item.location[1] = [-b, tr / 2, 0.1]
    item.location[2] = [-b, tr / 2, 0]
    item.units = "N"
    add_item!(item, the_system)


    # tire, measure slip angle
    item = sensor("LF tire, alpha")
    item.body[1] = "LF wheel"
    item.body[2] = "ground"
    item.location[1] = [a, tf / 2, 0]
    item.location[2] = [a, tf / 2 - 0.1, 0]
    item.order = 2
    item.frame = 0
    item.gain = 1 / u
    item.units = "radian"
    add_item!(item, the_system)

    item = sensor("LR tire, alpha")
    item.body[1] = "LR wheel"
    item.body[2] = "ground"
    item.location[1] = [-b, tr / 2, 0]
    item.location[2] = [-b, tr / 2 - 0.1, 0]
    item.order = 2
    item.frame = 0
    item.gain = 1 / u
    item.units = "radian"
    add_item!(item, the_system)

    mirror!(the_system) # note that the mirror can't go any further without adressing the change in the location in the sequence of items in the main file

    item = sensor("r")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0, 0]
    item.twist = 1
    item.order = 2
    item.gain = 180 / pi
    item.units = "degree/s"
    add_item!(item, the_system)

    # measure the bounce, pitch, and roll
    item = sensor("zG")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0, 0]
    item.units = "m"
    add_item!(item, the_system)

    item = sensor("phi")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [-0.1, 0, 0.25]
    item.gain = 180 / pi
    item.twist = 1
    item.units = "degree"
    add_item!(item, the_system)

    item = sensor("theta")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, -0.1, 0.25]
    item.gain = 180 / pi
    item.twist = 1
    item.units = "degree"
    add_item!(item, the_system)

    item = sensor("beta")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, -0.1, 0.25]
    item.order = 2 # velocity
    item.frame = 0 # local frame
    item.gain = 180 / pi / u # radian to degree
    item.units = "degree"
    add_item!(item, the_system)

    item = sensor("ru")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, hG]
    item.location[2] = [0, 0, -0.1]
    item.gain = u
    item.order = 2 # velocity
    item.twist = 1
    item.units = "m/ss"
    add_item!(item, the_system)

    item = sensor("(kf+kr)zG")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0, 0]
    item.gain = kf + kr
    item.units = "N"
    add_item!(item, the_system)

    item = sensor("(kf+kr)(t)phi")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [-0.1, 0, 0.25]
    item.gain = (kf + kr) * (tf + tr) / 2
    item.twist = 1
    item.units = "N"
    add_item!(item, the_system)

    the_system

end
