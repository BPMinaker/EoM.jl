function run_eom(sysin::Function,vpts=0;verbose=false)
	##,param::Symbol=:dummy,vpts=0,extra...;verbose=false)
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

the_system=Vector{mbd_system}(length(vpts))  ## create empty system holder

verbose && println("Calling system function...")

for i=1:length(vpts)
	the_system[i]=sysin(vpts[i])
	the_system[i].vpt=vpts[i]
	verbose && (i<2) && println("Running analysis of $(the_system[1].name) ...")
	verbose && (i<2) && println("Found $(length(the_system[1].item)) items...")
	sort_system!(the_system[i],(i<2)*verbose)  ## Sort all the input structs
end

the_system

end
