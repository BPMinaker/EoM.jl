function run_eom(sysin::Function,vpts=1:1;analyze=false,report=false)
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

if(report)
	analyze=true
	dir_output=setup()  ## Creat output folder
end

the_system=Vector{mbd_system}(0)

analyze && println("Calling user function...")
for i in vpts ## Build all the input structs
	push!(the_system,sysin(i))
end

analyze && println("Running analysis of $(the_system[1].name) ...")
analyze && println("Found $(length(the_system[1].item)) items...")

for i=1:length(vpts)
	sort_system!(the_system[i],(i<2)*analyze)  ## Sort all the input structs
end

result=Vector{matrix_struct}(length(vpts))
#@time
for i=1:length(vpts)
	result[i]=build_eom(the_system[i],(i<2)*analyze)  ## Build eom
end

analyze && linear_analysis!(result)  ## Do all the eigen, freqresp, etc.
report && write_output(dir_output,vpts,the_system[1],result)

if(report && is_linux())
	println("Running LaTeX...")

	cmd="cd $(dir_output); /usr/bin/pdflatex -shell-escape -interaction batchmode report.tex"
	run(`bash -c $cmd`)
	run(`bash -c $cmd`)

end

analyze && println("Done.")

result

end
