function find_radius!(items,locations,verb)  ## Takes the key, i.e. springs and returns the key with new entries telling the attachement radii
## Copyright (C) 2017, Bruce Minaker
## find_radius.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## find_radius.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Find the distance from each location to the associated body centre of mass

verb && println("Looking for location info...")

for i in items
	if(typeof(i)==link||typeof(i)==spring||typeof(i)==beam||typeof(i)==sensor||typeof(i)==actuator)
		i.radius[:,1]=i.location[:,1]-locations[i.body_number[1]]
		i.radius[:,2]=i.location[:,2]-locations[i.body_number[2]]
	elseif(typeof(i)==rigid_point||typeof(i)==flex_point||typeof(i)==nh_point) 
		i.radius[:,1]=i.location-locations[i.body_number[1]]
		i.radius[:,2]=i.location-locations[i.body_number[2]]
	elseif(typeof(i)==load)
		i.radius=i.location-locations[i.body_number]
	else
		error("Unknown type.")
	end
end

end ## Leave
