function minreal_jordan(sys_in,verbose=false)

	AA=sys_in.A
	BB=sys_in.B
	CC=sys_in.C

	verbose && println("Computing Jordan minimal realization...")

	val,vec=eigen(AA)
	m=length(val)

	## println(val)

	jvec=vec
	md=real(val)
	ud=zeros(m-1)
	ld=zeros(m-1)

	i=1
	while i<m
		if (val[i]==conj(val[i+1])) && !(val[i]==val[i+1])
			if abs(imag(val[i]))<1e-6
				verbose && println("Rounding vectors $i and $(i+1)")
				jvec[:,i]=real(jvec[:,i])
				jvec[:,i+1]=real(jvec[:,i+1])
				val[i]=real(val[i])
				val[i+1]=real(val[i+1])
				i+=1
			else
				verbose && println("Combining vectors $i and $(i+1)")
				jvec[:,i+1]=imag(jvec[:,i])
				jvec[:,i]=real(jvec[:,i])
				ud[i]=imag(val[i])
				ld[i]=-ud[i]
				i+=1
			end
		end
		i+=1
	end

	jvec=real.(jvec)

	# println(round.(jvec,5))

	Aj=diagm(-1=>ld,0=>md,1=>ud)

	# if verbose
	# 	println("Checking factorization...")
	# 	chk=norm(AA-jvec*Aj*pinv(jvec))
	# 	if chk<1e-8
	# 	println("Checks ok.")
	# 	else
	# 		println("Problem with factorization!  Check=$(chk).")
	# 	end
	# end

	match_val=Vector[]
	for i=1:m
		if abs(imag(val[i]))<1e-6  ## if eigenvalue is real
			t=findall(round.(round.(val,digits=5),sigdigits=6).==round.(round(val[i],digits=5),sigdigits=6))  ## find matching values
			length(t)>1 && push!(match_val,t)  ## record them
		end
	end
	match_val=unique(match_val)  ## remove the duplicate entries, if 1 matches 2, then 2 matches 1

	#println(match_val)

	r=rank(round.(jvec,sigdigits=6))  ## round the eigenvectors and find the rank (all vectors same magnitude)
	verbose && println("Jordan vector rank is $r, size $m.")

	for i in match_val
		j=1
		while (j<length(i)+1 && r<m)
			t=rank(round.([jvec[:,1:i[j]-1] jvec[:,i[j]+1:end]],sigdigits=6))  ## find rank with vector removed
			if t==r  ## if removing this vector had no effect on the rank
				verbose && println("Replacing vector $(i[j]+1) with pseudovector...")
				jvec[:,i[j]+1]=pinv([AA-val[i[j]]*diagm(0=>ones(m));jvec[:,i[j]]'])*[jvec[:,i[j]];0]  ## add one row to allow unique solution, pvector must be orthogonal
				Aj[i[j],i[j]+1]=1  ## set entry in A matrix where pvector is located
				j+=1
			end
			chk=norm(AA-jvec*Aj*inv(jvec))  ## confirm factorization is correct
			chk>1e-8 && println("Factorization check=$(chk)...")
			j+=1
			r=rank(round.(jvec,sigdigits=6))  ## recompute rank
			verbose && println("Basis vector rank is now $r.")
		end
	end

	# println(dpl)
	# println(dplb)

	Bjm=(jvec\BB)
	Cjm=(CC*jvec)
	Ajm=Aj

	ind=1:m
	sens=zeros(m)
	i=1
	while i<m+1
		if i<m && Ajm[i,i+1]!=0.0  ## if there are entries to the right, do 2x2 sensitivity
			sens[i]=norm(Cjm[:,i:i+1]*(Int64.((abs.(Ajm[i:i+1,i:i+1])+diagm(0=>ones(2))).>1e-6))*Bjm[i:i+1,:])
			sens[i+1]=sens[i]
			i+=2
		else  ## otherwise, just B and C
			sens[i]=norm(Cjm[:,i:i]*Bjm[i:i,:])
			i+=1
		end
	end

	# println(sens)
	flag=findall(sens.>maximum(sens)*1e-5)  ## find roots where sensitivity is more than 1e-5 times maximum
	# println(flag)

	t=setdiff(ind,flag)
	if verbose && length(t)>0
		print("Removing non-contributing modes ")
		for i in t
			print("$i, ")
		end
		println("...")
	end

	Ajm=Ajm[flag,flag] ## keep only sensitive roots
	Bjm=Bjm[flag,:]
	Cjm=Cjm[:,flag]
	val=val[flag]
	m=length(val)

# println(Ajm)
# println(Bjm)
# println(Cjm)

	match_val=Vector[]
	for i=1:m
		t=findall(round.(round.(val,digits=5),sigdigits=6).==round.(round(val[i],digits=5),sigdigits=6))  ## find matching values
		length(t)>1 && push!(match_val,t)  ## record them
	end
	match_val=unique(match_val)  ## remove the duplicate entries, if 1 matches 2, then 2 matches 1

	println(match_val)

	while i<length(match_val)
		if abs(imag(val[match_val[i][1]]))>1e-6  ## if matching root is complex, skip to next
			i+=1
		elseif Ajm[match_val[i][1],match_val[i][1]+1]==0  ## or if matching root is real and not repeated (pvector), skip to next
			i+=1
		else
			deleteat!(match_val,i)  ## otherwise delete this entry
		end
	end

	println(match_val)

	dup=Int[]
	i=1
	flag=false

	while i<length(match_val)
		if length(match_val[i])==2
			if val[match_val[i][1]]==conj(val[match_val[i+1][1]])  ## matching complex pair, works for siso only

				B1=Bjm[match_val[i][1]:match_val[i+1][1],:]  ## build first B matrix
				C1=Cjm[:,match_val[i][1]:match_val[i+1][1]]  ## build first C matrix
				B2=Bjm[match_val[i][2]:match_val[i+1][2],:]  ## build second B matrix
				C2=Cjm[:,match_val[i][2]:match_val[i+1][2]]  ## build second C matrix

				H=B1*C1+B2*C2
				nn=B1[1]^2+B1[2]^2+B2[1]^2+B2[2]^2

				mx,ind=findmax(abs.(H))

				w=0
				x=0
				y=0
				z=0

				if ind.I==(1,1)
					y=(nn/((H[2,1]/H[1,1])^2+1))^0.5
					z=(y^2*(H[2,1]/H[1,1])^2)^0.5
					if H[1,1]*H[2,1]<0
						z=-z
					end
					w=H[1,1]/y
					x=H[1,2]/y

				elseif ind.I==(2,1)
					z=(nn/((H[1,1]/H[2,1])^2+1))^0.5
					y=(z^2*(H[1,1]/H[2,1])^2)^0.5
					if H[1,1]*H[2,1]<0
						y=-y
					end
					w=H[2,1]/z
					x=H[2,2]/z

				elseif ind.I==(1,2)
					y=(nn/((H[2,2]/H[1,2])^2+1))^0.5
					z=(y^2*(H[2,2]/H[1,2])^2)^0.5
					if H[1,2]*H[2,2]<0
						z=-z
					end
					w=H[1,1]/y
					x=H[1,2]/y

				elseif ind.I==(2,2)
					z=(nn/((H[1,2]/H[2,2])^2+1))^0.5
					y=(z^2*(H[1,2]/H[2,2])^2)^0.5
					if H[1,2]*H[2,2]<0
						y=-y
					end
					w=H[2,1]/z
					x=H[2,2]/z
				else
					error("Something weird happened in Jordan form calcs")
				end

#				H2=[y z]'*[w x]
#				err=norm(H-H2)

				Bjm[match_val[i][1],:].=y  ## compute combined B, C, overwrite first B matrix
				Bjm[match_val[i+1][1],:].=z
				Cjm[:,match_val[i][1]].=w ## overwrite first C matrix
				Cjm[:,match_val[i+1][1]].=x

				push!(dup,match_val[i][2])  ## record which row can be removed
				push!(dup,match_val[i+1][2])  ## record which row can be removed
				i+=2  ## go to next match

			else ## matching single real root, works for mimo

				B1=Bjm[match_val[i][1]:match_val[i][1],:]  ## build first B matrix
				C1=Cjm[:,match_val[i][1]:match_val[i][1]]  ## build first C matrix
				B2=Bjm[match_val[i][2]:match_val[i][2],:]  ## build second B matrix
				C2=Cjm[:,match_val[i][2]:match_val[i][2]]  ## build second C matrix

				Q,S,P=svd([C1 C2]*[B1;B2])  ## Q*S*P' should = G
				if abs(S[1])/norm(S)>0.99
					Bjm[match_val[i][1],:]=P[:,1]' ## compute combined B, C, overwrite first B matrix
					Cjm[:,match_val[i][1]]=Q[:,1]*S[1]  ## overwrite first C matrix
					push!(dup,match_val[i][2])  ## record which row can be removed
				else
					error("Something weird happened in Jordan form calcs")
				end
				i+=1  ## go to next match
			end
		elseif length(match_val[i])>2  ## found multiple mathing roots with no duplicate
			println("Multiple matching roots, not implemented yet...")
			i+=1
		else  ## shouldn't get here?
			i+=1
		end
	end
	if verbose && length(dup)>0
		print("Duplicate roots at ")
		for i in dup
			print("$i, ")
		end
		println("removing and renumbering...")
	end
	ind=1:m
	nind=setdiff(ind,dup)  ## all roots minus duplicate roots are keepers
	#println(nind)

	Ajm=Ajm[nind,nind]  ## removing rows, columns
	Bjm=Bjm[nind,:]
	Cjm=Cjm[:,nind]

	jordan=ss_data()
	jordan.A=Ajm
	jordan.B=Bjm
	jordan.C=Cjm
	jordan.D=sys_in.D

	verbose && println("System is now of dimension ",size(jordan.A),".")

	jordan

end



	# i=1
	# while r<m && i<m+1  ## if not full rank, and not past the end, check each vector
	# 	verbose && println("Basis vectors are not independent.  Checking vector $i...")
	# 	t=rank(round.([jvec[:,1:i-1] jvec[:,i+1:end]],6))  ## find rank with vector removed
	# 	#println(t)
	# 	if t==r  ## if removing this vector had no effect on the rank
	# 		verbose && println("Vector $i identified as redundant...")
	# 		if i<m && abs(val[i]-val[i+1])<1e-6  ## if the roots are repeated
	# 			verbose && println("Found duplicate root...")
	# 			verbose && println("Replacing vector $(i+1) with pseudovector...")
	# 			jvec[:,i+1]=pinv([AA-val[i]*eye(m);jvec[:,i]'])*[jvec[:,i];0]  ## add one row to allow unique solution, pvector must be orthogonal
	# 			Aj[i,i+1]=1  ## set entry in A matrix where pvector is located
	# 			push!(dpl,i)  ## record that this root has a duplicate
	# 			push!(dplb,i+1)  ## record that next root is a duplicate
	# 			dplln[i]=i+1  ## record where the duplicate is located
	# 			i+=1  ## skip extra vector
	# 		end
	# 		chk=norm(AA-jvec*Aj*inv(jvec))  ## confirm factorization is correct
	# 		chk>1e-8 && println("Factorization check=$(chk)...")
	# 	end
	# 	i+=1  ## go to next vector
	# 	r=rank(round.(jvec,6))  ## recompute rank
	# 	verbose && println("Basis vector rank is now $r.")
	# end



	# match_vec=Vector[]
	# for i in match_val  ## for each list of matching values
	# 	verbose && println("Found repeated roots at ",i)
	# 	j=length(i)
	#
	# 	t=abs.(jvec[:,i]'*jvec[:,i])-ones(j,j)  ## dot product of colinear vectors = +/-1
	# 	println(i)
	# 	println(t)
	# 	for k=1:j
	# 		u=findall(abs.(t[:,k]).<1e-6)  ## find the colinear vectors
	# 		push!(match_vec,u)
	# 	end
	# 	match_vec=unique(match_vec)  ## remove the duplicate entries
	# 	println(match_vec)
	# 	sorted=Int64[]
	# 	for k in match_vec
	# 		for n in k
	# 			push!(sorted,i[n])
	# 		end
	# 	end
	# 	jvec[:,i]=jvec[:,sorted]  ## put all colinear vectors with same value next to each other
	# end
