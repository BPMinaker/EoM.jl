function minreal_jordan(sys_in,verbose=false)

	AA=sys_in.A
	BB=sys_in.B
	CC=sys_in.C

	verbose && println("Computing Jordan minimal realization...")

	val,vec=eig(AA)
	m=length(val)

	#println(val)

	jvec=vec
	md=real(val)
	ud=zeros(m-1)
	ld=zeros(m-1)

	i=1
	while i<m

		if (val[i]==conj(val[i+1])) && !(val[i]==val[i+1])
			if abs(imag(val[i]))<1e-5
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

	#println(round.(jvec,5))

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

	r=rank(jvec)
	verbose && println("Jordan vector rank is $r, size $m.")

	dpl=Int[]
	i=1
	while r<m && i<m+1
		verbose && println("Basis vectors are not independent.  Checking vector $i...")
		t=rank([jvec[:,1:i-1] jvec[:,i+1:end]])
		#println(t)
		if t==r
			if abs(val[i]-val[i+1])<1e-8
				verbose && println("Vectors $i, $(i+1) identified as redundant.")
				tv=jvec[:,i+1]
				jvec[:,i+1]=pinv([AA-val[i]*eye(m);jvec[:,i]'])*[jvec[:,i];0]
				#println((AA-val[i]*eye(m))*jvec[:,i+1]-jvec[:,i])
				if rank(jvec)<m
					jvec[:,i+1]=tv
					println("Doesn't help.  Undoing...")
				else
					Aj[i,i+1]=1
					push!(dpl,i)
					push!(dpl,i+1)
					verbose && println("Vector $(i+1) replaced.")
					i+=1
				end
			end

			if verbose
				println("Checking factorization...")
				chk=norm(AA-jvec*Aj*inv(jvec))
				if chk<1e-8
					println("Checks ok.")
				else
					println("Problem with factorization!  Check=$(chk).")
				end
			end
		end
		i+=1
		r=rank(jvec)
		verbose && println("Basis vector rank is now $r.")
	end
	#println(dpl)

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
		t=find(abs.(val-val[i]).<1e-10)  ## find all matching eigenvalues
		t=setdiff(t,dpl)  ## remove those that are already identified as repeated roots
		push!(match,t)  ## record the rest
	end
	match=unique(match)  ## find the unique entries
	#println(match)
	#readline(STDIN)

	dup=Int[]
	i=1
	while i<length(match)
		#println(length(match[i]))
		#readline(STDIN)

		if length(match[i])==2

			if (val[match[i][1]]==conj(val[match[i+1][1]]) && val[match[i][1]] != 0)  ## matching pair of roots

				B1=Bjm[match[i][1]:match[i+1][1],:]
				C1=Cjm[:,match[i][1]:match[i+1][1]]
				B2=Bjm[match[i][2]:match[i+1][2],:]
				C2=Cjm[:,match[i][2]:match[i+1][2]]

				H=B1*C1+B2*C2
				nn=B1[1]^2+B1[2]^2+B2[1]^2+B2[2]^2

				mx,ind=findmax(abs.(H))
				w=0
				x=0
				y=0
				z=0

				if ind==1
					y=(nn/((H[2,1]/H[1,1])^2+1))^0.5
					z=(y^2*(H[2,1]/H[1,1])^2)^0.5
					if H[1,1]*H[2,1]<0
						z=-z
					end
					w=H[1,1]/y
					x=H[1,2]/y


				elseif ind==2
					z=(nn/((H[1,1]/H[2,1])^2+1))^0.5
					y=(z^2*(H[1,1]/H[2,1])^2)^0.5
					if H[1,1]*H[2,1]<0
						y=-y
					end
					w=H[2,1]/z
					x=H[2,2]/z

				elseif ind==3
					y=(nn/((H[2,2]/H[1,2])^2+1))^0.5
					z=(y^2*(H[2,2]/H[1,2])^2)^0.5
					if H[1,2]*H[2,2]<0
						z=-z
					end
					w=H[1,1]/y
					x=H[1,2]/y

				elseif ind==4
					z=(nn/((H[1,2]/H[2,2])^2+1))^0.5
					y=(z^2*(H[1,2]/H[2,2])^2)^0.5
					if H[1,2]*H[2,2]<0
						y=-y
					end
					w=H[2,1]/z
					x=H[2,2]/z
				else
					println("Something weird happened")
				end

				H2=[y z]'*[w x]
				err=norm(H-H2)

				if err>1e-7
					Bjm[match[i][2]:match[i+1][2],:]=[0 1;-1 0]*Bjm[match[i][2]:match[i+1][2],:]
					Cjm[:,match[i][2]:match[i+1][2]]=Cjm[:,match[i][2]:match[i+1][2]]*[0 -1;1 0]
					verbose && println("No solution found, attempting rotation of input and outout matrices...")
				else
					Bjm[match[i][1],:]=y
					Bjm[match[i+1][1],:]=z
					Cjm[:,match[i][1]]=w
					Cjm[:,match[i+1][1]]=x
					push!(dup,match[i][2])
					push!(dup,match[i+1][2])
					i+=2
				end
			else ## matching single root
				println("Matching single root, not implemented yet...")
				i+=1
			end
		elseif length(match[i])>2
			println("Multpile matching roots, not implemented yet...")
			i+=1
		else
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
	nind=setdiff(ind,dup)
	#println(nind)

	Ajm=Ajm[nind,nind]
	Bjm=Bjm[nind,:]
	Cjm=Cjm[:,nind]
	m=size(Ajm,1)
	ind=1:m

	u=sum(Bjm.^2,2).^0.5
	v=sum(Cjm.^2,1).^0.5
	sens=u.*(v')
	for i=1:m-1
		if abs(Ajm[i,i+1])>1e-10
			w=abs(v[i]*u[i+1])+abs(v[i+1]*u[i])
			sens[i]+=w
			sens[i+1]+=w
		end
	end
	#println(sens)
	flag=find(sens.>maximum(sens)*1e-5)
	#println(flag)
	t=setdiff(ind,flag)
	if verbose && length(t)>0
		print("Removing non-contributing modes ")
		for i in t
			print("$i, ")
		end
		println("...")
	end

	jordan=ss_data()

	jordan.A=Ajm[flag,flag]
	jordan.B=Bjm[flag,:]
	jordan.C=Cjm[:,flag]
	jordan.D=sys_in.D

	verbose && println("System is now of dimension ",size(jordan.A),".")

	jordan

end


# 	r1=Bjm[match[i][1],:]
# 	r2=Bjm[match[i][2],:]
# 	c1=Cjm[:,match[i][1]]
# 	c2=Cjm[:,match[i][2]]
# 	if (abs(dot(r1,r2))-norm(r1)*norm(r2))<1e-10 && (dot(c1,c2)-norm(c1)*norm(c2))<1e-10
# 		Bjm[match[i][1],:]+=(sign(dot(r1,r2))*Bjm[match[i][2],:])
# 		Cjm[:,match[i][1]]+=(sign(dot(c1,c2))*Cjm[:,match[i][2]])
# 		push!(dup,match[i][2])
# 	end
