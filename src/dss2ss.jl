function dss2ss(dss_eqns,verbose=false)

verbose && println("System is of dimension ",size(dss_eqns.A,1),".")
verbose && println("Converting from descriptor form to standard state space...")

Q,S,P=svd(dss_eqns.E)  ##Q'*E*P should = S

S=S[S.>(maximum(size(dss_eqns.E))*eps(maximum(S)))]
n=length(S)
Sinv=diagm(0=>1.0 ./S)

Atilde=Q'*dss_eqns.A*P
Btilde=Q'*dss_eqns.B
Ctilde=dss_eqns.C*P

A11=Atilde[1:n,1:n]
A12=Atilde[1:n,n+1:end]
A21=Atilde[n+1:end,1:n]
A22=Atilde[n+1:end,n+1:end]

B1=Btilde[1:n,:]
B2=Btilde[n+1:end,:]

C1=Ctilde[:,1:n]
C2=Ctilde[:,n+1:end]

A221=A22\A21
A22B=A22\B2

A=Sinv*(A11-A12*A221)
B=Sinv*(B1-A12*A22B)
C=C1-C2*A221
D=dss_eqns.D-C2*A22B

# display(A)
# display(B)
# display(C)

n=size(A,1)
verbose && println("System is now of dimension ",n,".")
verbose && println("Attemping to minimize the order...")

ud=zeros(n)
ld=zeros(n)

verbose && println("Finding left eigenvectors...")

