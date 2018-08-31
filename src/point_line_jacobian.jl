function point_line_jacobian(items,num)
## Copyright (C) 2017, Bruce Minaker
## point_line_jacobian.m is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## point_line_jacobian.m is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------
## Function 'point_line_jacobian' returns 'mtx' (constraint or deflection matrix of point items) as a function of 'in' (items in system) and 'num' (number of bodies)

nr=sum(broadcast(num_fm,items))  ## Find total number of rows needed

mtx=spzeros(nr,6*num)  ## Initially define blank matrix

idx=1
for i in items
	rs=i.radius[1]  ## Radius of the point item from the CG at 'start' body
	re=i.radius[2]  ## Radius of the point item from the CG at 'end' body
	pointer1=6*(i.body_number[1]-1)  ## Column number of the start body
	pointer2=6*(i.body_number[2]-1)  ## Column number of the end body
	nrows=i.forces+i.moments

	B1=[i.b_mtx[1];i.b_mtx[2]]*[I -skew(rs); zeros(3,3) I]; ## The skew rs makes 'theta'x'r'...
	B2=[i.b_mtx[1];i.b_mtx[2]]*[I -skew(re); zeros(3,3) I]; ## rotation of the body that creates a translation at the joint, i.e, x1-theta*r = 0

	B=spzeros(nrows,6*num)
	B[:,pointer1.+(1:6)]=B1 ## Positive
	B[:,pointer2.+(1:6)]=-B2 ## Negative, so the equations sum to zero, i.e x1 - x3 = 0

	mtx[idx:idx+nrows-1,:]=B ## Stack up the matrix for each flex point or rigid point
	idx=idx+nrows
end

n=6*(num-1)
mtx[:,1:n]  ## Eliminate ground from matrix (all items of ground motion will be zero anyhow)

end  ## Leave
