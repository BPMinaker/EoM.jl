function line_bend_jacobian(items,num) ## Function 'line_bend_jacobian' returns 'mtx' (constraint or deflection matrix of directed items) as a function of 'in' (directed items in system) and 'num' (number of bodies) 
## Copyright (C) 2017, Bruce Minaker
## line_bend_jacobian.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## line_bend_jacobian.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

mtx=zeros(4*length(items),6*num); ## Initially define deflection matrix as zero matrix

idx=1
for i in items
	l=i.length
	rs=i.radius[:,1]  ## Radius from body1 cg to point of action of directed item on body1; 's'=start
	re=i.radius[:,2]  ## Radius from body2 cg to point of action of directed item on body2; 'e'=end
	pointer1=6*(i.body_number[1]-1)  ## Column number of the start body
	pointer2=6*(i.body_number[2]-1)  ## Column number of the end body

	B1=[i.b_mtx[1];i.b_mtx[2]]*[eye(3) -skew(rs); zeros(3,3) eye(3)]  ## The skew rs makes 'theta'x'r'... 
	B2=[i.b_mtx[1];i.b_mtx[2]]*[eye(3) -skew(re); zeros(3,3) eye(3)]  ## rotation of the body that creates a translation at the joint, i.e, x1-theta*r = 0

	B=zeros(8,6*num)
	B[1:4,pointer1+(1:6)]=B1
	B[5:8,pointer2+(1:6)]=B2

	D=[0 0 0 -1 0 0 0 1; 2/l 0 0 1 -2/l 0 0 1; 0 0 -1 0 0 0 1 0; 0 2/l -1 0 0 -2/l -1 0]  ## Relate the beam stiffness matrix to the deflection of the ends (diagonalize the typical beam stiffness matrix!)

	mtx[4*idx+(-3:0),:]=D*B;
	idx+=1
end

n=6*(num-1) ## n = number of bodies -1 = number of bodies not including ground
mtx[:,1:n]  ## mtx = jacobian / deflection matrix

end ## Leave
