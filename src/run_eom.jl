function run_eom(sysin::Function;vpts=[],verbose=false,diagnose=false)

## Copyright (C) 2017, Bruce Minaker
## run_eom.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## run_eom.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

m=length(vpts)
n=max(1,m)

# create empty system holders
the_system=Vector{mbd_system}(undef,n) 
the_eqns=Vector{dss_data}(undef,n)
the_data=Vector{eom_data}(undef,n)

verbose && println("Calling system function...")

for i=1:n
	if m>0
		the_system[i]=sysin(vpts[i])
		the_system[i].vpt=vpts[i]
	else
		the_system[i]=sysin()
	end
	verbose && (i<2) && println("Running analysis of $(the_system[1].name) ...")
	verbose && (i<2) && println("Found $(length(the_system[1].item)) items...")
	sort_system!(the_system[i],(i<2)*verbose)  ## Sort all the input structs
	the_eqns[i],the_data[i]=generate_eom(the_system[i],(i<2)*verbose)
end

if ~diagnose
	return the_system,the_eqns
else
	return the_system,the_eqns,the_data
end

end
