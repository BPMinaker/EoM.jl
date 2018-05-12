function syst_props(the_system)
## Copyright (C) 2017, Bruce Minaker
## syst_props.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## syst_props.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

bodydata="###### Body Data\nnum name mass rx ry rz ixx iyy izz ixy iyz ixz\n"
pointdata="###### Connection Data\nnum name rx ry rz ux uy uz\n"
#linedata="###### Connection Data\nnum name rx ry rz ux uy uz\n"
stiffnessdata="###### Connection Data\nnum name stiffness damping t_stiffness t_damping\n"


## Body data
idx=1
for item in the_system.bodys[1:end-1]
	bodydata*="{$idx} {$(item.name)} $(item.mass) $(item.location[1]) $(item.location[2]) $(item.location[3])"
	bodydata*=" $(item.moments_of_inertia[1]) $(item.moments_of_inertia[2])  $(item.moments_of_inertia[3])"
	bodydata*=" $(item.products_of_inertia[1]) $(item.products_of_inertia[2]) $(item.products_of_inertia[3])\n"
	idx+=1
end

## Connection data
idx=1
for item in the_system.rigid_points
	pointdata*="{$idx} {$(item.name)} $(item.location[1]) $(item.location[2]) $(item.location[3])"
	if(norm(item.axis)>0)
		pointdata*=" $(item.unit[1]) $(item.unit[2]) $(item.unit[3])"
	else
		pointdata*=" {} {} {}"
	end
	pointdata*="\n"
	idx+=1
end

idx2=1
for item in the_system.flex_points
	pointdata*="{$idx} {$(item.name)} $(item.location[1]) $(item.location[2]) $(item.location[3])"
	if(norm(item.axis)>0)
		pointdata*=" $(item.unit[1]) $(item.unit[2]) $(item.unit[3])"
	else
		pointdata*=" {} {} {}"
	end
	pointdata*="\n"
	stiffnessdata*="{$idx2} {$(item.name)} $(item.stiffness[1]) $(item.damping[1]) $(item.stiffness[2]) $(item.damping[2])\n"
	idx+=1
	idx2+=1
end

for item in the_system.nh_points
	pointdata*="{$idx} {$(item.name)} $(item.location[1]) $(item.location[2]) $(item.location[3])"
	if(norm(item.axis)>0)
		pointdata*=" $(item.unit[1]) $(item.unit[2]) $(item.unit[3])"
	else
		pointdata*=" {} {} {}"
	end
	pointdata*="\n"
	idx+=1
end

for item in the_system.springs
	pointdata*="{$idx} {$(item.name) } $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3]) {} {} {}\n"
	pointdata*="{} {} $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3]) {} {} {}\n"
	stiffnessdata*="{$idx2} {$(item.name)} $(item.stiffness) $(item.damping) {} {}\n"
	idx+=1
	idx2+=1
end

for item in the_system.links
	pointdata*="{$idx} {$(item.name)} $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3]) {} {} {}\n"
	pointdata*="{} {} $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3]) {} {} {}\n"
	idx+=1
end

for item in the_system.beams
	pointdata*="{$idx} {$(item.name)} $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3]) {} {} {}\n"
	pointdata*="{} {} $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3]) {} {} {}\n"
	stiffnessdata*="{$idx2} {$(item.name)} $(item.stiffness) {} {} {}\n"
	idx+=1
	idx2+=1
end

bodydata,pointdata,stiffnessdata

end  ## Leave








# for item in the_system.springs
# 	linedata*="{$idx} {$(item.name)}"
# 	linedata*=" $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3])"
# 	linedata*=" $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3])\n"
# 	stiffnessdata*="{$idx2} {$(item.name)} $(item.stiffness) $(item.damping) {} {}\n"
# 	idx+=1
# 	idx2+=1
# end
#
# for item in the_system.links
# 	linedata*="{$idx} {$(item.name)}"
# 	linedata*=" $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3])"
# 	linedata*=" $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3])\n"
# 	idx+=1
# end
#
# for item in the_system.beams
# 	linedata*="{$idx} {$(item.name)}"
# 	linedata*=" $(item.location[1][1]) $(item.location[1][2]) $(item.location[1][3])"
# 	linedata*=" $(item.location[2][1]) $(item.location[2][2]) $(item.location[2][3])\n"
# 	stiffnessdata*="{$idx2} {$(item.name)} $(item.stiffness) {} {} {}\n"
# 	idx+=1
# 	idx2+=1
# end
