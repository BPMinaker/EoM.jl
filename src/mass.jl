function mass(the_system,verb)
## Copyright (C) 2017, Bruce Minaker
## mass.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## mass.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verb && println("Building mass matrix...")

n=length(the_system.bodys)
d=6*(n-1)

temp=broadcast(mass_mtx,the_system.bodys)
mtx=zeros(d,d) ## Find the dimension of the system from number of bodies, subtract one for ground body
for i=1:n-1
	mtx[6*i-5:6*i,6*i-5:6*i]=temp[i]  ## Build mass matrix from body info
end

mtx

end ## Leave
