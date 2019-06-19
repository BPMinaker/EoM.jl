function load_defln(the_system,dir_output)
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

preload_f=open(joinpath(dir_output,"preload.out"),"w")
println(preload_f,"###### Preload\nnum name type fx fy fz fxyz")

defln_f=open(joinpath(dir_output,"defln.out"),"w")
println(defln_f,"###### Deflection\nnum name type x y z")

idx=1
for item in [the_system.rigid_points;the_system.flex_points]
	pload=[item.b_mtx[1];item.b_mtx[2]]'*item.preload
	frc=pload[1:3]
	mmt=pload[4:6]
	print(preload_f,"{",idx,"} {",item.name,"} ")
	println(preload_f,"force ",frc[1]," ",frc[2]," ",frc[3]," ",norm(frc))
	print(preload_f,"{} {} ")
	println(preload_f,"moment ",mmt[1]," ",mmt[2]," ",mmt[3]," ",norm(mmt))
	idx+=1
end

for item in [the_system.springs;the_system.links]
	pload=[item.b_mtx[1];item.b_mtx[2]]'*item.preload
	frc=pload[1:3]
	mmt=pload[4:6]
	print(preload_f,"{",idx,"} {",item.name,"} ")
	if item.twist==0
		println(preload_f,"force ",frc[1]," ",frc[2]," ",frc[3]," ",item.preload)
	else
		println(preload_f,"moment ",mmt[1]," ",mmt[2]," ",mmt[3]," ",item.preload)
	end
	idx+=1
end

for item in the_system.beams
	l=item.length
	D=[0 0 0 -1 0 0 0 1; 2/l 0 0 1 -2/l 0 0 1; 0 0 -1 0 0 0 1 0; 0 2/l -1 0 0 -2/l -1 0]  ## Relate the beam stiffness matrix to the deflection of the ends (diagonalize the typical beam stiffness matrix!)
	temp=diagm(0=>(D'*item.preload))*[item.b_mtx[1];item.b_mtx[2];item.b_mtx[1];item.b_mtx[2]]
	v1=temp[1,1:3]+temp[2,1:3]
	m1=temp[3,4:6]+temp[4,4:6]
	v2=temp[5,1:3]+temp[6,1:3]
	m2=temp[7,4:6]+temp[8,4:6]
	println(preload_f,"{",idx,"} {",item.name,"} shear ",v1[1]," ",v1[2]," ",v1[3]," ",norm(v1))
	println(preload_f,"{} {} moment ",m1[1]," ",m1[2]," ",m1[3]," ",norm(m1))
	println(preload_f,"{} {} shear ",v2[1]," ",v2[2]," ",v2[3]," ",norm(v2))
	println(preload_f,"{} {} moment ",m2[1]," ",m2[2]," ",m2[3]," ",norm(m2))
	idx+=1
end

idx=1
for item in the_system.bodys[1:end-1]
	println(defln_f,"{",idx,"} {",item.name,"} translation ",item.deflection[1]," ",item.deflection[2]," ",item.deflection[3])
	println(defln_f,"{ } { } rotation ",item.angular_deflection[1]," ",item.angular_deflection[2]," ",item.angular_deflection[3])
	idx+=1
end

close(preload_f)
close(defln_f)

end ## Leave
