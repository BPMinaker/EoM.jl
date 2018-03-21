function load_defln(the_system)
## Copyright (C) 2017, Bruce Minaker
## load_defln.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## load_defln.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

preload="###### Preload\nnum name type fx fy fz fxyz\n"
defln="###### Deflection\nnum name type x y z\n"

idx=1

for item in [the_system.rigid_points;the_system.flex_points]
	pload=[item.b_mtx[1];item.b_mtx[2]]'*item.preload
	frc=pload[1:3]
	mmt=pload[4:6]
	preload*="{$idx} {$(item.name)}"
	if(~(norm(frc)==0 && norm(mmt)>0))
		preload*=" force "*@sprintf("%.12e ",frc[1])*@sprintf("%.12e ",frc[2])*@sprintf("%.12e ",frc[3])*@sprintf("%.12e ",norm(frc))*"\n"
	end
	if(norm(mmt)>0)
		preload*="{} {} moment "*@sprintf("%.12e ",mmt[1])*@sprintf("%.12e ",mmt[2])*@sprintf("%.12e ",mmt[3])*@sprintf("%.12e ",norm(mmt))*"\n"
	end
	idx+=1
end

for item in [the_system.springs;the_system.links]
	pload=[item.b_mtx[1];item.b_mtx[2]]'*item.preload
	frc=pload[1:3]
	mmt=pload[4:6]
	preload*="{$idx} {$(item.name)}"
	if(item.twist==0)
		preload*=" force "*@sprintf("%.12e ",frc[1])*@sprintf("%.12e ",frc[2])*@sprintf("%.12e ",frc[3])*@sprintf("%.12e ",item.preload)*"\n"
	else
		preload*=" moment "*@sprintf("%.12e ",mmt[1])*@sprintf("%.12e ",mmt[2])*@sprintf("%.12e ",mmt[3])*@sprintf("%.12e ",item.preload)*"\n"
	end
	idx+=1
end

for item in the_system.beams
	l=item.length
	D=[0 0 0 -1 0 0 0 1; 2/l 0 0 1 -2/l 0 0 1; 0 0 -1 0 0 0 1 0; 0 2/l -1 0 0 -2/l -1 0]  ## Relate the beam stiffness matrix to the deflection of the ends (diagonalize the typical beam stiffness matrix!)
	temp=diagm((D'*item.preload))*[item.b_mtx[1];item.b_mtx[2];item.b_mtx[1];item.b_mtx[2]]
	v1=temp[1,1:3]+temp[2,1:3]
	m1=temp[3,4:6]+temp[4,4:6]
	v2=temp[5,1:3]+temp[6,1:3]
	m2=temp[7,4:6]+temp[8,4:6]
	preload*="{$idx} {$(item.name)} shear "*@sprintf("%.12e ",v1[1])*@sprintf("%.12e ",v1[2])*@sprintf("%.12e ",v1[3])*@sprintf("%.12e ",norm(v1))*"\n"
	preload*="{} {} moment "*@sprintf("%.12e ",m1[1])*@sprintf("%.12e ",m1[2])*@sprintf("%.12e ",m1[3])*@sprintf("%.12e ",norm(m1))*"\n"
	preload*="{} {} shear "*@sprintf("%.12e ",v2[1])*@sprintf("%.12e ",v2[2])*@sprintf("%.12e ",v2[3])*@sprintf("%.12e ",norm(v2))*"\n"
	preload*="{} {} moment "*@sprintf("%.12e ",m2[1])*@sprintf("%.12e ",m2[2])*@sprintf("%.12e ",m2[3])*@sprintf("%.12e ",norm(m2))*"\n"
	idx+=1
end

idx=1
for item in the_system.bodys[1:end-1]
	defln*="{$idx} {$(item.name)} translation "*@sprintf("%.12e ",item.deflection[1])*@sprintf("%.12e ",item.deflection[2])*@sprintf("%.12e ",item.deflection[3])*"\n{ } { } rotation "*@sprintf("%.12e ",item.angular_deflection[1])*@sprintf("%.12e ",item.angular_deflection[2])*@sprintf("%.12e ",item.angular_deflection[3])*"\n"
	idx+=1
end

preload,defln

end ## Leave
