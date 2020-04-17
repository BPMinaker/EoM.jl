function write_output(systems,eoms,results;verbose=false,folder="output",data=systems[1].name)
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
dir_date,dir_time=setup(folder=folder,data=data)
dir_data=joinpath(dir_date,dir_time)

cmplx=0  ## Creates variable for number of oscillatory modes
dmpd=0  ## Creates variable for number of non-oscillatory modes
nstbl=0  ## Creates variable for number of unstable modes
rgd=0  ## Number of rigid body modes

#n=size(result[1].Am,1)
nin=size(eoms[1].B,2)
nout=size(eoms[1].C,1)

nvpts=length(results)

## Initialize output strings

eigen_f=open(joinpath(dir_data,"eigen.out"),"w")
println(eigen_f,"###### Eigenvalues\nnum speed real imag realhz imaghz nfreq zeta tau lambda")

mode_f=open(joinpath(dir_data,"eigen_modes.out"),"w")
println(mode_f,"###### Eigenvalues\nnum speed real imag")

centre_f=open(joinpath(dir_data,"centre.out"),"w")
println(centre_f,"###### Rotation centre, Axis of rotation\n num name speed r ri")

sstf_f=open(joinpath(dir_data,"sstf.out"),"w")
println(sstf_f,"###### Steady State Transfer Function")
if (nvpts>1)
	print(sstf_f,"speed")
	for i=1:nin*nout
		print(sstf_f," ",i)
	end
	println(sstf_f,"")
end

#hsv_f=open(joinpath(dir_output,"hsv.out"),"w")
#println(hsv_f,"###### Hankel SVD\nnum speed hsv")

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

		bode_f=open(joinpath(dir_data,"bode_$i.out"),"w")
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

		#for j=1:length(results[i].hsv)
		#	println(hsv_f,"{",j,"} ",the_list[i].vpt," ",results[i].hsv[j])  ## Write the vpoint (e.g. speed), then the hankel_sv
		#end
		#println(hsv_f,"")
	end
end

close(sstf_f)
close(eigen_f)
close(mode_f)
close(centre_f)
#close(hsv_f)

load_defln(systems[1],dir_data)
syst_props(systems[1],dir_data)

str="list_in=\""
for i in input_names
	str*=("'"*i*"' ")
end
str*="\"\n"
str*="list_out=\""
for i in output_names
	str*=("'"*i*"' ")
end
str*="\"\n"

str*="item_in(n)=word(list_in,n)\n"
str*="item_out(n)=word(list_out,n)\n"

if nvpts==1
	for i=1:nin
		str*="set term x11 persist $i\nset logscale x\nset xzeroaxis\nset yrange [-60<*:]\nset xlabel 'Frequency [Hz]'\nset ylabel 'Gain [dB]'\nplot for [z=$(3+(i-1)*nout):$(2+i*nout)] 'bode.out' using 1:z with lines title item_out(z-2-$((i-1)*nout)).'/'.item_in($i) lw 2\n"
	end
else
	for i=1:nin
		for j=1:nout
			str*="set term x11 persist $((i-1)*nout+j)\nset logscale x\nset xlabel 'Frequency [Hz]'\nset ylabel 'vpoint'\nset zlabel 'Gain [dB]' rotate by 90\nsplot 'bode.out' using 1:2:$(2+(i-1)*nout+j) with lines title item_out($j).'/'.item_in($i)\n"
		end
	end
	str*="unset logscale x\nset yrange [-60<*:]\nset xzeroaxis\nset xlabel 'vpoint'\nset ylabel 'Eigenvalue [rad/s]'\nset term x11 persist $(nin*nout+1)\nplot 'eigen.out' using 2:(abs(\$3)<1e-4?NaN:\$3) with points pt 7 lw 2 title 'Real', 'eigen.out' using 2:(abs(\$4)<1e-4?NaN:\$4) with points pt 6 lw 2 title 'Imaginary'\n"
	for i=1:nin
		str*="set term x11 persist $(nin*nout+1+i)\nset xzeroaxis\nset xlabel 'vpoint'\nset ylabel 'Gain'\nplot for [z=$(2+(i-1)*nout):$(1+i*nout)] 'sstf.out' using 1:z with lines title item_out(z+1-$((i-1)*nout)).'/'.item_in($i) lw 2\n"
	end
