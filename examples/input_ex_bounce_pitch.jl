function input_ex_bounce_pitch(; u = 0, a = 1.189, b = 2.885 - 1.189, kf = 35000, kr = 38000, cf = 1000, cr = 1200, m = 16975 / 9.81, Iy = 3267)

    ## Copyright (C) 2017, Bruce Minaker
    ## input_ex_bounce_pitch.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_bounce_pitch.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## A bounce pitch model
    the_system = mbd_system("Bounce Pitch Model")

    ## Add one body representing the chassis
    item = body("chassis")
    item.mass = m
    item.moments_of_inertia = [0, Iy, 0]  ## Only the Iy term matters here
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, 0.25]  ## Put cg at origin, but offset vertically to make animation more clear
    item.velocity = [u, 0, 0]
    add_item!(item, the_system)

    ## Add a spring, to connect our chassis to ground, representing the front suspension
    item = flex_point("front susp")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [a, 0, 0.25]  ## Front axle "a" m ahead of cg
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]  ## Spring acts in z direction
    item.stiffness = [kf, 0]  ## Linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
    item.damping = [cf, 0]
    add_item!(item, the_system)

    ## Rear suspension
    item = flex_point("rear susp")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [-b, 0, 0.25]  ## Rear axle "b" m behind cg
    item.forces = 1
    item.moments = 0
    item.axis = [0, 0, 1]
    item.stiffness = [kr, 0]
    item.damping = [cr, 0]
    add_item!(item, the_system)

    ## Constrain to linear motion in z direction (bounce)
    item = rigid_point("bounce")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0.25]
    item.forces = 2
    item.moments = 0
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    ## Constrain to rotational motion around y axis (pitch)
    item = rigid_point("pitch")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0.25]
    item.forces = 0
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    ## Measure the bounce and pitch
    item = sensor("z_G")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0, 0]
    item.units = "m"
    add_item!(item, the_system)

    item = sensor("θ(a+b)")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0.25]
    item.location[2] = [0, 0.1, 0.25]
    item.twist = 1
    item.gain = a + b
    item.units = "m"
    add_item!(item, the_system)

    ## Force the bounce and pitch
    item = actuator("u_f")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [a, 0, 0.1]
    item.location[2] = [a, 0, 0]
    item.gain = kf
    item.rate_gain = cf
    item.units = "m"
    add_item!(item, the_system)

    item = actuator("u_r")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [-b, 0, 0.1]
    item.location[2] = [-b, 0, 0]
    item.gain = kr
    item.rate_gain = cr
    item.units = "m"
    add_item!(item, the_system)

    the_system

end
