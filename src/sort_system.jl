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

## Fill in some extra info in each item
item_init!(the_system.item)

## Ground is added to the system, because it is not in the user-defined system
push!(the_system.item,body("ground"))  ## Ground body is added last (important!)

## Find the type of each item, and sort into named fields
for i in the_system.item
	type=string(typeof(i))*"s"
	type=replace(type,"EoM."=>"")
	loc=getproperty(the_system,Symbol(type))
	push!(loc,i)
end

## Find the body number from the name
names=name.(the_system.bodys)
find_bodynum!(the_system.item,names)
find_bodyframenum!(the_system.loads,names)

## Find the actuator number from the name
names=name.(the_system.actuators)
find_actnum!(the_system.sensors,names)

## Find the radius of each connector
locations=location.(the_system.bodys)
find_radius!(the_system.item,locations)

verbose && println("System sorted.")

end  ## Leave


#types=[:bodys,:loads,:links,:springs,:rigid_points,:flex_points,:nh_points,:beams,:sensors,:actuators]
#type=[body,load,link,spring,rigid_point,flex_point,nh_point,beam,sensor,actuator]
#for i=1:length(types)
#	setproperty!(the_system,types[i],the_system.item[typeof.(the_system.item).==type[i]])
#end

#for i=3:length(types)
#	find_bodynum!(getproperty(the_system,types[i]),names)
#end
# for i=2:length(types)
# 	find_radius!(getproperty(the_system,types[i]),locations)
# end
#for i=3:length(types)
#	item_init!(getproperty(the_system,types[i]))
#end
