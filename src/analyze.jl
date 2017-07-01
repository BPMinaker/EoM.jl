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
wpts=500
if(wpts*nvpts>4000)
	wpts=Int(round(4000/nvpts))
end
w=2*pi*logspace(-1,2,wpts)

result=Vector{analysis}(nvpts)

for i=1:nvpts

	result[i]=analysis()
	result[i].w=w

	val,vec=eig(ss_eqns[i].A,ss_eqns[i].E)  ## Find the eigen for this speed
	result[i].e_val=val[isfinite.(val)]  ## Discard modes with Inf or Nan vals
	result[i].e_vect=vec[:,isfinite.(val)]

	nin=size(ss_eqns[i].B,2)
	nout=size(ss_eqns[i].C,1)

	result[i].freq_resp=zeros(nout,nin,length(w))
	for j=1:wpts
		result[i].freq_resp[:,:,j]=ss_eqns[i].Cm*((I*w[j]im-ss_eqns[i].Am)\ss_eqns[i].Bm)+ss_eqns[i].Dm
		#result[i].freq_resp[:,:,j]=ss_eqns[i].Ct*((I*w[j]im-ss_eqns[i].At)\ss_eqns[i].Bt)+ss_eqns[i].Dt
		#result[i].freq_resp[:,:,j]=ss_eqns[i].C*((ss_eqns[i].E*w[j]im-ss_eqns[i].A)\ss_eqns[i].B)+ss_eqns[i].D
	end

	result[i].ss_resp=-ss_eqns[i].Cm*(ss_eqns[i].Am\ss_eqns[i].Bm)+ss_eqns[i].Dm
	#result[i].ss_resp=-ss_eqns[i].Ct*(ss_eqns[i].At\ss_eqns[i].Bt)+ss_eqns[i].Dt

	# result[i].zero_val=eigvals([ss_eqns[i].A ss_eqns[i].B;ss_eqns[i].C ss_eqns[i].D],[ss_eqns[i].E zeros(ss_eqns[i].B);zeros(ss_eqns[i].C) zeros(ss_eqns[i].D)])

	tmp=size(ss_eqns[i].Am,1)
#	tmp=eigvals(ss_eqns[i].Am)
#	if(sum(real(tmp).>0)==0 && length(tmp)>1)

	try
		WC=lyap(ss_eqns[i].Am,ss_eqns[i].Bm*ss_eqns[i].Bm')
		WO=lyap(ss_eqns[i].Am',ss_eqns[i].Cm'*ss_eqns[i].Cm)
		result[i].hsv=sqrt.(eigvals(WC*WO))
	catch
		result[i].hsv=zeros(length(tmp))
	end

# 		if(vpts<10)
#			r=rank(vec)
# 			if(r<m)
# 				println("Vectors are not unique!")
# 				if(r==(m-1))
# 					println("Trying to replace redundant vector...")
#
# 					for j=1:m
# 						temp=vec
# 						temp[:,j]=[]
# 						t=rank(temp)
# 						if(t==r)
# 							bb=j
# 						end
# 					end
# 					result[i].vect[:,bb]=pinv(result[i].A-result[i].val[bb]*result[i].E)*(result[i].E*result[i].vect[:,bb])
# 				end
# 			end
#		end
#
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
