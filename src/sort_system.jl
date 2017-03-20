function sort_system!(the_system,verb)
## Copyright (C) 2017, Bruce Minaker
## sort_system.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## sort_system.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Sort the system into a new structure

verb && println("Sorting system...")

## First, ground is added to the system, because it is not in the user-defined system
ground=body("ground")
push!(the_system.item,ground)  ## Ground body is added last (important!)

#println(fieldnames(the_system))
#setfield!(the_system,:bodys,the_system.item[broadcast(typeof,the_system.item).==body])

the_system.bodys=the_system.item[broadcast(typeof,the_system.item).==body]
the_system.links=the_system.item[broadcast(typeof,the_system.item).==link]
the_system.springs=the_system.item[broadcast(typeof,the_system.item).==spring]
the_system.rigid_points=the_system.item[broadcast(typeof,the_system.item).==rigid_point]
the_system.flex_points=the_system.item[broadcast(typeof,the_system.item).==flex_point]
the_system.nh_points=the_system.item[broadcast(typeof,the_system.item).==nh_point]
the_system.beams=the_system.item[broadcast(typeof,the_system.item).==beam]
the_system.loads=the_system.item[broadcast(typeof,the_system.item).==load]
the_system.sensors=the_system.item[broadcast(typeof,the_system.item).==sensor]
the_system.actuators=the_system.item[broadcast(typeof,the_system.item).==actuator]


names=broadcast(name,the_system.bodys)

find_bodynum!(the_system.links,names,false)
find_bodynum!(the_system.springs,names,false)
find_bodynum!(the_system.rigid_points,names,false)
find_bodynum!(the_system.flex_points,names,false)
find_bodynum!(the_system.nh_points,names,false)
find_bodynum!(the_system.beams,names,false)
find_bodynum!(the_system.sensors,names,false)
find_bodynum!(the_system.actuators,names,false)

find_bodyframenum!(the_system.loads,names,false)

names=broadcast(name,the_system.actuators)

find_actnum!(the_system.sensors,names,false)


locations=broadcast(location,the_system.bodys)


find_radius!(the_system.links,locations,false)
find_radius!(the_system.springs,locations,false)
find_radius!(the_system.rigid_points,locations,false)
find_radius!(the_system.flex_points,locations,false)
find_radius!(the_system.nh_points,locations,false)
find_radius!(the_system.beams,locations,false)
find_radius!(the_system.loads,locations,false)
find_radius!(the_system.sensors,locations,false)
find_radius!(the_system.actuators,locations,false)

item_init!(the_system.links,false)
item_init!(the_system.springs,false)
item_init!(the_system.rigid_points,false)
item_init!(the_system.flex_points,false)
item_init!(the_system.nh_points,false)
item_init!(the_system.beams,false)
item_init!(the_system.sensors,false)
item_init!(the_system.actuators,false)

#println(the_system.actuators[1].location)


 
verb && println("System sorted.")
end  ## Leave
