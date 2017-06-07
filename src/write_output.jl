function write_output(dir_output,vpts,the_system,result,verb=false;dir_raw="unformatted")
## Copyright (C) 2017, Bruce Minaker
## write_output.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## write_output.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verb && println("Writing output...")

cmplx=0  ## Creates variable for number of oscillatory modes
dmpd=0  ## Creates variable for number of non-oscillatory modes
nstbl=0  ## Creates variable for number of unstable modes
rgd=0  ## Number of rigid body modes

#n=size(result[1].Am,1)
nin=size(result[1].B,2)
nout=size(result[1].C,1)

## Initialize output strings
eigen="###### Eigenvalues\nnum speed real imag realhz imaghz\n"
freq="###### Natural Frequency\nnum speed nfreq zeta tau lambda\n"

#strs.mode=["###### Modes $nn\n"]
#strs.centre="###### Speed, Mode, Body, Rotation centre, Axis of rotation\nspeed num name rx rxi ry ryi rz rzi ux uxi uy uyi uz uzi\n"

bode="###### Bode Mag Phase\nfrequency speed"
for i=1:nin*nout
	bode*=" m$i"
end
for i=1:nin*nout
	bode*=" p$i"
end
bode*="\n"

#zeros=['###### Zeros\n'	'Speed \n'];

sstf="###### Steady State Transfer Function\n"
if (length(vpts)>1)
	sstf*="speed"
	for i=1:nin*nout
		sstf*=" $i"
	end
	sstf*="\n"
end

hsv="###### Hankel SVD\nnum speed hsv\n"

for i=1:length(vpts)
	for j=1:length(result[i].e_val)
		realpt=real(result[i].e_val[j])
		imagpt=imag(result[i].e_val[j])

		tau=-1/realpt
		lambda=2*pi/abs(imagpt)

		if(isreal(result[i].e_val[j]))
			# counter=1
			omegan=NaN
			zeta=NaN
			# if(realpt==0)
			# 	rgd+=1
			# end
		else
			# counter=1/2
			# cmplx+=1/2
			omegan=abs(result[i].e_val[j])
			zeta=-realpt/omegan
		end

		# if(realpt>0)
		# 	nstbl+=counter
		# elseif(realpt<0)
		# 	dmpd+=counter
		# end

		eigen*="{$j} $(vpts[i]) $realpt $imagpt $(realpt/2/pi) $(imagpt/2/pi)\n"  ## Write the number, the speed, then the eigenvalue
		freq*="{$j} $(vpts[i]) $(omegan/2/pi) $zeta $tau $lambda\n"  ## Write nat freq, etc.
	end
	eigen*="\n"
	freq*="\n"
end

if(nin*nout>0  && nin*nout<16)
	for i=1:length(vpts)
		if(length(vpts)==1)
			sstf*="num outputtoinput gain\n"

			for j=1:nout
				for k=1:nin
					sstf*="{$((j-1)*nin+k)}"
					sstf*=" {$(result[i].output_names[j])/$(result[i].input_names[k])} $(result[1].ss_resp[j,k])\n"
				end
			end
		else
			## Each row starts with vpoint, followed by first column, written as a row, then next column, as a row
			sstf*="$(vpts[i])"
			for k in reshape(result[i].ss_resp[:,:],1,nin*nout)
				sstf*=" $k"
			end
			sstf*="\n"
		end

		phs=angle(result[i].freq_resp)  ## Search for where angle changes by almost 1 rotation
		for u=1:nout
			for v=1:nin
				phs[u,v,find(abs(diff(phs[u,v,:])).>6)]=Inf  ## Replace with Inf to trigger plot skip
			end
		end

		for j=1:length(result[i].w) ## Loop over frequency range
			## Each row starts with freq in Hz, then speed
			bode*="$(result[i].w[j]/2/pi) $(vpts[i])"
			## Followed by first mag column, written as a row, then next column, as a row
			for k in reshape(20*log10(abs(result[i].freq_resp[:,:,j])),1,nin*nout)
				bode*=" $k"
			end
			for k in reshape(180/pi*phs[:,:,j],1,nin*nout)
				bode*=" $k"  ## Followed by first phase column, written as a row, then next column, as a row
			end
			bode*="\n"
		end
		bode*="\n"
# #		strs.zeros=[strs.zeros sprintf('%4.12e ',real(result{i}.math.zros),imag(result{i}.math.zros))];

  		for j=1:length(result[i].hsv)
			hsv*="{$j} $(vpts[i]) $(result[i].hsv[j])\n"  ## Write the vpoint (e.g. speed), then the hankel_sv
  		end
  		hsv*="\n"
	end
end

preload,defln=load_defln(the_system)
bodydata,pointdata,linedata,stiffnessdata=syst_props(the_system)

data_out=[bodydata pointdata linedata stiffnessdata]
file_name=["bodydata.out" "pointdata.out" "linedata.out" "stiffnessdata.out"]

for i=1:length(data_out)
	out=joinpath(dir_output,file_name[i])
	file=open(out,"w")
	write(file,data_out[i])
	close(file)
end

data_out=[eigen freq bode sstf hsv preload defln]
file_name=["eigen.out" "freq.out" "bode.out" "sstf.out" "hsv.out" "preload.out" "defln.out"]

for i=1:length(data_out)
	out=joinpath(dir_output,file_name[i])
	file=open(out,"w")
	write(file,data_out[i])
	close(file)
end

writedlm(joinpath(pwd(),dir_output,dir_raw,"A.out"),result[1].A)
writedlm(joinpath(pwd(),dir_output,dir_raw,"B.out"),result[1].B)
writedlm(joinpath(pwd(),dir_output,dir_raw,"C.out"),result[1].C)
writedlm(joinpath(pwd(),dir_output,dir_raw,"D.out"),result[1].D)
writedlm(joinpath(pwd(),dir_output,dir_raw,"E.out"),result[1].E)

writedlm(joinpath(pwd(),dir_output,dir_raw,"Amin.out"),result[1].Am)
writedlm(joinpath(pwd(),dir_output,dir_raw,"Bmin.out"),result[1].Bm)
writedlm(joinpath(pwd(),dir_output,dir_raw,"Cmin.out"),result[1].Cm)
writedlm(joinpath(pwd(),dir_output,dir_raw,"Dmin.out"),result[1].Dm)


mtx=result[1].stiffness+result[1].tangent_stiffness+result[1].load_stiffness
r,c,v=findnz(mtx)
writedlm(joinpath(pwd(),dir_output,dir_raw,"stiffness_matrix.out"),[r c v])


#writedlm(joinpath(pwd(),dir_output,dir_raw,"M.out"),result[1].M)
#writedlm(joinpath(pwd(),dir_output,dir_raw,"KC.out"),result[1].KC)
#writedlm(joinpath(pwd(),dir_output,dir_raw,"J.out"),result[1].right_jacobian)

# writedlm(joinpath(pwd(),dir_output,dir_raw,"mass.out"),result[1].mass)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"input.out"),result[1].input)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"output.out"),result[1].output)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"stiff.out"),result[1].stiffness)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"tstiff.out"),result[1].tangent_stiffness)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"lstiff.out"),result[1].load_stiffness)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"momentum.out"),result[1].momentum)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"constraint.out"),result[1].constraint)


end ## Leave
