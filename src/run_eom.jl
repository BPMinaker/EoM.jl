function run_eom(sysin::Function;vpts=[],verbose=false)

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

n=1
m=length(vpts)
(m>1) && (n=m)

#the_system=Vector{mbd_system}(undef,n)  ## create empty system holder

the_list=Vector{mbd_eom}(undef,n)  ## create empty system holder

the_eqns=Vector{dss_data}(undef,n)

verbose && println("Calling system function...")

for i=1:n
	the_list[i]=mbd_eom()
	if m>0
		the_list[i].system=sysin(vpts[i])
		the_list[i].vpt=vpts[i]
	else
		the_list[i].system=sysin()
	end
	verbose && (i<2) && println("Running analysis of $(the_list[1].system.name) ...")
	verbose && (i<2) && println("Found $(length(the_list[1].system.item)) items...")
	sort_system!(the_list[i].system,(i<2)*verbose)  ## Sort all the input structs
	the_eqns[i],the_list[i].data=generate_eom(the_list[i].system,(i<2)*verbose)

end

the_list,the_eqns

end
