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

	# println(round.(jvec,5))

	Aj=Tridiagonal(ld,md,ud)

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

	match_vec=Vector[]
	for i in match_val  ## for each list of matching values
		verbose && println("Found repeated roots at ",i)
		j=length(i)
		if j>2
			t=abs.(jvec[:,i]'*jvec[:,i])-ones(j,j)  ## dot product of colinear vectors = +/-1
			for k=1:j
				u=findall(abs.(t[:,k]).<1e-6)  ## find the colinear vectors
				push!(match_vec,u)
			end
			match_vec=unique(match_vec)  ## remove the duplicate entries
			sorted=Int64[]
			for k in match_vec
				for n in k
					push!(sorted,i[n])
				end
			end
			jvec[:,i]=jvec[:,sorted]  ## put all colinear vectors with same value next to each other
		end
	end

	r=rank(round.(jvec,sigdigits=6))  ## round the eigenvectors and find the rank (all vectors same magnitude)
	verbose && println("Jordan vector rank is $r, size $m.")

	dpl=Int64[]
	dplb=Int64[]
	dplln=Int64.(zeros(m))

	for i in match_val
		j=1
		while (j<length(i)+1 && r<m)
			t=rank(round.([jvec[:,1:i[j]-1] jvec[:,i[j]+1:end]],sigdigits=6))  ## find rank with vector removed
			if t==r  ## if removing this vector had no effect on the rank
				verbose && println("Replacing vector $(i[j]+1) with pseudovector...")
				jvec[:,i[j]+1]=pinv([AA-val[i[j]]*Matrix(1.0I,m,m);jvec[:,i[j]]'])*[jvec[:,i[j]];0]  ## add one row to allow unique solution, pvector must be orthogonal
				Aj[i[j],i[j]+1]=1  ## set entry in A matrix where pvector is located
				push!(dpl,i[j])  ## record that this root has a duplicate
				push!(dplb,i[j]+1)  ## record that next root is a duplicate
				dplln[i[j]]=i[j]+1  ## record where the duplicate is located
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

	####
	jvec=real.(jvec)
	#####

	Bjm=(jvec\BB)
	Cjm=(CC*jvec)

	Ajm=Aj

# println(Ajm)
# println(Bjm)
# println(Cjm)

	match=Vector[]
	for i=1:m
		t=findall(abs.(val.-val[i]).<1e-6)  ## find all matching eigenvalues
#		if contains(==,dpl,i)  ## if this root has a duplicate
		if any((y->begin ==(y,dpl) end),i)
			t=setdiff(t,dplb)  ## remove all duplcate roots
		elseif any((y->begin ==(y,dplb) end),i)
			#contains(==,dplb,i)  ## or if this root is a duplcate
			t=setdiff(t,dpl)  ## remove all the originals
		end
		push!(match,t)  ## record the rest
	end
	match=unique(match)  ## remove the duplicate entries, if 1 matches 2, then 2 matches 1
	# println(match)

	dup=Int[]
	i=1
	flag=false

	while i<length(match)
		# println(i)
		# println(match[i])
		# readline(STDIN)

		if length(match[i])==2  ## matching complex or duplicate root, works for siso
			if (val[match[i][1]]==conj(val[match[i+1][1]]) || dplln[match[i][1]]==match[i+1][1])  ## matching pair of roots or duplicate

				B1=Bjm[match[i][1]:match[i+1][1],:]  ## build first B matrix
				C1=Cjm[:,match[i][1]:match[i+1][1]]  ## build first C matrix
				B2=Bjm[match[i][2]:match[i+1][2],:]  ## build second B matrix
				C2=Cjm[:,match[i][2]:match[i+1][2]]  ## build second C matrix

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

				Bjm[match[i][1],:].=y  ## compute combined B, C, overwrite first B matrix
				Bjm[match[i+1][1],:].=z
				Cjm[:,match[i][1]].=w ## overwrite first C matrix
				Cjm[:,match[i+1][1]].=x

				push!(dup,match[i][2])  ## record which row can be removed
				push!(dup,match[i+1][2])  ## record which row can be removed
				i+=2  ## go to next match

			else ## matching single real root, works for mimo

				B1=Bjm[match[i][1]:match[i][1],:]  ## build first B matrix
				C1=Cjm[:,match[i][1]:match[i][1]]  ## build first C matrix
				B2=Bjm[match[i][2]:match[i][2],:]  ## build second B matrix
				C2=Cjm[:,match[i][2]:match[i][2]]  ## build second C matrix

				Q,S,P=svd([C1 C2]*[B1;B2])  ## Q*S*P' should = G
				if abs(S[1])/norm(S)>0.99
					Bjm[match[i][1],:]=P[:,1]' ## compute combined B, C, overwrite first B matrix
					Cjm[:,match[i][1]]=Q[:,1]*S[1]  ## overwrite first C matrix
					push!(dup,match[i][2])  ## record which row can be removed
				else
					error("Something weird happened in Jordan form calcs")
				end
				i+=1  ## go to next match
			end
		elseif length(match[i])>2  ## found multiple mathing roots with no duplicate
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
	m=size(Ajm,1)
	ind=1:m

	sens=zeros(m)
	i=1
	while i<m+1
		if i<m && abs(Ajm[i,i]-Ajm[i+1,i+1])<1e-6  ## if the roots are repeated
			sens[i]=norm(Cjm[:,i:i+1]*(Int64.((abs.(Ajm[i:i+1,i:i+1])+Matrix(1.0I,2,2)).>1e-6))*Bjm[i:i+1,:])
			sens[i+1]=sens[i]
			#Q,S,P=svd([Cjm[:,i:i+1]; Cjm[:,i:i+1]*Ajm[i:i+1,i:i+1]]*[Bjm[i:i+1,:] Ajm[i:i+1,i:i+1]*Bjm[i:i+1,:]])
			#sens[i]=S[1]
			#sens[i+1]=S[2]
			i+=2
		else
			sens[i]=norm(Cjm[:,i:i]*Bjm[i:i,:])
			#Q,S,P=svd([Cjm[:,i:i]; Cjm[:,i:i]*Ajm[i:i,i:i]]*[Bjm[i:i,:] Ajm[i:i,i:i]*Bjm[i:i,:]])
			#sens[i]=S[1]
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

	jordan=ss_data()

	jordan.A=Ajm[flag,flag]  ## keep only sensitive roots
	jordan.B=Bjm[flag,:]
	jordan.C=Cjm[:,flag]
	jordan.D=sys_in.D

	verbose && println("System is now of dimension ",size(jordan.A),".")

	jordan

end


# 			Bjm[match[i][1],:]=1.0  ## compute combined B, C, overwrite first B matrix
# 			Bjm[match[i+1][1],:]=0.0
# 			Cjm[:,match[i][1]]=[C1 C2]*[B1;B2]  ## overwrite first C matrix
# 			Cjm[:,match[i+1][1]]=det([C1;B1'])+det([C2;B2'])


# u=sum(Bjm.^2,2).^0.5  ## compute input sensitivity
# v=sum(Cjm.^2,1).^0.5  ## compute output sensitivity
# sens=u.*(v')
# for i=1:m-1
# 	if abs(Ajm[i,i+1])>1e-10  ## if off diagonal elements, compute cross sensitivity
# 		w=abs(v[i]*u[i+1])+abs(v[i+1]*u[i])
# 		sens[i]+=w
# 		sens[i+1]+=w
# 	end
# end



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
