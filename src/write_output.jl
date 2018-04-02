function write_output(the_system,eoms,results;verbose=false,dir_raw="unformatted")
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

verbose && println("Writing output...")

cmplx=0  ## Creates variable for number of oscillatory modes
dmpd=0  ## Creates variable for number of non-oscillatory modes
nstbl=0  ## Creates variable for number of unstable modes
rgd=0  ## Number of rigid body modes

#n=size(result[1].Am,1)
nin=size(eoms[1].B,2)
nout=size(eoms[1].C,1)

nvpts=length(results)

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
if (nvpts>1)
	sstf*="speed"
	for i=1:nin*nout
		sstf*=" $i"
	end
	sstf*="\n"
end

hsv="###### Hankel SVD\nnum speed hsv\n"

for i=1:nvpts
	for j=1:length(results[i].e_val)
		realpt=real(results[i].e_val[j])
		imagpt=imag(results[i].e_val[j])

		omegan=abs(results[i].e_val[j])
		zeta=-realpt/omegan
		lambda=2*pi/abs(imagpt)
		tau=-1/realpt

		if abs(realpt)<1e-10
			tau=Inf
			zeta=0
		end

		if abs(imagpt)<1e-10
			lambda=NaN
			omegan=NaN
			zeta=NaN
		end

		eigen*="{$j} $(the_system[i].vpt) "*@sprintf("%.12e ",realpt) *@sprintf("%.12e ",imagpt)*@sprintf("%.12e ",realpt/2/pi) *@sprintf("%.12e ",imagpt/2/pi)*"\n"  ## Write the number, the speed, then the eigenvalue
		freq*="{$j} $(the_system[i].vpt) "*@sprintf("%.12e ",omegan/2/pi)*@sprintf("%.12e ",zeta)*@sprintf("%.12e ",tau)*@sprintf("%.12e ",lambda)*"\n"  ## Write nat freq, etc.
	end
	eigen*="\n"
	freq*="\n"
end

input_names=broadcast(EoM.name,the_system[1].actuators)
output_names=broadcast(EoM.name,the_system[1].sensors)

if(nin*nout>0 && nin*nout<16)
	for i=1:nvpts
		if(nvpts==1)
			sstf*="num outputtoinput gain\n"

			for j=1:nout
				for k=1:nin
					sstf*="{$((j-1)*nin+k)}"
					sstf*=" {$(output_names[j])/$(input_names[k])} "*@sprintf("%.12e ",results[1].ss_resp[j,k])*"\n"
				end
			end
		else
			## Each row starts with vpoint, followed by first column, written as a row, then next column, as a row
			sstf*="$(the_system[i].vpt) "
			for k in reshape(results[i].ss_resp[:,:],1,nin*nout)
				sstf*=@sprintf("%.12e ",k)
			end
			sstf*="\n"
		end

		phs=angle.(results[i].freq_resp)  ## Search for where angle changes by almost 1 rotation
		for u=1:nout
			for v=1:nin
				phs[u,v,find(abs.(diff(phs[u,v,:])).>6)]=Inf  ## Replace with Inf to trigger plot skip
			end
		end

		for j=1:length(results[i].w) ## Loop over frequency range
			## Each row starts with freq in Hz, then speed
			bode*=@sprintf("%.12e ",results[i].w[j]/2/pi)*"$(the_system[i].vpt) "
			## Followed by first mag column, written as a row, then next column, as a row
			for k in reshape(20*log10.(abs.(results[i].freq_resp[:,:,j])),1,nin*nout)
				bode*=@sprintf("%.12e ",k)
			end
			for k in reshape(180/pi*phs[:,:,j],1,nin*nout)
				bode*=@sprintf("%.12e ",k)  ## Followed by first phase column, written as a row, then next column, as a row
			end
			bode*="\n"
		end
		bode*="\n"
# #		strs.zeros=[strs.zeros sprintf('%4.12e ',real(result{i}.math.zros),imag(result{i}.math.zros))];

  		for j=1:length(results[i].hsv)
			hsv*="{$j} $(the_system[i].vpt) $(results[i].hsv[j])\n"  ## Write the vpoint (e.g. speed), then the hankel_sv
  		end
  		hsv*="\n"
	end
end

preload,defln=load_defln(the_system[1])
bodydata,pointdata,linedata,stiffnessdata=syst_props(the_system[1])

data_out=[bodydata pointdata linedata stiffnessdata]
file_name=["bodydata.out" "pointdata.out" "linedata.out" "stiffnessdata.out"]

