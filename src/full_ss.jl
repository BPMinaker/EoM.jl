function full_ss(dss_eqns;verbose=false)
## Copyright (C) 2017, Bruce Minaker
## full_ss.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## full_ss.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verbose && println("Converting...")

nvpts=length(dss_eqns)  ## Number of points to plot
result=Vector{ss_data}(undef,nvpts)

for i=1:nvpts
	m=size(dss_eqns[i].phys,1)
	n=size(dss_eqns[i].B,2)

	temp=dss_data(dss_eqns[i].A,dss_eqns[i].B,dss_eqns[i].phys,zeros(m,n),dss_eqns[i].E,dss_eqns[i].phys)
	result[i],val=dss2ss(temp,verbose && i<2)  ## Reduce to standard form
end

result

end ## Leave
