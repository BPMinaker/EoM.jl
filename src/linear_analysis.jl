function linear_analysis!(result)
## Copyright (C) 2017, Bruce Minaker
## linear_analysis.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## linear_analysis.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

vpts=length(result)  ## Number of points to plot
wpts=Int(round(2000/vpts))
w=2*pi*logspace(-1,2,wpts)

for i=1:vpts

	result[i].w=w

	val,vec=eig(result[i].A,result[i].E)  ## Find the eigen for this speed
	result[i].e_val=val[isfinite(val)]  ## Discard modes with Inf or Nan vals
	result[i].e_vect=vec[:,isfinite(val)]

	n=size(result[i].Am,1)
	nin=size(result[i].Bm,2)
	nout=size(result[i].Cm,1)

	result[i].freq_resp=zeros(nout,nin,length(w))

	for j=1:wpts
	#	result[i].freq_resp[:,:,j]=result[i].Cm*((I*w[j]im-result[i].Am)\result[i].Bm)+result[i].Dm
		result[i].freq_resp[:,:,j]=result[i].C*((result[i].E*w[j]im-result[i].A)\result[i].B)+result[i].D
	end

	result[i].ss_resp=-result[i].Cm*(result[i].Am\result[i].Bm)+result[i].Dm

	tmp=eigvals(result[i].Am)
	if(sum(real(tmp).>0)==0)
		WC=lyap(result[i].Am,result[i].Bm*result[i].Bm')
		WO=lyap(result[i].Am',result[i].Cm'*result[i].Cm)
		result[i].hsv=sqrt(eigvals(WC*WO))
#		result[i].hsv=zeros(length(tmp))
	else
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

end ## Leave
