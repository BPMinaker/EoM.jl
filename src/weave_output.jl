function weave_output(systems,results;verbose=false,folder="output")
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

## Initialize output

# dir=joinpath(pwd(),"figures")
# if ~isdir(dir)
# 	mkdir(dir)
# end

dir=joinpath(pwd(),folder)
if ~isdir(dir)  ## If no output folder exists
	mkdir(dir)  ## Create new empty output folder
end

eigen_f=open(joinpath(dir,"eigen.out"),"w")
println(eigen_f,"###### Eigenvalues\nnum speed real imag realhz imaghz nfreq zeta tau lambda")

mode_f=open(joinpath(dir,"eigen_modes.out"),"w")
println(mode_f,"###### Eigenvalues\nnum speed real imag")

centre_f=open(joinpath(dir,"centre.out"),"w")
println(centre_f,"###### Rotation centre, Axis of rotation\n num name speed r ri")

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

	for j=1:length(results[i].mode_vals)
		println(mode_f,"{",j,"} ",systems[i].vpt," ",real(results[i].mode_vals[j])  ," ",imag(results[i].mode_vals[j]))  ## Write the number, the speed, then the eigenvalue
		for k=1:length(systems[i].bodys)-1
			for m=1:6
				println(centre_f,"{",j,"} {",systems[i].bodys[k].name,"} ",systems[i].vpt," ",real(results[i].centre[6*k-6+m,j])," ",imag(results[i].centre[6*k-6+m,j]))  ## Write the number, the speed ...
			end
			println(centre_f,"")
		end
		println(centre_f,"")
	end
	println(mode_f,"")

	for j=1:length(results[i].e_val)
		realpt=real(results[i].e_val[j])
		imagpt=imag(results[i].e_val[j])
		println(eigen_f,"{",j,"} ",systems[i].vpt," ",realpt," ",imagpt," ",realpt/2/pi," ",imagpt/2/pi," ",results[i].omega_n[j]," ",results[i].zeta[j]," ",results[i].tau[j]," ",results[i].lambda[j])  ## Write the number, the speed, then the eigenvalue
	end
	println(eigen_f,"")
end

input_names=EoM.name.(systems[1].actuators)
output_names=EoM.name.(systems[1].sensors)

if(nin*nout>0 && nin*nout<16)
	for i=1:nvpts
		if(nvpts==1)
			println(sstf_f,"num outputtoinput gain")
			for j=1:nout
				for k=1:nin
					print(sstf_f,"{",(j-1)*nin+k,"} ")
					println(sstf_f,"{\$",output_names[j],"/",input_names[k],"\$} ",results[1].ss_resp[j,k])
				end
			end
		else
			## Each row starts with vpoint, followed by first column, written as a row, then next column, as a row
			print(sstf_f,systems[i].vpt," ")
			for k in vec(results[i].ss_resp[:,:])
				print(sstf_f,k," ")
			end
			println(sstf_f,"")
		end

		bode_f=open(joinpath(dir,"bode_$i.out"),"w")
		println(bode_f,"###### Bode Mag Phase")
		print(bode_f,"frequency speed")

		for i=1:nin*nout
		 	print(bode_f," m$i")
		end
		for i=1:nin*nout
			print(bode_f," p$i")
		end
		println(bode_f,"")

		mag=abs.(results[i].freq_resp).+eps(1.0)
		phs=angle.(results[i].freq_resp)  ## Search for where angle changes by almost 1 rotation
		for u=1:nout
			for v=1:nin
				phs[u,v,findall(abs.(diff(phs[u,v,:])).>6)].=Inf  ## Replace with Inf to trigger plot skip
				phs[u,v,findall(mag[u,v,:].<1e-8)].=0  ## Set angle to zero is magnitude is almost zero
			end
		end

		for j=1:length(results[i].w) ## Loop over frequency range
			## Each row starts with freq in Hz, then speed
			print(bode_f,results[i].w[j]/2/pi," ",systems[i].vpt," ")
			## Followed by first mag column, written as a row, then next column, as a row
			for k in vec(20*log10.(mag[:,:,j]))
				print(bode_f,k," ")
			end
			for k in vec(180/pi*phs[:,:,j])
				print(bode_f,k," ")  ## Followed by first phase column, written as a row, then next column, as a row
			end
			println(bode_f,"")
		end
		close(bode_f)
	end
end

close(sstf_f)
close(eigen_f)
close(mode_f)
close(centre_f)

end ## Leave
