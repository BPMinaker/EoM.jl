function analyze(dss_eqns;verbose=false)
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

verbose && println("Running linear analysis...")

nvpts=length(dss_eqns)  ## Number of points to plot
result=Vector{analysis}(undef,nvpts)
lower=zeros(nvpts)
upper=zeros(nvpts)

wpts=500
(wpts*nvpts>2500) && (wpts=Int(round(2500/nvpts)))

for i=1:nvpts
#	println(i)
	result[i]=analysis()

	result[i].ss_eqns=dss2ss(dss_eqns[i],verbose && i<2)  ## Reduce to standard form
	result[i].jordan=minreal_jordan(result[i].ss_eqns,verbose && i<2)  ## Reduce to minimal Jordan form

	F=eigen(dss_eqns[i].A,dss_eqns[i].E)  ## Find the eigen
#	println(F.values)

	result[i].e_val=F.values[isfinite.(F.values)]  ## Discard modes with Inf or Nan vals
	result[i].e_vect=F.vectors[:,isfinite.(F.values)]

	t=abs.(result[i].e_val)
	lower[i]=minimum(t[t.>1e-6])
	upper[i]=maximum(t)
end

low=floor(log10(0.5*minimum(lower)/2/pi))
(low<-2) && (low=-2)
high=ceil(log10(2.0*maximum(upper)/2/pi))
w=2*pi*(10.0.^range(low,stop=high,length=wpts))

for i=1:nvpts

	result[i].w=w
	nin=size(result[i].ss_eqns.B,2)
	nout=size(result[i].ss_eqns.C,1)
#	nj=size(result[i].jordan.A,1)

	result[i].freq_resp=zeros(nout,nin,length(w))

	# for j=1:wpts
	# 	result[i].freq_resp[:,:,j]=result[i].ss_eqns.C*((I*w[j]im-result[i].ss_eqns.A)\result[i].ss_eqns.B)+result[i].ss_eqns.D
	# end

	for j=1:wpts
		result[i].freq_resp[:,:,j]=result[i].jordan.C*(Tridiagonal(I*w[j]im-result[i].jordan.A)\result[i].jordan.B)+result[i].jordan.D
	end

	try
		result[i].ss_resp=-result[i].jordan.C*(result[i].jordan.A\result[i].jordan.B)+result[i].jordan.D
	catch
		result[i].ss_resp=-result[i].jordan.C*pinv(result[i].jordan.A)*result[i].jordan.B+result[i].jordan.D
	end

	# result[i].zero_val=eigvals([ss_eqns.A ss_eqns.B;ss_eqns.C ss_eqns.D],[ss_eqns.E zeros(ss_eqns.B);zeros(ss_eqns.C) zeros(ss_eqns.D)])

	# try
	# 	WC=lyap(result[i].ss_eqns.A,result[i].ss_eqns.B*result[i].ss_eqns.B')
	# 	WO=lyap(result[i].ss_eqns.A',result[i].ss_eqns.C'*result[i].ss_eqns.C)
	# 	result[i].hsv=sqrt.(eigvals(WC*WO))
	# catch
	# 	tmp=size(result[i].ss_eqns.A,1)
	# 	result[i].hsv=zeros(length(tmp))
	# end

	result[i].modes=dss_eqns[i].phys*result[i].e_vect  ## Convert vector to physical coordinates
	nb=div(size(result[i].modes,1),6)
	nm=size(result[i].modes,2)

	result[i].centre=zeros(size(result[i].modes))

	for j=1:nm  ## For each mode
		if norm(result[i].modes[:,j])>0  ## Check for non-zero displacement modes
			temp,k=findmax(abs.(result[i].modes[:,j]))  ## Find max entry
			result[i].modes[:,j]/=result[i].modes[k,j]  ## Scale motions to unity by diving by max value, but not abs of max, as complex possible
		end

		for k=1:nb  ## For each body
			mtn=result[i].modes[6*k.+(-5:0),j]  ## motion of body k
			temp,l=findmax(abs.(mtn))
			phi=angle(mtn[l])
			mtn*=exp(-phi*1im)  ## Remove unnecessary imag parts

			result[i].centre[6*k.+(-5:0),j]=[-pinv(skew(mtn[4:6]))*mtn[1:3];mtn[4:6]/(norm(mtn[4:6])+eps(1.))]
			## Radius to the instantaneous center of rotation of the body (rad=omega\v)
		end
	end
end

result

end ## Leave
