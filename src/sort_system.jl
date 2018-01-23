function sort_system!(the_system,verbose=false)
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

verbose && println("Sorting system...")

## First, ground is added to the system, because it is not in the user-defined system
ground=body("ground")
push!(the_system.item,ground)  ## Ground body is added last (important!)

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

find_bodynum!(the_system.links,names)
find_bodynum!(the_system.springs,names)
find_bodynum!(the_system.rigid_points,names)
find_bodynum!(the_system.flex_points,names)
find_bodynum!(the_system.nh_points,names)
find_bodynum!(the_system.beams,names)
find_bodynum!(the_system.sensors,names)
find_bodynum!(the_system.actuators,names)

find_bodyframenum!(the_system.loads,names)

names=broadcast(name,the_system.actuators)

find_actnum!(the_system.sensors,names)

locations=broadcast(location,the_system.bodys)

find_radius!(the_system.links,locations)
find_radius!(the_system.springs,locations)
find_radius!(the_system.rigid_points,locations)
find_radius!(the_system.flex_points,locations)
find_radius!(the_system.nh_points,locations)
find_radius!(the_system.beams,locations)
find_radius!(the_system.loads,locations)
find_radius!(the_system.sensors,locations)
find_radius!(the_system.actuators,locations)

item_init!(the_system.links)
item_init!(the_system.springs)
item_init!(the_system.rigid_points)
item_init!(the_system.flex_points)
item_init!(the_system.nh_points)
item_init!(the_system.beams)
item_init!(the_system.sensors)
item_init!(the_system.actuators)

verbose && println("System sorted.")
end  ## Leave
