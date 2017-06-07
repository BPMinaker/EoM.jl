function run_eom(sysin::Function,vpts=0;report=false,analyze=report,verbose=false)
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
result=Vector{matrix_struct}(length(vpts))

verbose && println("Calling system function...")

for i=1:length(vpts)
	the_system[i]=sysin(vpts[i])  ## Build the input structs
end

verbose && println("Running analysis of $(the_system[1].name) ...")
verbose && println("Found $(length(the_system[1].item)) items...")

for i=1:length(vpts)
	sort_system!(the_system[i],(i<2)*verbose)  ## Sort all the input structs
	result[i]=build_eom(the_system[i],(i<2)*verbose)  ## Build eom
end

analyze && linear_analysis!(result,verbose)  ## Do all the eigen, freqresp, etc.

if report
	dir_output=setup()  ## Create output folder
	write_output(dir_output,vpts,the_system[1],result,verbose)
end

verbose && println("Done.")

if report
	result,dir_output
else
	result
end

end
