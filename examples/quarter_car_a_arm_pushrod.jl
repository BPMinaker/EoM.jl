function quarter_car_a_arm_pushrod(; u = 10, a = 1.2, cf = 40000, m = 400, r = 0.3, tw = 1.5, kt = 150000, ct = 100, g = 9.81)

    ## Copyright (C) 2017, Bruce Minaker
    ## full_car_a_arm_pushrod.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## full_car_a_arm_pushrod.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    the_system = mbd_system("Quarter Car A-Arm Pushrod")

    item = body("Chassis")
    item.mass = m
    item.moments_of_inertia = [0, 0, 0]
    item.products_of_inertia = [0, 0, 0]
    item.location = [0, 0, 0.3]
    add_item!(item, the_system)
    add_item!(weight(item, g), the_system)

    item = rigid_point("Chassis constraint")
    item.body[1] = "Chassis"
    item.body[2] = "ground"
    item.location = [0, 0, 0.3]
    item.forces = 2
    item.moments = 3
    item.axis = [0, 0, 1]
    add_item!(item, the_system)

    susp!(the_system, str = "LF ", front = true; a, tw, r, u)
    tire!(the_system, str = "LF ", front = true; a, tw, cf, kt, ct, u)

    # add sensors
    item = sensor("LF Chassis motion")
    item.body[1] = "Chassis"
    item.body[2] = "ground"
    item.location[1] = [a, tw / 2, r]
    item.location[2] = [a, tw / 2, r - 0.1]
    item.units = "m"
    add_item!(item, the_system)

    item = sensor("LF Suspension travel")
    item.body[1] = "Chassis"
    item.body[2] = "LF Wheel+hub"
    item.location[1] = [a, tw / 2, r]
    item.location[2] = [a, tw / 2, r - 0.1]
    item.units = "m"
    add_item!(item, the_system)

    item = sensor("LF Tire compression")
    item.body[1] = "LF Wheel+hub"
    item.body[2] = "ground"
    item.location[1] = [a, tw / 2, r]
    item.location[2] = [a, tw / 2, r - 0.1]
    item.actuator = "u_LF "
    item.units = "m"
    add_item!(item, the_system)



    #=
    item=actuator("L")
    item.body[1]="Chassis"
    item.body[2]="ground"
    item.location[1]=[0,0,0.5]
    item.location[2]=[0.1,0,0.5]
    item.twist=1
    item.gain=1000
    add_item!(item,the_system)

    item=sensor("ϕ")
    item.body[1]="Chassis"
    item.body[2]="ground"
    item.location[1]=[0,0,0.5]
    item.location[2]=[0.1,0,0.5]
    item.twist=1
    item.gain=180/pi
    add_item!(item,the_system)
    =#

    the_system

end ## Leave