vall,vectl=eigen(copy(A'))  ## find left eigenvectors using A'
vectl=conj(vectl)
#display(vall)
#display(round.(vectl,digits=9))
vall,vectl=group_vals(vall,vectl)
#display(vall)
#display(round.(vectl,digits=9))
sl=check_vecs!(vall,vectl,copy(A'),left=true,verbose=verbose)
#display(vall)
#display(round.(vectl,digits=9))

val,vectr=eigen(A)  ## find the right eigenvectors using A
val,vectr=group_vals(val,vectr)

#display(val)
#display(round.(vectr,digits=9))

sr=check_vecs!(val,vectr,A,left=false,verbose=verbose)
# println("sr",sr)

#display(val)
#display(round.(vectr,digits=9))

#temp=vectl'*vectr
#println("temp l*r")
#display(temp)

for i=1:length(sr)
	ud[sr[i]-1]=1.0
end

na=norm(A)
K=rand(size(B,2),size(C,1))
BKC=B*K*C
nk=norm(BKC)
BKC*=na/nk
valk=eigvals(A+BKC)  ## find eigs of A+BKC
#println("val")
#display(val)
#println("valk")
#display(valk)

n=length(val)  ## find matching values in A, A+BKC
idx=fill(true,n)  ## we keep all vecs
for i=1:n
	for j=1:n
		if abs(val[i]-valk[j])<1e-5  ## remove the ones that match
			idx[i]=false
			valk[j]=NaN
			break
		end
	end
end
# println("idx",idx)

vectr=vectr[:,idx]  ## keep only those vecs that are minimal
# note that this is wrong!!!! if we have repeated oscillatory roots!!!!!
vectl=vectl[:,idx]
val=val[idx]  ## keep only the min e-vals
ud=ud[idx]
ld=ld[idx]

ud=ud[1:end-1]
ld=ld[1:end-1]

md=real(val)
m=length(val)

root2=(2.)^0.5
i=1
while i<=m  ## for each eigenvalue
	temp=vectl[:,i]'*vectr[:,i]
	if isreal(val[i])
		vectl[:,i]/=temp
		i+=1
	else
		vectl[:,i]*=temp/norm(temp)^2
		vectl[:,i]*=root2
		vectr[:,i]*=root2

		vectl[:,i+1]=imag(vectl[:,i])  ## set _next_ vector to imag
		vectl[:,i]=real(vectl[:,i])  ## keep only real _this_ vector
		vectr[:,i+1]=imag(vectr[:,i])
		vectr[:,i]=real(vectr[:,i])

		ud[i]=imag(val[i])
		ld[i]=-ud[i]
		i+=2
	end
end

if norm(round.(vectl'*vectr,digits=3)-I) < 1e-3
	verbose && println("Decomposition appears ok...")
end

#display(round.(vectl'*A*vectr-diagm(-1=>ld,0=>md,1=>ud),digits=5))

A=diagm(-1=>ld,0=>md,1=>ud)
B=vectl'*B
C=C*vectr

b=norm(B)
c=norm(C)
B*=(c/b)^0.5
C*=(b/c)^0.5

B=round.(B,digits=9)
C=round.(C,digits=9)

verbose && println("System is now of dimension ",m,".")
ss_eqns=ss_data(A,B,C,D)

ss_eqns,val

end

function group_vals(val,vect)
	p=sortperm(round.(val,digits=5),by=x->(isreal(x),real(x)>0,abs(round(x,digits=5)),real(x),-imag(x)))
	val=val[p]
	vect=vect[:,p]
#	display(val)
	n=length(val)
	temp=diff(round.(val,digits=5))
	p=vcat(0,findall(temp.!=0),n)

#	println("p,",p)
	temp=vect'*vect
#	println("temp")
#	display(temp)
	q=[]
	i=1
	while i<length(p)
		if p[i+1]-p[i]==1 && p[i]+1<n && val[p[i]+1]==conj(val[p[i]+2]) && imag(val[p[i]+1])!=0
			q=vcat(q,p[i]+1,p[i]+2)
			i+=1
		else
			temp2=sort(temp[p[i]+1:p[i+1],p[i]+1:p[i+1]],dims=2,by=x->-abs(x))
			if size(temp2,2)>1
				q=vcat(q,sortperm(temp2[:,2],by=x->(-abs(x))).+p[i])
			else
				q=vcat(q,p[i]+1)
			end
		end
		i+=1
	end
#	println("q ",q)
	val=val[q]
	vect=vect[:,q]

	val,vect

end


function check_vecs!(val,vect,A;left=false,verbose=true)

n=size(vect,2)
r=rank(vect,atol=1e-8)
d=n-r
s=Int.([])

if d>0
	verbose && println("Rank ",r,", eigenvectors are defective.  Attempting minimization anyway...")
	idx=ones(n).==1
	idx[2]=false
	i=2
	while i<=n
		if val[i]==val[i-1]
			t=rank(vect[:,idx],atol=1e-8)  ## rank without this vector
			if t==r  ## if removing this vector has no effect, replace it
				push!(s,i)
				############################# still issue here for 3 roots
				if left  ## swap left or right
					j=i-1
					k=i
				else
					j=i
					k=i-1
				end
				temp=vect[:,j]  ## save for later in case
				vect[:,j]=([A-val[i]*I;vect[:,k]'])\[vect[:,k];0]  ## replace
				q=rank(vect,atol=1e-8)  ## find new rank
				verbose && println("Defective vector $j replaced. Rank now ",q,".")
				if q==t  ## if no help
					verbose && println("Replacement ineffective, reversing...")
					vect[:,j]=temp
					pop!(s)
					d+=1
					r-=1
				end
				d-=1
				r+=1
				if d==0
					i=n
				end
			end
		end
		circshift!(idx,1)
		i+=1
	end
end

s
end


# for i=1:n
# 	max,ind=findmax(abs.(temp[:,i]))
# 	if ind!=i
# 		max,ind=findmax(abs.(temp[i,:]))
# 		if val[i]==val[ind]
# 			verbose && println("Reordering left eigenvectors...")
# 			vectl[:,[i,ind]]=circshift(vectl[:,[i,ind]],(0,1))
# 			temp=vectl'*vectr
# 		else
# 			verbose && println("Something might be wrong with decomposition...")
# 		end
# 	end
# end




# for i=1:length(sr)
# 	ud[sr[i]-1]=1.0
# 	if idx[sr[i]]  ## if a pseudo vector is controllable and observeable
# 		idx[sr[i]-1]=true  ## keep its origin vector too
# 	end
# 	if idx_c[sr[i]] && idx_o[sr[i]-1] || idx_o[sr[i]] && idx_c[sr[i]-1]
# 		## if a pseudo vector is controllable or observeable, and
# 		## its origin vector is opposite, keep both
# 		idx[sr[i]]=true  ## keep its origin vector too
# 		idx[sr[i]-1]=true
# 	end
# end
