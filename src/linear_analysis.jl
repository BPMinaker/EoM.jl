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
wpts=Int(round(1500/vpts))
w=2*pi*logspace(-1,2,wpts)


for i=1:vpts

# 	if(n>2000)  ## If it's really big, then forget it
# 		println("Huge system. Stopping..."')
# 		return
# 	end


		val_tmp,vec_tmp=eig(result[i].A,result[i].E)  ## Find the eigen for this speed
	#	println(val_tmp)
	#	println(vec_tmp)

		result[i].e_val=val_tmp[isfinite(val_tmp)]  ## Discard modes with Inf or Nan vals
		result[i].e_vect=vec_tmp[:,isfinite(val_tmp)]

	#	println(result[i].e_vect)

 		m=size(result[i].e_val)
		#println("Size of e_val is $m")

	#	println(result[i].e_vect(1:m,:))
 	#	vec=1e-6*round(result[i].e_vect(1:m,:)*1e6)

		result[i].AA,result[i].BB,result[i].CC,result[i].DD=dss2ss(result[i].A,result[i].B,result[i].C,result[i].D,result[i].E)


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
