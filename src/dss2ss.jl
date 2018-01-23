function dss2ss!(ss_eqns,verbose=false)

verbose && println("System is of dimension ",size(ss_eqns.A),".")
verbose && println("Converting from descriptor form to standard state space...")

Q,S,P=svd(ss_eqns.E)  ##Q'*E*P should = S
#println(S)
S=S[S.>(maximum(size(ss_eqns.E))*eps(maximum(S)))]
n=length(S)
Sinv=diagm(1./S)

Atilde=Q'*ss_eqns.A*P
Btilde=Q'*ss_eqns.B
Ctilde=ss_eqns.C*P

A11=Atilde[1:n,1:n]
A12=Atilde[1:n,n+1:end]
A21=Atilde[n+1:end,1:n]
A22=Atilde[n+1:end,n+1:end]

B1=Btilde[1:n,:]
B2=Btilde[n+1:end,:]

C1=Ctilde[:,1:n]
C2=Ctilde[:,n+1:end]

# println("det ",det(A22))
# println("rank ",rank(A22))
# println("size ",size(A22))

A22i=pinv(A22)
#println(A22i)

AA=Sinv*(A11-A12*A22i*A21)
BB=Sinv*(B1-A12*A22i*B2)
CC=C1-C2*A22i*A21
DD=ss_eqns.D-C2*A22i*B2

#println(AA,BB,CC,DD)

ss_eqns.At=AA
ss_eqns.Bt=BB
ss_eqns.Ct=CC
ss_eqns.Dt=DD

verbose && println("System is now of dimension ",(size(AA)),".")
verbose && println("Computing minimal realization...")

val,vec=eig(AA)
m=length(val)

# println(val)
# println(vec)

## convert to Jordan form

# t=sortrows([val vec'])
#
# val=t[:,1]
# jvec=t[:,2:end]'

#println(val)

jvec=vec
md=real(val)
ud=zeros(m-1)
ld=zeros(m-1)

i=1
while i<m
	if (val[i]==conj(val[i+1])) && !(val[i]==val[i+1])
		verbose && println("Combining vectors $i and $(i+1)")
		jvec[:,i+1]=imag(jvec[:,i])
		jvec[:,i]=real(jvec[:,i])
		ud[i]=imag(val[i])
		ld[i]=-ud[i]
		i+=1
	end
	i+=1
end

#println(round.(jvec,5))

Aj=Tridiagonal(ld,md,ud)

if verbose
	println("Checking factorization...")
	chk=norm(AA-jvec*Aj*pinv(jvec))
	if chk<1e-8
	println("Checks ok.")
	else
		println("Problem with factorization!  Check=$(chk).")
	end
end

r=rank(jvec)
verbose && println("Jordan vector rank is $r, size $m.")

dpl=Int[]
i=1
while r<m && i<m+1
	verbose && println("Basis vectors are not independent.")
	t=rank([jvec[:,1:i-1] jvec[:,i+1:end]])
	#println(t)
	if t==r
		if abs(val[i]-val[i+1])<1e-8
			verbose && println("Vectors $i, $(i+1) identified as redundant.")
			tv=jvec[:,i+1]
			jvec[:,i+1]=pinv(AA-val[i]*eye(m))*jvec[:,i]
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

ss_eqns.Aj=Aj
ss_eqns.Bj=(jvec\BB)
ss_eqns.Cj=(CC*jvec)
ss_eqns.Dj=DD

Ajm=ss_eqns.Aj
Bjm=ss_eqns.Bj
Cjm=ss_eqns.Cj

match=Vector[]
for i=1:m
	t=find(abs.(val-val[i]).<1e-10)
	t=setdiff(t,dpl)
	push!(match,t)
end
match=unique(match)
#println(match)

dup=Int[]
for i=1:length(match)
	if length(match[i])==2
		r1=Bjm[match[i][1],:]
		r2=Bjm[match[i][2],:]
		c1=Cjm[:,match[i][1]]
		c2=Cjm[:,match[i][2]]
		if (abs(dot(r1,r2))-norm(r1)*norm(r2))<1e-10 && (dot(c1,c2)-norm(c1)*norm(c2))<1e-10
			Bjm[match[i][1],:]+=(sign(dot(r1,r2))*Bjm[match[i][2],:])
			Cjm[:,match[i][1]]+=(sign(dot(c1,c2))*Cjm[:,match[i][2]])
			push!(dup,match[i][2])
		end
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

ss_eqns.Am=Ajm[flag,flag]
ss_eqns.Bm=Bjm[flag,:]
ss_eqns.Cm=Cjm[:,flag]
ss_eqns.Dm=DD

verbose && println("System is now of dimension ",size(ss_eqns.Am),".")

# else
# 	println("No observable and controllable modes found.")
# end

end
