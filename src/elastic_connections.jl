function elastic_connections!(the_system,data,verb)
## Copyright (C) 2017, Bruce Minaker
## elastic_connections.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## elastic_connections.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Check condition of deflection matrix
verb && println("Checking flexible items...")

n=length(the_system.bodys)

## The form of the deflection matrix depends on the type of elastic item,
defln_mtx=[point_line_jacobian(the_system.springs,n);
point_line_jacobian(the_system.flex_points,n);
line_bend_jacobian(the_system.beams,n)]

s=size(defln_mtx,1)  ## s=the number of rows in the deflection matrix
if s>0  ## If the deflection matrix has more than zero rows (i.e. there are elastic items in the system)
	rk=rank(Matrix(defln_mtx)) ## rk=the rank (the number of linearly independent rows or columns) of the deflection matrix
	if rk==s ## If the rank equals the number of rows, the flexible connectors are statically determinate
		verb && println("Flexible connectors are statically determinate. Good.")  ## Give success message
	else
		verb && println("Warning: the flexible connectors are indeterminate.")  ## Give warning
	end

	## Gather all stiffness and damping coefficients into a vector
	spring_stiff=broadcast(stiffness,the_system.springs)
	spring_dmpng=broadcast(damping,the_system.springs)
	spring_inertia=broadcast(inertance,the_system.springs)
	preload_vec=broadcast(preload,the_system.springs)

	## Find the springs where the preload is given
	fnd=findall(.~broadcast(isnan,preload_vec))

	## Record their stiffnesses
	subset_spring_stiff=spring_stiff[fnd]
	preload_vec=preload_vec[fnd]  ## Throw away NaNs

	slct_mtx=zeros(length(the_system.springs),s)
	for i in fnd
		slct_mtx[i,i]=1
	end
	slct_mtx=slct_mtx[fnd,:]  ## Throw away zero rows

	t=sum(broadcast(num_fm,the_system.flex_points))
	flex_point_stiff=spzeros(t,t)
	flex_point_dmpng=spzeros(t,t)
	flex_point_inertia=spzeros(t,t)

	idx=1
	for i in the_system.flex_points  ## For each elastic point item

		idxe=idx+i.forces+i.moments-1
		flex_point_stiff[idx:idxe,idx:idxe]=sparse(i.s_mtx)
		flex_point_dmpng[idx:idxe,idx:idxe]=sparse(i.d_mtx)
		idx=idxe+1
	end

	## Relate the beam stiffness matrix to the deflection of the ends
	idx=1
	nb=8*length(the_system.beams)
	beam_stiff=spzeros(nb,nb)  ## Creates empty matrix for the beam stiffnesses
	beam_damping=spzeros(nb,nb)
	beam_inertia=spzeros(nb,nb)  ## Creates empty atrix for the beam inertia
	for i in the_system.beams
		l=i.length
		D=[0 0 0 -1 0 0 0 1; 2/l 0 0 1 -2/l 0 0 1; 0 0 -1 0 0 0 1 0; 0 2/l -1 0 0 -2/l -1 0]
		beam_stiff[8*idx.+(-7:0),8*idx.+(-7:0)]=i.stiffness/l*(D'*spdiagm(0=>[1,3,1,3])*D)
		E=[6 0 0 l 6 0 0 -l; 8 0 0 l -8 0 0 l; 0 6 l 0 0 6 -l 0; 0 8 -l 0 0 -8 -l 0]
		beam_inertia[8*idx.+(-7:0),8*idx.+(-7:0)]=i.mpul*l/432*(E'*spdiagm(0=>[111/37,1,111/37,1])*E)
		idx+=1

println(beam_stiff)
println(beam_inertia)

	end

	## Converts stiffness row vector into diagonal matrix -> a column for each elastic item
	stiff=blockdiag(spdiagm(0=>spring_stiff),flex_point_stiff,beam_stiff)

	## Convert damping row vector into diagonal matrix  -> a column for each elastic item
 	dmpng=blockdiag(spdiagm(0=>spring_dmpng),flex_point_dmpng,beam_damping)
 	#zeros(1,3*the_system.ntriangle_3s) zeros(1,5*the_system.ntriangle_5s) ])

	## Compute the diagonal inertia values, mostly zero except the inertance of the springs
#	inertia=zero(stiff)
#	inertia[1:length(the_system.springs),1:length(the_system.springs)]=spdiagm(0=>spring_inertia)

	inertia=blockdiag(spdiagm(0=>spring_inertia),flex_point_inertia,beam_inertia)
	#	zeros(1,3*the_system.ntriangle_3s) zeros(1,5*the_system.ntriangle_5s)]), ...

	## Use the deflection matrices to determine the stiffness matrix that results from the deflection of the elastic items -> Combines delfn_mtx (row for each elastic item, six columns for each body) with 'stiff' (row, column for each elastic constraint) to give proper stiffness matrix
	stiff_mtx=defln_mtx'*stiff*defln_mtx
	dmpng_mtx=defln_mtx'*dmpng*defln_mtx
	inertia_mtx=defln_mtx'*inertia*defln_mtx

	println(stiff_mtx)
	println(inertia_mtx)

else
	verb && println("No flexible connectors.")  ## If there are no springs or flex point items, define empty matrices

	stiff_mtx=zeros(6*(n-1),6*(n-1))
	dmpng_mtx=zeros(6*(n-1),6*(n-1))
	inertia_mtx=zeros(6*(n-1),6*(n-1))

	slct_mtx=zeros(0,0)
	preload_vec=zeros(0)
	stiff=zeros(0,0)
	subset_spring_stiff=zeros(0)

end

data.stiffness=stiff_mtx
data.damping=dmpng_mtx
data.inertia=inertia_mtx
data.deflection=defln_mtx
data.selection=slct_mtx
data.preload=preload_vec
data.spring_stiffness=diag(stiff)
data.subset_spring_stiffness=subset_spring_stiff

end  ## Leave


# #	if(the_system.ntriangle_3s>0)
# #        stiff=blkdiag(stiff,the_system.triangle_3s.mod_mtx);
# #	end
#
# # 	T=0.5*eye(3)+(1/6)*ones(3);  ## Using a 3 point (2/3,1/6,1/6) integration, find integration points
# # 	for i=1:the_system.ntriangle_5s
# # 		gp=the_system.triangle_5s(i).local*T;
# # 		D=zeros(5);
# # 		B=zeros(3,5,3);
# # 		for j=1:3
# # 			## Evaluate B at each integration point
# # 			B(:,:,j)=[1 gp(2,j) 0 0 0; 0 0 1 gp(1,j) 0; 0 -gp(1,j) 0 -gp(2,j) 1];
# # 			D=D+B(:,:,j)'*the_system.triangle_5s(i).mod_mtx*B(:,:,j);
# # 		end
# # 		D=D/3;
# # 		stiff=blkdiag(stiff,D);
# # 	end

#		flex_point_stiff[idx:idx+i.forces-1,idx:idx+i.forces-1]+=i.stiffness[1]*sparse(1.0I,i.moments,i.moments)
#		flex_point_dmpng[idx:idx+i.forces-1,idx:idx+i.forces-1]+=i.damping[1]*sparse(1.0I,i.forces,i.forces)
#		idx+=i.forces

#		flex_point_stiff[idx:idx+i.moments-1,idx:idx+i.moments-1]+=i.stiffness[2]*sparse(1.0I,i.moments,i.moments)
#		flex_point_dmpng[idx:idx+i.moments-1,idx:idx+i.moments-1]+=i.damping[2]*sparse(1.0I,i.moments,i.moments)
#		idx+=i.moments
