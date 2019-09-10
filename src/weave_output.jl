function weave_output(the_list,results;verbose=false,folder="output")
## Copyright (C) 2019, Bruce Minaker
## weave_output.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## weave_output.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verbose && println("Writing output...")

cmplx=0  ## Creates variable for number of oscillatory modes
dmpd=0  ## Creates variable for number of non-oscillatory modes
nstbl=0  ## Creates variable for number of unstable modes
rgd=0  ## Number of rigid body modes

nin=size(results[1].ss_eqns.B,2)
nout=size(results[1].ss_eqns.C,1)
nvpts=length(results)

## Initialize output strings
dir=joinpath(pwd(),folder)
if(~isdir(dir))  ## If no output folder exists
	mkdir(dir)  ## Create new empty output folder
end

eigen_f=open(joinpath(dir,"eigen.out"),"w")
println(eigen_f,"###### Eigenvalues\nnum speed real imag realhz imaghz")

freq_f=open(joinpath(dir,"freq.out"),"w")
println(freq_f,"###### Natural Frequency\nnum speed nfreq zeta tau lambda")

centre_f=open(joinpath(dir,"centre.out"),"w")
println(centre_f,"###### Rotation centre, Axis of rotation\n num name speed r ri")

bode_f=open(joinpath(dir,"bode.out"),"w")
println(bode_f,"###### Bode Mag Phase")
print(bode_f,"frequency speed")

for i=1:nin*nout
 	print(bode_f," m$i")
end
for i=1:nin*nout
	print(bode_f," p$i")
end
println(bode_f,"")

sstf_f=open(joinpath(dir,"sstf.out"),"w")
println(sstf_f,"###### Steady State Transfer Function")
if (nvpts>1)
	print(sstf_f,"speed")
	for i=1:nin*nout
		print(sstf_f," ",i)
	end
	println(sstf_f,"")
end

for i=1:nvpts

		# realpt=real.(results[i].e_val)
		# imagpt=imag.(results[i].e_val)
		# n=length(results[i].e_val)
		#
		# writedlm(eigen_f	[fill(the_list[i].vpt,n,1) realpt imagpt realpt./2pi imagpt./2pi])
		# println(eigen_f,"")
		# writedlm(freq_f,   [fill(the_list[i].vpt,n,1) results[i].omega_n results[i].zeta results[i].tau results[i].lambda])
		# println(freq_f,"")

	for j=1:length(results[i].e_val)

		realpt=real(results[i].e_val[j])
		imagpt=imag(results[i].e_val[j])
		println(eigen_f,"{",j,"} ",the_list[i].vpt," ",realpt," ",imagpt," ",realpt/2/pi," ",imagpt/2/pi)  ## Write the number, the speed, then the eigenvalue
		println(freq_f,"{",j,"} ",the_list[i].vpt," ",results[i].omega_n[j]," ",results[i].zeta[j]," ",results[i].tau[j]," ",results[i].lambda[j])  ## Write nat freq, etc.

		for k=1:length(the_list[i].system.bodys)-1
			for m=1:6
				println(centre_f,"{",j,"} {",the_list[i].system.bodys[k].name,"} ",the_list[i].vpt," ",real(results[i].centre[6*k-6+m,j])," ",imag(results[i].centre[6*k-6+m,j]))  ## Write the number, the speed ...
			end
			println(centre_f,"")
		end
		println(centre_f,"")
	end
	println(eigen_f,"")
	println(freq_f,"")
end

input_names=EoM.name.(the_list[1].system.actuators)
output_names=EoM.name.(the_list[1].system.sensors)

if(nin*nout>0 && nin*nout<16)
	for i=1:nvpts
		if(nvpts==1)
			println(sstf_f,"num outputtoinput gain")

			for j=1:nout
				for k=1:nin
					print(sstf_f,"{",(j-1)*nin+k,"} ")
					println(sstf_f,"{",output_names[j],"/",input_names[k],"} ",results[1].ss_resp[j,k])
				end
			end
		else
			## Each row starts with vpoint, followed by first column, written as a row, then next column, as a row
			print(sstf_f,the_list[i].vpt," ")
			for k in vec(results[i].ss_resp[:,:])
				print(sstf_f,k," ")
			end
			println(sstf_f,"")
		end

		phs=angle.(results[i].freq_resp)  ## Search for where angle changes by almost 1 rotation
		for u=1:nout
			for v=1:nin
				phs[u,v,findall(abs.(diff(phs[u,v,:])).>6)].=Inf  ## Replace with Inf to trigger plot skip
			end
		end

		for j=1:length(results[i].w) ## Loop over frequency range
			## Each row starts with freq in Hz, then speed
			print(bode_f,results[i].w[j]/2/pi," ",the_list[i].vpt," ")
			## Followed by first mag column, written as a row, then next column, as a row
			for k in vec(20*log10.(abs.(results[i].freq_resp[:,:,j])))
				print(bode_f,k," ")
			end
			for k in vec(180/pi*phs[:,:,j])
				print(bode_f,k," ")  ## Followed by first phase column, written as a row, then next column, as a row
			end
			println(bode_f,"")
		end
		println(bode_f,"")
	end
end

close(bode_f)
close(sstf_f)
close(eigen_f)
close(freq_f)
close(centre_f)

end ## Leave
