function analyze(ss_eqns;verbose=false)
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

nvpts=length(ss_eqns)  ## Number of points to plot
result=Vector{analysis}(nvpts)
lower=zeros(nvpts)
upper=zeros(nvpts)

wpts=500
(wpts*nvpts>4000) && (wpts=Int(round(4000/nvpts)))

for i=1:nvpts
	result[i]=analysis()

	F=eigfact(ss_eqns[i].A,ss_eqns[i].E)  ## Find the eigen for this speed
#	println(F.values)

	result[i].e_val=F.values[isfinite.(F.values)]  ## Discard modes with Inf or Nan vals
	result[i].e_vect=F.vectors[:,isfinite.(F.values)]

	lower[i]=minimum(abs.(result[i].e_val))
	upper[i]=maximum(abs.(result[i].e_val))
end

low=floor(log10(minimum(lower)/2/pi))
(low<-2) && (low=-2)
high=ceil(log10(maximum(upper)/2/pi))
w=2*pi*logspace(low,high,wpts)

for i=1:nvpts
	result[i].w=w
	nin=size(ss_eqns[i].B,2)
	nout=size(ss_eqns[i].C,1)

	result[i].freq_resp=zeros(nout,nin,length(w))

	if size(ss_eqns[i].Am)==(0,0)
		for j=1:wpts
			result[i].freq_resp[:,:,j]=ss_eqns[i].Ct*((I*w[j]im-ss_eqns[i].At)\ss_eqns[i].Bt)+ss_eqns[i].Dt
		end
		result[i].ss_resp=-ss_eqns[i].Ct*(ss_eqns[i].At\ss_eqns[i].Bt)+ss_eqns[i].Dt
	else
		for j=1:wpts
			result[i].freq_resp[:,:,j]=ss_eqns[i].Cm*((I*w[j]im-ss_eqns[i].Am)\ss_eqns[i].Bm)+ss_eqns[i].Dm
	#		result[i].freq_resp[:,:,j]=ss_eqns[i].C*((ss_eqns[i].E*w[j]im-ss_eqns[i].A)\ss_eqns[i].B)+ss_eqns[i].D
		end
		result[i].ss_resp=-ss_eqns[i].Cm*(ss_eqns[i].Am\ss_eqns[i].Bm)+ss_eqns[i].Dm
	end

	# result[i].zero_val=eigvals([ss_eqns[i].A ss_eqns[i].B;ss_eqns[i].C ss_eqns[i].D],[ss_eqns[i].E zeros(ss_eqns[i].B);zeros(ss_eqns[i].C) zeros(ss_eqns[i].D)])

	tmp=size(ss_eqns[i].At,1)

	try
		WC=lyap(ss_eqns[i].At,ss_eqns[i].Bt*ss_eqns[i].Bt')
		WO=lyap(ss_eqns[i].At',ss_eqns[i].Ct'*ss_eqns[i].Ct)
		result[i].hsv=sqrt.(eigvals(WC*WO))
	catch
		result[i].hsv=zeros(length(tmp))
	end


# 		result[i].modes=result[i].phys*result[i].vect  ## Convert vector to physical coordinates
#
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
