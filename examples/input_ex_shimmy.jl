function input_ex_shimmy(; m = 5, k = 0.3 * m, a = 0.5, b = 0.5, u = a + b, I = 0.21 * m * (a + b)^2)
    the_system = mbd_system("Shimmy Problem")

    ## Copyright (C) 2018, Bruce Minaker
    ## This file is intended for use with Octave.
    ## input_ex_shimmy.jl is free software, you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation, either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_shimmy.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY, without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ##  Implement the wheel shimmy problem from Schwab and Meijaard paper
    ##  Schwab,A.L., Meijaard,J.P., Dynamics Of Flexible Multibody Systems With Non-Holonomic Constraints: A Finite Element Approach, Multibody System Dynamics 10: (2003) pp. 107-123



    item = body("chassis")
    item.mass = m
    item.location = [0, 0, 0]
    item.velocity = [u, 0, 0]
    item.moments_of_inertia = [0, 0, I]
    add_item!(item, the_system)

    item = flex_point("spring")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.stiffness = [k, 0]
    item.location = [b, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = nh_point("tire")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [-a, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = rigid_point("road")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 2
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    item = rigid_point("speed")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0]
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = actuator("applied force")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [0, 0, 0]
    item.location[2] = [0, 0.1, 0]
    item.units = "N"
    add_item!(item, the_system)

    item = sensor("spring force")
    item.body[1] = "chassis"
    item.body[2] = "ground"
    item.location[1] = [b, 0, 0]
    item.location[2] = [b, 0.1, 0]
    item.gain = k
    item.units = "N"
    add_item!(item, the_system)

    the_system

end
