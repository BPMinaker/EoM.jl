function elastic_connections(the_system,verb)
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
if(s>0)  ## If the deflection matrix has more than zero rows (i.e. there are elastic items in the system)
	rk=rank(defln_mtx) ## rk=the rank (the number of linearly independent rows or columns) of the deflection matrix
	if(rk==s) ## If the rank equals the number of rows, the flexible connectors are statically determinate
		verb && println("Flexible connectors are statically determinate. Good.")  ## Give success message
	else
		verb && println("Warning: the flexible connectors are indeterminate.")  ## Give warning
	end

	## Gather all stiffness and damping coefficients into a vector
	spring_stiff=broadcast(stiffness,the_system.springs)
	spring_dmpng=broadcast(damping,the_system.springs)
	spring_inertia=broadcast(eq_mass,the_system.springs)
	preload_vec=broadcast(preload,the_system.springs)

	## Find the springs where the preload is given
	fnd=find(~broadcast(isnan,preload_vec))

	## Record their stiffnesses
	subset_spring_stiff=spring_stiff[fnd]
	preload_vec=preload_vec[fnd]  ## Throw away NaNs

	slct_mtx=zeros(length(the_system.springs),s)
	for i in fnd
		slct_mtx[i,i]=1
	end
	slct_mtx=slct_mtx[fnd,:]  ## Throw away zero rows


	t=sum(broadcast(num_fm,the_system.flex_points))
	flex_point_stiff=zeros(t)
	flex_point_dmpng=zeros(t)

	idx=1
	for i in the_system.flex_points  ## For each elastic point item
		flex_point_stiff[idx:idx+i.forces-1]=i.stiffness[1]
		flex_point_dmpng[idx:idx+i.forces-1]=i.damping[1]
		idx+=i.forces

		flex_point_stiff[idx:idx+i.moments-1]=i.stiffness[2]
		flex_point_dmpng[idx:idx+i.moments-1]=i.damping[2]
		idx+=i.moments
	end

	idx=1
	beam_stiff=zeros(4*length(the_system.beams))  ## Creates empty vector for the beam stiffnesses
	for i in the_system.beams
		beam_stiff[4*idx-3:4*idx]=[i.stiffness 3*i.stiffness i.stiffness 3*i.stiffness]  ## Creates a row vector of the beam stiffnesses, necessary to rebuild beam stiffness matrix from diagonalization
		idx+=1
	end

	## Converts stiffness row vector into diagonal matrix -> a column for each elastic item
	stiff=[spring_stiff;flex_point_stiff;beam_stiff]

	## Convert damping row vector into diagonal matrix  -> a column for each elastic item
 	dmpng=[spring_dmpng;flex_point_dmpng;zeros(beam_stiff)]
 	#zeros(1,3*the_system.ntriangle_3s) zeros(1,5*the_system.ntriangle_5s) ])

	## Compute the diagonal inertia values, mostly zero except the inertance of the springs
	inertia=zeros(dmpng)
	inertia[1:length(the_system.springs)]=spring_inertia
	#inertia=blkdiag(diag(spring_inertia,zeros(size(flex_point_stiff)),zeros(size(beam_stiff))))
	#	zeros(1,3*the_system.ntriangle_3s) ...
	#	zeros(1,5*the_system.ntriangle_5s)]), ...
	#	wing_inertia);


	## Build stiffness matrix
	stiff_mtx=defln_mtx'*diagm(stiff)*defln_mtx  ## Use the deflection matrices to determine the stiffness matrix that results from the deflection of the elastic items -> Combines delfn_mtx (row for each elastic item, six columns for each body) with 'stiff' (row, column for each elastic constraint) to give proper stiffness matrix
 	dmpng_mtx=defln_mtx'*diagm(dmpng)*defln_mtx  ## ...likewise for damping
 	inertia_mtx=defln_mtx'*diagm(inertia)*defln_mtx  ## ...likewise for inertia

else
	verb && println("No flexible connectors.")  ## If there are no springs or flex point items, define empty matrices

	stiff_mtx=zeros(6*(n-1),6*(n-1))
	dmpng_mtx=zeros(6*(n-1),6*(n-1))
	inertia_mtx=zeros(6*(n-1),6*(n-1))

	slct_mtx=Array{Float64}(0,0)
	preload_vec=Array{Float64}(0,0)
	spring_stiffness=Vector{Float64}(0)
	subset_spring_stiffness=Vector{Float64}(0)

end

stiff_mtx,dmpng_mtx,inertia_mtx,defln_mtx,slct_mtx,preload_vec,stiff,subset_spring_stiff

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

# 	## Now deal with wings
# # 	wing_inertia=[];
# # 	for i=1:the_system.nwings
# # 		stiff=blkdiag(stiff,zeros(6,6));  ## Wing has no stiffness, but many damping terms
# # 		wing=the_system.wings(i);
# # 		temp=zeros(6);
# # 		temp(1,1)=wing.cxu;
# # 		temp(1,3)=wing.cxw;
# # 		temp(1,5)=wing.cxq*wing.chord/2;
# # 		temp(2,2)=wing.cyv;
# # 		temp(2,4)=wing.cyp*wing.span/2;
# # 		temp(2,6)=wing.cyr*wing.span/2;
# # 		temp(3,1)=wing.czu;
# # 		temp(3,3)=wing.czw;
# # 		temp(3,5)=wing.czq*wing.chord/2;
# # 		temp(4,2)=wing.clv*wing.span;
# # 		temp(4,4)=wing.clp*wing.span^2/2;
# # 		temp(4,6)=wing.clr*wing.span^2/2;
# # 		temp(5,1)=wing.cmu*wing.chord;
# # 		temp(5,3)=wing.cmw*wing.chord;
# # 		temp(5,5)=wing.cmq*wing.chord^2/2;
# # 		temp(6,2)=wing.cnv*wing.span;
# # 		temp(6,4)=wing.cnp*wing.span^2/2;
# # 		temp(6,6)=wing.cnr*wing.span^2/2;
# #
# # 		dmpng=blkdiag(dmpng,-wing.qs/wing.airspeed*temp);
# #
# # 		temp=zeros(6);  ## Wing has effective inertia terms, actual mass and inertia included elsewhere
# # 		temp(1,1)=wing.a_mass(1);
# # 		temp(2,2)=wing.a_mass(2);
# # 		temp(3,3)=wing.a_mass(3);
# #
# # 		temp(1,2)=wing.a_mass_products(1); % xy
# # 		temp(2,1)=wing.a_mass_products(1);
# # 		temp(2,3)=wing.a_mass_products(2); % yz
# # 		temp(3,2)=wing.a_mass_products(2);
# # 		temp(3,1)=wing.a_mass_products(3); % zx
# # 		temp(1,3)=wing.a_mass_products(3);
# #
# # 		temp(4,4)=wing.a_momentsofinertia(1);
# # 		temp(5,5)=wing.a_momentsofinertia(2);
# # 		temp(6,6)=wing.a_momentsofinertia(3);
# #
# # 		temp(4,5)=wing.a_productsofinertia(1);
# # 		temp(5,4)=wing.a_productsofinertia(1);
# # 		temp(5,6)=wing.a_productsofinertia(2);
# # 		temp(6,5)=wing.a_productsofinertia(2);
# # 		temp(4,6)=wing.a_productsofinertia(3);
# # 		temp(6,4)=wing.a_productsofinertia(3);
# #
# # 		wing_inertia=blkdiag(wing_inertia,temp);
# # 	end