end

out=joinpath(dir_data,"plots.gp")
open(out,"w") do file
	write(file,str)
end

dss_path=joinpath(dir_data,"dss")
ss_path=joinpath(dir_data,"ss")

writedlm(joinpath(dss_path,"A.out"),eoms[end].A)
writedlm(joinpath(dss_path,"B.out"),eoms[end].B)
writedlm(joinpath(dss_path,"C.out"),eoms[end].C)
writedlm(joinpath(dss_path,"D.out"),eoms[end].D)
writedlm(joinpath(dss_path,"E.out"),eoms[end].E)

writedlm(joinpath(ss_path,"A.out"),results[end].ss_eqns.A)
writedlm(joinpath(ss_path,"B.out"),results[end].ss_eqns.B)
writedlm(joinpath(ss_path,"C.out"),results[end].ss_eqns.C)
writedlm(joinpath(ss_path,"D.out"),results[end].ss_eqns.D)

# sys=[results[1].ss_eqns.A results[1].ss_eqns.B; results[1].ss_eqns.C results[1].ss_eqns.D]
# sys=(abs.(sys).>=1e-9).*sys
# writedlm(joinpath(jordan_path,"ABCD.out"),sys)

# writedlm(joinpath(jordan_path,"A.out"),results[1].jordan.A)
# writedlm(joinpath(jordan_path,"B.out"),results[1].jordan.B)
# writedlm(joinpath(jordan_path,"C.out"),results[1].jordan.C)
# writedlm(joinpath(jordan_path,"D.out"),results[1].jordan.D)

# sys=[results[1].jordan.A results[1].jordan.B; results[1].jordan.C results[1].jordan.D]
# sys=(abs.(sys).>=1e-9).*sys
# writedlm(joinpath(jordan_path,"ABCD.out"),sys)

# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"mass.tex"),the_list[1].data.mass)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"s_stiff.tex"),the_list[1].data.stiffness)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"t_stiff.tex"),the_list[1].data.tangent_stiffness)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"l_stiff.tex"),the_list[1].data.load_stiffness)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"stiff.tex"),the_list[1].data.stiffness+the_list[1].data.load_stiffness+the_list[1].data.tangent_stiffness)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"damping.tex"),the_list[1].data.load_stiffness)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"velocity.tex"),the_list[1].data.velocity)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"momentum.tex"),the_list[1].data.momentum)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"constraint.tex"),the_list[1].data.constraint)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"nh_constraint.tex"),the_list[1].data.nh_constraint)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"input.tex"),the_list[1].data.input)
# write_mtx_ptrn(joinpath(pwd(),dir_output,dir_raw,"output.tex"),the_list[1].data.output)

dir_date,dir_time

end ## Leave

function write_mtx_ptrn(file_name,mtx)

	n,m=size(mtx)

	str="\\begin{tikzpicture}[every left delimiter/.style={xshift=1ex},every right delimiter/.style={xshift=-1ex}]\n"
	str*="\\draw[help lines,xstep=6ex,ystep=1ex] (0ex,0ex) grid ($(m)ex,$(n)ex);\n"
	str*="\\matrix (name)[matrix anchor=south west,row sep={1ex,between origins},column sep={1ex,between origins},matrix of nodes,left delimiter={[},right delimiter={]},dot/.style={fill=black,circle,scale=0.2},empty/.style={fill=white,circle,scale=0.2}] at (-0.5ex,-0.5ex)\n"

	str*="{\n"
	for i=1:n
		for j=1:m
			if j==m
				cc="\\\\"
			else
				cc="&"
			end
			if abs(mtx[i,j])>1e-6
				str*="\\node[dot]{};"*cc
			else
				str*="\\node[empty]{};"*cc
			end
		end
		str*="\n"
	end
	str*="};\n"

	str*="\\node [left=0ex of name] {\$\\mathbf{A}=\$};\n"
	str*="\\end{tikzpicture}\n"

	open(file_name,"w") do handle
		write(handle,str)
	end
end
