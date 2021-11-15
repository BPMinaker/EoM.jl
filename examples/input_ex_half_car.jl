function input_ex_half_car(; u = 0, a = 1.189, b = 2.885 - 1.189, kf = 35000, kr = 38000, cf = 1000, cr = 1200, m = 16975 / 9.81, Iy = 3267, kt = 300000, muf = 50, mur = 50)

    ## Copyright (C) 2017, Bruce Minaker
    ## input_ex_half_car.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_half_car.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## A half car model
    ## Note tire and suspension properties are for both left and right sides summed
    the_system = mbd_system("Half Car Model")

    # add one body representing the chassis
    item = body("chassis")
    item.mass = m
    item.moments_of_inertia = [0, Iy, 0] # only the Iy term matters here
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, 0.25] # put cg at origin, but offset vertically to make animation more clear
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = body("front unsprung")
    item.mass = muf
    item.location = [a, 0, 0.1]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    item = body("rear unsprung")
    item.mass = muf
    item.location = [-b, 0, 0.1]
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)
    add_item!(weight(item), the_system)

    # add a spring, to connect our chassis to the front suspension
    item = flex_point("front susp")
    item.body[1] = "chassis"
    item.body[2] = "front unsprung"
    item.location = [a, 0, 0.25] # front axle "a" m ahead of cg
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1] # spring acts in z direction
    item.stiffness = [kf, 0] # linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
    item.damping = [cf, 0]
    add_item!(item, the_system)

    # rear suspension
    item = flex_point("rear susp")
    item.body[1] = "chassis"
    item.body[2] = "rear unsprung"
    item.location = [-b, 0, 0.25] # rear axle "b" m behind cg
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1] # spring acts in z direction
    item.stiffness = [kr, 0] # linear stiffness "kr" N/m; (torsional stiffness zero, not a torsion spring so has no effect
    item.damping = [cr, 0]
    add_item!(item, the_system)

    item = flex_point("tire")
    item.body[1] = "front unsprung"
    item.body[2] = "ground"
    item.stiffness = [kt, 0]
    item.damping = [0, 0]
    item.location = [a, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    item = flex_point("tire")
    item.body[1] = "rear unsprung"
    item.body[2] = "ground"
    item.stiffness = [kt, 0]
    item.damping = [0, 0]
    item.location = [-b, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    item = rigid_point("slider front")
    item.body[1] = "front unsprung"
    item.body[2] = "ground"
    item.location = [a, 0, 0.1]
    item.forces = 2
    item.moments = 3
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    item = rigid_point("slider rear")
    item.body[1] = "rear unsprung"
    item.body[2] = "ground"
    item.location = [-b, 0, 0.1]
    item.forces = 2
    item.moments = 3
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    # constrain to linear motion in z direction (bounce)
    item = rigid_point("road frc")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0.25]
    item.forces = 2
    item.moments = 0
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    item = rigid_point("road mmt")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0.25]
    item.forces = 0
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    # force the bounce and pitch
    item = actuator("u_f")
    item.body[1] = "front unsprung"
    item.body[2] = "ground"
    item.location[1] = [a, 0, 0.1]
    item.location[2] = [a, 0, 0]
    item.gain = kt
    item.units = "m"
    add_item!(item, the_system)

    # measure the bounce
    item = sensor("z_G")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0, 0]
    item.units = "m"
    add_item!(item, the_system)

    # suspension travel
    item = sensor("z_f")
    item.body[1] = "chassis"
    item.body[2] = "front unsprung"
    item.location[1] = [a, 0, 0.25]
    item.location[2] = [a, 0, 0.1]
    item.units = "m"
    add_item!(item, the_system)

    # add measure between ground and unsprung mass
    item = sensor("z_2-u_f")
    item.body[1] = "front unsprung"
    item.body[2] = "ground"
    item.actuator = "u_f"
    item.location[1] = [a, 0, 0.1]
    item.location[2] = [a, 0, 0]
    item.units = "m"
    add_item!(item, the_system)

    the_system

end
