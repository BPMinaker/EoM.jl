function run_eom(sysin,vpts=1:1,flags=[])
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

include(joinpath(pwd(),config.dir_input,"$sysin.jl"))
s=Symbol(sysin)
f=getfield(Main,s)

the_system=Vector{mbd_system}(0)
for i in vpts ## Build all the input structs
	temp=f(i)
	push!(the_system,temp)
end

n=the_system[1].name
option.analyze && println("Running analysis of $n ...")
n=length(the_system[1].item)
option.analyze && println("Found $n items...")

for i=1:length(vpts)
	sort_system!(the_system[i],i<2)  ## Sort all the input structs
end

result=Vector{matrix_struct}(length(vpts))
tic
for i=1:length(vpts)
	result[i]=build_eom(the_system[i],(i<2)*option.analyze)  ## Build eom
end
toc

writedlm(joinpath(pwd(),config.dir_raw,"A'.out"),result[1].A)
writedlm(joinpath(pwd(),config.dir_raw,"B'.out"),result[1].B)
writedlm(joinpath(pwd(),config.dir_raw,"C'.out"),result[1].C)
writedlm(joinpath(pwd(),config.dir_raw,"D'.out"),result[1].D)
writedlm(joinpath(pwd(),config.dir_raw,"E'.out"),result[1].E)

option.analyze && linear_analysis!(result)  ## Do all the eigen, freqresp, etc.
#println(result[1])

writedlm(joinpath(pwd(),config.dir_raw,"A.out"),result[1].AA)
writedlm(joinpath(pwd(),config.dir_raw,"B.out"),result[1].BB)
writedlm(joinpath(pwd(),config.dir_raw,"C.out"),result[1].CC)
writedlm(joinpath(pwd(),config.dir_raw,"D.out"),result[1].DD)

println("Done.")

end
