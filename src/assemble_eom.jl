function assemble_eom!(data,column,verb)
## Copyright (C) 2017, Bruce Minaker
## assemble_eom.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## assemble_eom.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Build angular stiffness matrix from motion of items with preload, both rigid and flexible
verb && println("Building equations of motion...")

mass_mtx=data.mass+data.inertia
stiff_mtx=data.stiffness+data.tangent_stiffness+data.load_stiffness  ## Sum total system stiffness
damp_mtx=data.damping+data.momentum
#symmetric_stiffness=issymmetric(stiff_mtx,1.e-3);  ## Check symmetry of stiffness matrix, if 'stiff_mtx' is symmetric to the tolerance 1.e-3, return the dimension, otherwise return zero

dim=size(data.constraint,2)
nin=size(data.input,2)
nout=size(data.output,1)

data.M=[speye(dim) spzeros(dim,dim+nin); spzeros(dim,dim) mass_mtx -data.input_rate; spzeros(nin,2*dim+nin)]

data.KC=[data.velocity -speye(dim) spzeros(dim,nin); stiff_mtx damp_mtx  -data.input; spzeros(nin,2*dim) eye(nin)];

s=size(data.right_jacobian,1)  ## Compute size of J matrices

if(s>0)
	r_orth=nullspace(full([data.right_jacobian zeros(s,nin)]))
	l_orth=nullspace(full([data.left_jacobian zeros(s,nin)]))
else
	r_orth=speye(2*dim+nin)
	l_orth=r_orth
end


ss_eqns=ss_data()  ## Create empty state space holder

## Pre and post multiply by orthogonal complements, and then cast in standard form
ss_eqns.E=l_orth'*data.M*r_orth
ss_eqns.A=-l_orth'*data.KC*r_orth
ss_eqns.B=l_orth'*[zeros(2*dim,nin); eye(nin)]
C=zeros(nout,2*dim+nin)

for i=1:nout
	if(column[i]==1) ## p
 			mask=[speye(dim) spzeros(dim,dim+nin)]

	elseif(column[i]==2)  ## w
		mask=[spzeros(dim,dim) speye(dim) spzeros(dim,nin)]

	elseif(column[i]==3)  ## p dot
		mask=-data.KC[1:dim,:]

	elseif(column[i]==4)  ## w dot
		mask=-pinv(full(data.M[dim+1:2*dim,dim+1:2*dim]))*data.KC(dim+1:2*dim,:)

	elseif(column[i]==5) ## p dot dot
			mask=[data.velocity^2 -data.velocity  zeros(dim,nin)] - pinv(full(data.M[dim+1:2*dim,dim+1:2*dim]))*data.KC[dim+1:2*dim,:]
	else
		error("Matrix size error")
	end

	C[i,:]=data.output[i,:]'*mask  ## Note transpose here -- behaviour different than Matlab/Octave
end

ss_eqns.C=C*r_orth
ss_eqns.D=data.feedthrough  ## Add the user defined feed forward
ss_eqns.phys=r_orth[1:dim,:]
verb && println("Okay, built equations of motion.")

ss_eqns

end  ## Leave