dir_output=setup()

for i=1:length(data_out)
	out=joinpath(dir_output,file_name[i])
	open(out,"w") do file
		write(file,data_out[i])
	end
end

data_out=[eigen freq bode sstf hsv preload defln]
file_name=["eigen.out" "freq.out" "bode.out" "sstf.out" "hsv.out" "preload.out" "defln.out"]

for i=1:length(data_out)
	out=joinpath(dir_output,file_name[i])
	open(out,"w") do file
		write(file,data_out[i])
	end
end

write_mtx(eoms[1].A,joinpath(dir_output,dir_raw,"A.out"))
write_mtx(eoms[1].B,joinpath(dir_output,dir_raw,"B.out"))
write_mtx(eoms[1].C,joinpath(dir_output,dir_raw,"C.out"))
write_mtx(eoms[1].D,joinpath(dir_output,dir_raw,"D.out"))
write_mtx(eoms[1].E,joinpath(dir_output,dir_raw,"E.out"))

# write_mtx(eoms[1].At,joinpath(dir_output,dir_raw,"At.out"))
# write_mtx(eoms[1].Bt,joinpath(dir_output,dir_raw,"Bt.out"))
# write_mtx(eoms[1].Ct,joinpath(dir_output,dir_raw,"Ct.out"))
# write_mtx(eoms[1].Dt,joinpath(dir_output,dir_raw,"Dt.out"))
#
# write_mtx(eoms[1].Aj,joinpath(dir_output,dir_raw,"Aj.out"))
# write_mtx(eoms[1].Bj,joinpath(dir_output,dir_raw,"Bj.out"))
# write_mtx(eoms[1].Cj,joinpath(dir_output,dir_raw,"Cj.out"))
# write_mtx(eoms[1].Dj,joinpath(dir_output,dir_raw,"Dj.out"))
#
# write_mtx(eoms[1].Am,joinpath(dir_output,dir_raw,"Am.out"))
# write_mtx(eoms[1].Bm,joinpath(dir_output,dir_raw,"Bm.out"))
# write_mtx(eoms[1].Cm,joinpath(dir_output,dir_raw,"Cm.out"))
# write_mtx(eoms[1].Dm,joinpath(dir_output,dir_raw,"Dm.out"))
#
# write_mtx_ptrn(eoms[1].Am,joinpath(dir_output,dir_raw,"Amp.out"))
# write_mtx_ptrn(eoms[1].Bm,joinpath(dir_output,dir_raw,"Bmp.out"))
# write_mtx_ptrn(eoms[1].Cm,joinpath(dir_output,dir_raw,"Cmp.out"))
# write_mtx_ptrn(eoms[1].Dm,joinpath(dir_output,dir_raw,"Dmp.out"))
#
# write_mtx_ptrn([eoms[1].Am eoms[1].Bm; eoms[1].Cm eoms[1].Dm],joinpath(dir_output,dir_raw,"ABCDmp.out"))

# mtx=eoms[1].stiffness+eoms[1].tangent_stiffness+eoms[1].load_stiffness
# r,c,v=findnz(mtx)
# writedlm(joinpath(pwd(),dir_output,dir_raw,"stiffness_matrix.out"),[r c v])

dir_output

end ## Leave

function write_mtx(mtx,file_name)
	str=""
	for i=1:size(mtx,1)
		for j=1:size(mtx,2)
			str*= @sprintf("%.12e ",mtx[i,j])
		end
		str*="\n"
	end
	str*="\n"
	open(file_name,"w") do handle
		write(handle,str)
	end
end

function write_mtx_ptrn(mtx,file_name)

	str="\\begin{tikzpicture}[every left delimiter/.style={xshift=1.5ex},every right delimiter/.style={xshift=-1.5ex}]\n"


	str*="\\matrix (pat)[row sep={1ex,between origins},column sep={1ex,between origins},matrix of math nodes,left delimiter={[},right delimiter={]}]\n"

	str*="{\n"
	for i=1:size(mtx,1)
		for j=1:size(mtx,2)
			if j==size(mtx,2)
				cc="\\\\"
			else
				cc="&"
			end
			if abs(mtx[i,j])>1e-6
				str*="."*cc
			else
				str*=" "*cc
			end
		end
		str*="\n"
	end
	str*="};\n"

	str*="\\node [left=0ex of pat] {\$\\mathbf{$(file_name[end-6])}=\$};\n"
	str*="\\end{tikzpicture}\n"

	open(file_name,"w") do handle
		write(handle,str)
	end
end


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
