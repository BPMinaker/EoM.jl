function preload!(data,verb)
## Copyright (C) 2017, Bruce Minaker
## preload.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## preload.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------
## Use the Jacobian and deflection matrices to determine the forces of constraint and the preload reactions in the elastic items.  The assumption of equilibrium is necessary.

verb && println("Checking whether the system is determinate...")

p=length(data.preload)  ## p=the number of preloads known
q,r=size(data.constraint) ## q=the number of rows in the constraint matrix

# [J' H']{lam}={f}      rigid constraint force plus elastic force equals total applied force
# [0  S]{f}    {fp}     subset of the elastic preloads are known

test_mtx=[data.constraint' data.deflection'; spzeros(p,q) data.selection]
s=size(test_mtx,2)

# [ 0    J     0 ]{lam}  {0}    defln satisfies constraints
# [ J'   K  H'S'P]{x} ={-f}   forces sum to zero
# [ 0   PSH    P ]{d} {fp}   some of the elastic preloads are known

ind_test_mtx=[spzeros(q,q) data.constraint spzeros(q,p); data.constraint' data.stiffness data.deflection'*data.selection'*spdiagm(data.subset_spring_stiffness); spzeros(p,q) spdiagm(data.subset_spring_stiffness)*data.selection*data.deflection spdiagm(data.subset_spring_stiffness)]
t=size(ind_test_mtx,1)

sumf=0
lambda=zeros(0)
static=zeros(0)

if(rank(full(test_mtx))==s)
	if(verb)
		println("Statically determinate system.  Good.")
		println("Finding all forces of constraint and flexible item preloads...")
	end

	lambda=test_mtx\[-data.force; data.preload]  ## lambda (constraint forces)=-inverse(test_mtx)*frcvec
	verb && println("Finding deflections...")

	# [B    0 ]      {0}         satisfies constraints
	# [K  D'S'P]{x}={-f-B'lam}   elastic force due to motion and initial deflection = total applied force less rigid constraint force
	# [PSD  P ]{d}  {fp}         the known elastic preloads result from motion of the system plus initial deflection before motion

	temp_mtx=ind_test_mtx[:,q+1:end]
	static=temp_mtx\[zeros(q,1);-data.force-data.constraint'*lambda[1:q];data.preload]
	static=-static[1:r]
	sumf=test_mtx[1:end-p,:]*lambda+data.force
else
	if(verb)
		println("Warning: this is a statically indeterminate system!")
		println("Trying to use item stiffness to determine preloads...")
	end

	if(rank(full(ind_test_mtx))==t)
		verb && println("Finding all forces of constraint, flexible item preloads, and deflections...")
		temp=full(ind_test_mtx)\[zeros(q);-data.force;data.preload]
	else
		if(verb)
			println("Warning: some preloads cannot be found uniquely!")
			println("Attempting a trial solution anyway...")
		end
		temp=pinv(full(ind_test_mtx))*[zeros(q);-data.force;data.preload]
	end
	static=-temp[q+1:q+r]
	lambda=[temp[1:q];[diagm(data.spring_stiffness)*data.deflection data.selection'*diagm(data.subset_spring_stiffness)]*temp[q+1:end]]
	sumf=test_mtx[1:r,:]*lambda+data.force
end

verb &&	println("Checking whether the system is in equilibrium...")
temp=(sumf'*sumf)[1]
if(temp<1e-5*length(sumf))  ## If magnitude squared of sumf < small  i.e., equals ~zero
	verb && println("System is in equilibrium. Good.")
else
	println("The squared force error is $temp.")
	error("System is not in equilibrium.")  ## Equilibrium cannot be found, thus the system cannot be analyzed
end

data.lambda=lambda
data.static=static

end  ## Leave
