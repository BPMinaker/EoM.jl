function item_init!(items,verb)
## Copyright (C) 2017, Bruce Minaker
## item_init.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## item_init.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verb && println("Initializing...")

for i in items

	## If the item has one node
	if(typeof(i)==rigid_point||typeof(i)==flex_point||typeof(i)==nh_point) 
		if(norm(i.axis)>0)
			i.unit=i.axis/norm(i.axis)  ## Normalize any non-unit axis vectors
		end
		if(norm(i.rolling_axis)>0)
			i.rolling_unit=i.rolling_axis/norm(i.rolling_axis)
		end
	## If the item has two nodes
	elseif(typeof(i)==link||typeof(i)==spring||typeof(i)==beam||typeof(i)==sensor||typeof(i)==actuator)
		temp=i.location[:,2]-i.location[:,1]  ## Tempvec = vector from location1 to location2
		i.length=norm(temp)  ## New entry 'length' is the magnitude of the vector from location1 to location2
		if(i.length>0)
			i.unit=temp/i.length  ## New entry 'unit' is the unit vector from location1 to location2
		end
		if(typeof(i)!=beam)
			i.forces=Int(~i.twist)
			i.moments=Int(i.twist)
		end
	## If the item has three nodes
	
	else
		println("Three nodes")
		## find the normal to the triangle, but use Newell method rather than null()
		#ux=det([1 1 1;in(i).location(2:3,:)]);
		#uy=det([in(i).location(1,:);1 1 1;in(i).location(3,:)]);
		#uz=det([in(i).location(1:2,:);1 1 1]);
		#in(i).unit=[ux;uy;uz]/norm([ux;uy;uz]);
	end
	
	i.nu=nullspace(i.unit')  ## Find directions perp to beam axis
	if(~(round(i.unit'*cross(i.nu[:,1],i.nu[:,2]))==1))  ## Make sure it's right handed
		i.nu=circshift(i.nu,[0,1]);
	end

	##i.r=[i.nu i.unit];  ## Build the rotation matrix
	## Find the locations in the new coordinate system, z is the same for all points in planar element
	##i.local=i.r'*i.location
end


for i in items

	a=i.unit  ## Axis of constraint
	b=i.nu  ## Plane of constraint

	if(i.forces==3) ## For 3 forces, i.e. ball joint
		i.b_mtx[1]=[eye(3) zeros(3,3)] ## 
	elseif(i.forces==2) ## For 2 forces, i.e. cylindrical or pin joint
		i.b_mtx[1]=[b' zeros(2,3)]
	elseif(i.forces==1) ## For 1 force, i.e. planar
		i.b_mtx[1]=[a' 0 0 0]
	elseif(i.forces==0) ## For 0 forces
		i.b_mtx[1]=zeros(0,6)
	else
		error("Error.  Item is defined incorrectly.")
	end

	if(i.moments==3) ## For 3 moments, i.e. no rotational degrees of freedom
		i.b_mtx[2]=[zeros(3,3) eye(3)]
	elseif(i.moments==2) ## For 2 moments, i.e. 1 rotational degree of freedom, i.e. Cylindrical joint
		i.b_mtx[2]=[zeros(2,3) b']
	elseif(i.moments==1) ## For 1 moment, i.e. 2 rotational degrees of freedom, i.e. U-joint
		i.b_mtx[2]=[0 0 0 a']
	elseif(i.moments==0) ## For 0 moments, i.e. sherical joint
		i.b_mtx[2]=zeros(0,6)
	else
		error("Error.  Item is defined incorrectly.")
	end
end

# if(ismember(type,{'triangle_3s','triangle_5s'}))
# 	for i=1:length(in)
# 		in(i).mod_mtx=in(i).modulus/(1-in(i).psn_ratio^2)*[1 in(i).psn_ratio 0; in(i).psn_ratio 1 0; 0 0 0.5-in(i).psn_ratio/2];
# 	end
# end
# 
# if(ismember(type,{'wings','surfs'}))
# 	for i=1:length(in)
# 		if(in(i).area==0)
# 			in(i).area=in(i).span*in(i).chord;
# 		end
# 		in(i).qs=in(i).area*0.5*in(i).density*(in(i).airspeed)^2;
# 	end
# end

end ## Leave
