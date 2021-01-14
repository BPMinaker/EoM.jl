function analyze(dss_eqns,args...;decomp=true)
## Copyright (C) 2017, Bruce Minaker
## analyze.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## analyze.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verbose=any(args.==:verbose)
verbose && println("Running linear analysis...")

nvpts=length(dss_eqns) # number of vpoints (speeds)
result=Vector{analysis}(undef,nvpts)
lower=zeros(nvpts)
upper=zeros(nvpts)
wpts=500 # number of frequencies

for i=1:nvpts

	result[i]=analysis()
	F=eigen(dss_eqns[i].A,dss_eqns[i].E) # find the eigen
	tmp_vect=F.vectors[:,isfinite.(F.values)]
	tmp_vals=F.values[isfinite.(F.values)] # discard modes with Inf or Nan vals

	p=sortperm(round.(tmp_vals,digits=5),by=x->(isreal(x),real(x)>0,abs(x),real(x),abs(imag(x)),-imag(x)))
	result[i].mode_vals=tmp_vals[p]
	tmp_vect=tmp_vect[:,p]

	result[i].modes=dss_eqns[i].phys*tmp_vect # convert vector to physical coordinates
	nb=div(size(result[i].modes,1),6)
	nm=size(result[i].modes,2)

	result[i].centre=zeros(size(result[i].modes))

	for j=1:nm # for each mode
		if norm(result[i].modes[:,j])>0 # check for non-zero displacement modes
			max,k=findmax(abs.(result[i].modes[:,j])) # find max entry
			result[i].modes[:,j]/=(2*result[i].modes[k,j]) # scale motions to unity by diving by max value, but not abs of max, as complex possible
		end

		for k=1:nb # for each body
			mtn=result[i].modes[6*k.+(-5:0),j] # motion of body k
			temp,l=findmax(abs.(mtn)) # find max coordinate
			phi=angle(mtn[l]) # find angle of that coordinate
			mtn*=exp(-phi*1im) # rotate by negative of that angle to remove unnecessary imag parts

			result[i].centre[6*k.+(-5:0),j]=[-pinv(skew(mtn[4:6]))*mtn[1:3];mtn[4:6]/(norm(mtn[4:6])+eps(1.))]
			# radius to the instantaneous center of rotation of the body (rad=omega\v)
		end
	end

	temp=dss2ss(dss_eqns[i],verbose && i<2 && :verbose) # reduce to standard form
	if decomp
		result[i].ss_eqns,result[i].e_val=decompose(temp,verbose && i<2 && :verbose)
	else
		result[i].ss_eqns=temp
		result[i].e_val=result[i].mode_vals
	end

	result[i].omega_n=abs.(result[i].e_val)/2/pi
	result[i].zeta=-real.(result[i].e_val)./abs.(result[i].e_val)
	result[i].tau=-1.0./real.(result[i].e_val)
	result[i].lambda=abs.(2*pi./imag.(result[i].e_val))

	idx=abs.(real.(result[i].e_val)).<1e-10
	result[i].tau[idx].=Inf
	result[i].zeta[idx].=0

	idx=abs.(imag.(result[i].e_val)).<1e-10
	result[i].lambda[idx].=Inf
	result[i].omega_n[idx].=0
	result[i].zeta[idx].=NaN

	t=abs.(result[i].e_val)
	temp=t[t.>1e-6]
	if length(temp)==0
		lower[i]=1e-6
	else
		lower[i]=minimum(temp)
	end
	upper[i]=maximum(t)
end

low=floor(log10(0.5*minimum(lower)/2/pi))
# lowest low eigenvalue, round number in Hz
(low < -2) && (low=-2) # limit the min 0.01 Hz
high=ceil(log10(2.0*maximum(upper)/2/pi))
# highest high eigenvalue, round number in Hz
w=2*pi*(10.0.^range(low,stop=high,length=wpts))
# compute evenly spaced range of frequncies in log space to consider

flag=false
for i=1:nvpts
	result[i].w=w
	nin=size(result[i].ss_eqns.B,2)
	nout=size(result[i].ss_eqns.C,1)

	result[i].freq_resp=zeros(nout,nin,length(w))
	A=result[i].ss_eqns.A
	B=result[i].ss_eqns.B
	C=result[i].ss_eqns.C
	D=result[i].ss_eqns.D

	# compute frequency response
	for j=1:wpts
		result[i].freq_resp[:,:,j]=C*((I*w[j]im-A)\B)+D
	end

	# compute steady state response
	try
		result[i].ss_resp=-C*(A\B)+D
	catch
		verbose && flag==false && println("No inverse exists, trying individual input output pairs.")
		flag=true

		temp=dss2ss(dss_eqns[i],verbose && i<2 && :verbose)
		result[i].ss_resp=zeros(nout,nin)
		for m=1:nin
			for n=1:nout
				temp_mn=ss_data(temp.A,temp.B[:,m:m],temp.C[n:n,:],temp.D[n:n,m:m])
				ss_eqns,_=decompose(temp_mn)
				try
					result[i].ss_resp[n,m]=-(ss_eqns.C*(ss_eqns.A\ss_eqns.B))[1,1]+ss_eqns.D[1,1]
				catch
					result[i].ss_resp[n,m]=Inf
				end
			end
		end
	end
end

result

end ## Leave


#	result[i].ss_resp=-C*pinv(A)*B+D
# one I/O pair at a time
# detA=det(I*w[j]im-A)
# for m=1:nin
# 	for n=1:nout
# 		result[i].freq_resp[n,m,j]=(det(I*w[j]im-A+B[:,m]*C[n,:]')-detA)/detA+D[n,m]
# 	end
# end
# result[i].zero_val=eigvals([ss_eqns.A ss_eqns.B;ss_eqns.C ss_eqns.D],[ss_eqns.E zeros(ss_eqns.B);zeros(ss_eqns.C) zeros(ss_eqns.D)])

# try
# 	WC=lyap(result[i].ss_eqns.A,result[i].ss_eqns.B*result[i].ss_eqns.B')
# 	WO=lyap(result[i].ss_eqns.A',result[i].ss_eqns.C'*result[i].ss_eqns.C)
# 	result[i].hsv=sqrt.(eigvals(WC*WO))
# catch
# 	tmp=size(result[i].ss_eqns.A,1)
# 	result[i].hsv=zeros(length(tmp))
# end
