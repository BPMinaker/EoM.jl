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

mass_mtx=data.mass
stiff_mtx=data.stiffness+data.tangent_stiffness+data.load_stiffness  ## Sum total system stiffness
damp_mtx=data.damping+data.momentum
#symmetric_stiffness=issymmetric(stiff_mtx,1.e-3);  ## Check symmetry of stiffness matrix, if 'stiff_mtx' is symmetric to the tolerance 1.e-3, return the dimension, otherwise return zero

dim=size(data.constraint,2)
nin=size(data.input,2)
nout=size(data.output,1)

M=[eye(dim) zeros(dim,dim+nin); zeros(dim,dim) mass_mtx -data.input_rate; zeros(nin,2*dim+nin)]

KC=[data.velocity -eye(dim) zeros(dim,nin); stiff_mtx damp_mtx  -data.input; zeros(nin,2*dim) eye(nin)];

s=size(data.right_jacobian,1);  ## Compute size of J matrices

if(s>0)
	r_orth=nullspace([data.right_jacobian zeros(s,nin)])
	l_orth=nullspace([data.left_jacobian zeros(s,nin)])
else
	r_orth=eye(2*dim+nin)
	l_orth=r_orth
end

## Pre and post multiply by orthogonal complements, and then cast in standard form

data.E=l_orth'*M*r_orth
data.A=-l_orth'*KC*r_orth
data.B=l_orth'*[zeros(2*dim,nin); eye(nin)]
C=zeros(nout,2*dim+nin)

for i=1:nout
	if(column[i]==1) ## p
 			mask=[eye(dim) zeros(dim,dim+nin)]

	elseif(column[i]==2)  ## w
		mask=[zeros(dim,dim) eye(dim) zeros(dim,nin)]

	elseif(column[i]==3)  ## p dot
		mask=-KC[1:dim,:]

	elseif(column[i]==4)  ## w dot
		mask=-pinv(M[dim+1:2*dim,dim+1:2*dim])*KC(dim+1:2*dim,:)

	elseif(column[i]==5) ## p dot dot
			mask=[data.velocity^2 -data.velocity  zeros(dim,nin)] - pinv(M[dim+1:2*dim,dim+1:2*dim])*KC(dim+1:2*dim,:)
	else
		error("Matrix size error")
	end
	C[i,:]=data.output[i,:]'*mask  ## Note transpose here -- behaviour different than Matlab/Octave
end

data.C=C*r_orth
data.D=data.feedthrough  ## Add the user defined feed forward

# state_space=dss(A,B,C,D,E);
# phys=r_orth(1:dim,:);  ## Relate the physical coordinates to the minimal ones
#
verb && println("Okay, built equations of motion.")

end  ## Leave
