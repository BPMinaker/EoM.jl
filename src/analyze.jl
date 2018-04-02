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
result=Vector{analysis}(nvpts)
lower=zeros(nvpts)
upper=zeros(nvpts)

wpts=500
(wpts*nvpts>4000) && (wpts=Int(round(4000/nvpts)))

for i=1:nvpts
	result[i]=analysis()

	## Reduce to standard form
	result[i].ss_eqns=dss2ss(dss_eqns[i],verbose)

	F=eigfact(dss_eqns[i].A,dss_eqns[i].E)  ## Find the eigen for this speed
#	println(F.values)

	result[i].e_val=F.values[isfinite.(F.values)]  ## Discard modes with Inf or Nan vals
	result[i].e_vect=F.vectors[:,isfinite.(F.values)]

	t=abs.(result[i].e_val)
	lower[i]=minimum(t[t.>1e-6])
	upper[i]=maximum(t)
end

low=floor(log10(0.8*minimum(lower)/2/pi))
(low<-2) && (low=-2)
high=ceil(log10(1.25*maximum(upper)/2/pi))
w=2*pi*logspace(low,high,wpts)

for i=1:nvpts
	result[i].w=w
	nin=size(result[i].ss_eqns.B,2)
	nout=size(result[i].ss_eqns.C,1)

	result[i].freq_resp=zeros(nout,nin,length(w))

#	try
		for j=1:wpts
			result[i].freq_resp[:,:,j]=result[i].ss_eqns.C*((I*w[j]im-result[i].ss_eqns.A)\result[i].ss_eqns.B)+result[i].ss_eqns.D
		end
		result[i].ss_resp=-result[i].ss_eqns.C*(result[i].ss_eqns.A\result[i].ss_eqns.B)+result[i].ss_eqns.D
#	catch
#		for j=1:wpts
#			result[i].freq_resp[:,:,j]=ss_eqns.Cm*pinv(I*w[j]im-ss_eqns.Am)*ss_eqns.Bm+ss_eqns.Dm
#		end
#		result[i].ss_resp=-ss_eqns.Cm*pinv(ss_eqns.Am)*ss_eqns.Bm +ss_eqns.Dm
#	end

	# result[i].zero_val=eigvals([ss_eqns.A ss_eqns.B;ss_eqns.C ss_eqns.D],[ss_eqns.E zeros(ss_eqns.B);zeros(ss_eqns.C) zeros(ss_eqns.D)])

	try
		WC=lyap(result[i].ss_eqns.A,result[i].ss_eqns.B*result[i].ss_eqns.B')
		WO=lyap(result[i].ss_eqns.A',result[i].ss_eqns.C'*result[i].ss_eqns.C)
		result[i].hsv=sqrt.(eigvals(WC*WO))
	catch
		tmp=size(result[i].ss_eqns.A,1)
		result[i].hsv=zeros(length(tmp))
	end

		result[i].modes=dss_eqns[i].phys*result[i].e_vect  ## Convert vector to physical coordinates

# 		for j=1:size(result[i].modes,2)  ## For each mode
# 			if(norm(result[i].modes[:,j])>0)  ## Check for non-zero displacement modes
# #				[~,k]=max(abs(result{i}.eom.modes(:,j)));  ## Find max entry
# #				result{i}.eom.modes(:,j)=result{i}.eom.modes(:,j)/result{i}.eom.modes(k,j);  ## Scale motions to unity by diving by max value, but not abs of max, as complex possible
# 			end
# 		end
#

end

result

end ## Leave
