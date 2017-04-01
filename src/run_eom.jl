function run_eom(sysin,vpts=1:1,flags=[];parms...)
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

config,option=setup(flags)  ## Clear screen, set pager, etc.

option.analyze && println("Calling function $sysin...")

if(~isdefined(parse(sysin)))
	include(joinpath(pwd(),config.dir_input,"$sysin.jl"))
end
func=getfield(Main,Symbol(sysin))

the_system=Vector{mbd_system}(0)
for i in vpts ## Build all the input structs
	push!(the_system,func(i;parms...))
end

option.analyze && println("Running analysis of $(the_system[1].name) ...")
option.analyze && println("Found $(length(the_system[1].item)) items...")

for i=1:length(vpts)
	sort_system!(the_system[i],(i<2)*option.analyze)  ## Sort all the input structs
end

result=Vector{matrix_struct}(length(vpts))
#@time
for i=1:length(vpts)
	result[i]=build_eom(the_system[i],(i<2)*option.analyze)  ## Build eom
end

option.analyze && linear_analysis!(result)  ## Do all the eigen, freqresp, etc.
option.report && write_output(config,option,vpts,the_system[1],result)

if(option.report && is_linux())
	println("Running LaTeX...")

	cmd="cd $(config.dir_output); /usr/bin/pdflatex -shell-escape -interaction batchmode report.tex"
	run(`bash -c $cmd`)
	run(`bash -c $cmd`)

end

option.analyze && println("Done.")

result

end
