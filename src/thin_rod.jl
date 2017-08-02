function thin_rod(name,ends,mass)
## Copyright (C) 2013, Bruce Minaker
## This file is intended for use with Octave.
## thin_rod.m is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## thin_rod.m is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## thin_rod finds the mass matrix and mass centre of a thin rod, given
## end locations

len_vec=diff(ends,2)
i_mtx=-skew(len_vec)^2*mass/12

item=body(name)
item.mass=mass
item.location=mean(ends,2)[:,1]
item.moments_of_inertia=diag(i_mtx)
item.products_of_inertia=-[i_mtx[1,2],i_mtx[2,3],i_mtx[3,1]]  ## Change sign; using defn of Ixy as +ve integral

item

end  ## Leave
