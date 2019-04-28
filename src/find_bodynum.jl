function find_bodynum!(items,names,verb=false) ## Takes the key, i.e. springs and returns the key with new entries telling the attached body numbers -> reads the bodys which the items are attached to, and inserts the corresponding body numbers
## Copyright (C) 2017, Bruce Minaker
## find_bodynum.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## find_bodynum.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Find the body numbers of each connecting item
verb && println("Looking for connection info...")

for i in items
	for j=1:length(names)
		if i.body[1]==names[j]
			i.body_number[1]=j
		elseif i.body[2]==names[j]
			i.body_number[2]=j
		end
	end
	if i.body_number[1]*i.body_number[2]==0
		error("Item $(i.name) is attached to missing body!")
	end
end

end


function find_bodyframenum!(items,names,verb=false)

verb && println("Looking for connection info...")

for i in items
	for j=1:length(names)
		if i.body==names[j]
			i.body_number=j
		end
		if i.frame==names[j]
			i.frame_number=j
		end
	end
	if i.body_number==0
		error("Item $(i.name) is attached to a missing body!")
	end
	if i.frame_number==0
		error("Item $(i.name) is attached a missing frame!")
	end
end

end

function find_actnum!(items,names,verb=false)

verb && println("Looking for connection info...")

for i in items
	for j=1:length(names)
		if i.actuator==names[j]
			i.actuator_number=j
		end
	end
	if i.actuator!="ground" && i.actuator_number==0
		error("Item $(i.name) actuator not found!")
	end
end

end  ## Leave
