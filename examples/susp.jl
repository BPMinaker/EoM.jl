using LinearAlgebra

function susp!(the_system; a = 1.2, tw = 1.5, cs = 2000, ks = 60000, r = 0.3, u = 10.0, g = 9.81, str = "L ", front = true)
    ## Copyright (C) 2019, Bruce Minaker
    ## susp.jl is free software, you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation, either version 2, or (at your option)
    ## any later version.
    ##
    ## susp.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY, without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    velocity = [u, 0, 0]

    if front
        sgn = 1
    else
        sgn = -1
    end

    ####% LF Suspension bodys

    item = body(str * "Wheel+hub")
    item.mass = 10
    item.moments_of_inertia = [2, 4, 2]
    item.location = [a, tw / 2, r]
    item.velocity = velocity
    item.angular_velocity = [0, u / r, 0]
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    item = body(str * "Upright")
    item.mass = 5
    item.moments_of_inertia = [0.1, 0.1, 0.1]
    item.location = [a, tw / 2 - 0.1, r]
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    item = body(str * "Lower A-arm")
    item.mass = 5
    item.moments_of_inertia = [1, 1, 2]
    item.location = [a, tw / 2 - 0.3, r - 0.15]
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    item = body(str * "Upper A-arm")
    item.mass = 5
    item.moments_of_inertia = [1, 1, 2]
    item.location = [a, tw / 2 - 0.3, r + 0.1]
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    item = body(str * "Bell-crank")
    item.mass = 1
    item.moments_of_inertia = [0.05, 0.05, 0.05]
    item.location = [a - 0.05 * sgn, 0.3, 0.5]
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    upre = [a, tw / 2 - 0.5, r + 0.1]  ## upper push-rod end
    lpre = [a, tw / 2 - 0.2, r - 0.1]  ## lower push-rod end

    item = thin_rod(str * "Push-rod", [upre lpre], 1)
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    itre = [a - 0.25 * sgn, tw / 2 - 0.6, r - 0.04]  ## inner tie-rod end
    otre = [a - 0.07 * sgn, tw / 2 - 0.1, r]  ## outer tie-rod end

    item = thin_rod(str * "Tie-rod", [itre otre], 1)
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    aram = [a + 0.05 * sgn, 0.25, r + 0.05]
    aral = [a + 0.05 * sgn, 0.25, r + 0.2]

    item = thin_rod(str * "Anti-roll arm", [aram aral], 1)
    item.velocity = velocity
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    sue = [a - 0.5 * sgn, 0.25, r + 0.2]
    sle = [a - 0.1 * sgn, 0.25, r + 0.2]

    item = body(str * "Damper mount")  ## massless body
    item.location = sue - [0.05, 0, 0] * sgn
    add_item!(item, the_system)

    #### Springs

    item = flex_point(str * "Damper mount bushing")
    item.body[1] = str * "Damper mount"
    item.body[2] = "Chassis"
    item.stiffness = [10 * ks, 0]
    item.location = sue - [0.1, 0, 0] * sgn
    item.forces = 1
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = spring(str * "Suspension spring")
    item.location[1] = sue
    item.location[2] = sle
    item.body[1] = str * "Damper mount"
    item.body[2] = str * "Bell-crank"
    item.stiffness = ks
    item.damping = cs
    add_item!(item, the_system)


    #### LF Suspension constraints

    item = rigid_point(str * "Damper mount slider")
    item.body[1] = str * "Damper mount"
    item.body[2] = "Chassis"
    item.location = sue - [0.05, 0, 0] * sgn
    item.forces = 2
    item.moments = 3
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = rigid_point(str * "Wheel bearing")
    item.body[1] = str * "Wheel+hub"
    item.body[2] = str * "Upright"
    item.location = [a, tw / 2, r]
    item.forces = 3
    item.moments = 2
    item.axis = [0.0, 1.0, 0.0]
    add_item!(item, the_system)

    item = rigid_point(str * "Lower ball joint")
    item.body[1] = str * "Upright"
    item.body[2] = str * "Lower A-arm"
    item.location = [a, tw / 2 - 0.1, r - 0.15]
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Lower A-arm pivot, rear")
    item.body[1] = str * "Lower A-arm"
    item.body[2] = "Chassis"
    item.location = [a - 0.2 * sgn, 0.1, r - 0.15]
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Lower A-arm pivot, front")
    item.body[1] = str * "Lower A-arm"
    item.body[2] = "Chassis"
    item.location = [a + 0.2 * sgn, 0.1, r - 0.2]
    item.forces = 2
    item.moments = 0
    item.axis = [1.0, 0.0, 0.0]
    add_item!(item, the_system)

    item = rigid_point(str * "Bell-crank pivot")
    item.body[1] = str * "Bell-crank"
    item.body[2] = "Chassis"
    item.location = [a - 0.1 * sgn, 0.35, r + 0.1]
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 1] / norm([0, 1, 1])
    add_item!(item, the_system)

    item = rigid_point(str * "Upper A-arm pivot, front")
    item.body[1] = str * "Upper A-arm"
    item.body[2] = "Chassis"
    item.location = [a + 0.2 * sgn, 0.3, r + 0.05]
    item.forces = 2
    item.moments = 0
    item.axis = [1, 0, 0]
    add_item!(item, the_system)

    item = rigid_point(str * "Upper A-arm pivot, rear")
    item.body[1] = str * "Upper A-arm"
    item.body[2] = "Chassis"
    item.location = [a - 0.2 * sgn, 0.3, r + 0.05]
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Upper ball joint")
    item.body[1] = str * "Upper A-arm"
    item.body[2] = str * "Upright"
    item.location = [a, tw / 2 - 0.15, r + 0.15]
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Lower push-rod end")
    item.body[1] = str * "Lower A-arm"
    item.body[2] = str * "Push-rod"
    item.location = lpre
    item.forces = 3
    item.moments = 1
    item.axis = (upre - lpre) / norm(upre - lpre)
    add_item!(item, the_system)

    item = rigid_point(str * "Upper push-rod end")
    item.body[1] = str * "Bell-crank"
    item.body[2] = str * "Push-rod"
    item.location = upre
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Inner tie-rod end")
    item.body[1] = "Chassis"
    item.body[2] = str * "Tie-rod"
    item.location = itre
    item.forces = 3
    item.moments = 0
    add_item!(item, the_system)

    item = rigid_point(str * "Outer tie-rod end")
    item.body[1] = str * "Upright"
    item.body[2] = str * "Tie-rod"
    item.location = otre
    item.forces = 3
    item.moments = 1
    item.axis = (otre - itre) / norm(otre - itre)
    add_item!(item, the_system)

    item = rigid_point(str * "Anti-roll mount")
    item.body[1] = str * "Anti-roll arm"
    item.body[2] = "Chassis"
    item.location = aram
    item.forces = 3
    item.moments = 2
    item.axis = [0, 1, 0]
    add_item!(item, the_system)

    item = link(str * "Drop link")
    item.body[1] = str * "Bell-crank"
    item.body[2] = str * "Anti-roll arm"
    item.location[1] = [a - 0.1 * sgn, 0.25, r + 0.2]
    item.location[2] = [a + 0.05 * sgn, 0.25, r + 0.2]
    add_item!(item, the_system)

end ## Leave
