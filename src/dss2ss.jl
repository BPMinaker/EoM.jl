function dss2ss(dss_eqns,verbose=false)

verbose && println("System is of dimension ",size(dss_eqns.A),".")
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

val,vect=eigen(A)

if rank(vect)<size(vect,2)
	verbose && println("Eigenvectors are defective.  Attempting minimization anyway...")
end

idx_c=vec(any(abs.(vect'*B) .> 1e-6,dims=2))  # controllable
idx_o=vec(any(abs.(vect'*C') .> 1e-6,dims=2))  # observeable
idx=(idx_c .& idx_o)  ## find c & o
vectl=vect[:,idx]  ## keep only those

val,vect=eigen(copy(A'))  ## find right vectors using A'
vect=conj(vect)

vectr=vect[:,idx]
val=val[idx]  ## keep only the min e-vals

m=length(val)
md=real(val)
ud=zeros(m-1)  # preallocate
ld=zeros(m-1)

i=1
while i <= m  ## for each eigenvalue
	temp=vectr[:,i]'*vectl[:,i]

	if isreal(val[i])
		vectr[:,i]/=temp
		i+=1
	else
		vectr[:,i]*=temp/norm(temp)^2
		root2=(2.)^0.5
		vectr[:,i]*=root2
		vectl[:,i]*=root2

		vectr[:,i+1]=imag(vectr[:,i])
		vectl[:,i+1]=imag(vectl[:,i])
		vectr[:,i]=real(vectr[:,i])
		vectl[:,i]=real(vectl[:,i])

		ud[i]=imag(val[i])
		ld[i]=-ud[i]
		i+=2
	end
end

Am=diagm(-1=>ld,0=>md,1=>ud)
Bm=vectr'*B
Cm=C*vectl

verbose && println("System is now of dimension ",(size(Am)),".")
ss_eqns=ss_data(Am,Bm,Cm,D)

ss_eqns

end



# b=norm(B)
# c=norm(C)
#
# B*=(c/b)^0.5
# C*=(b/c)^0.5

# rows=find_states(A,B)
# cols=find_states(A',C')
# states=rows .& cols
# idx=findall(states)
#
# ss_eqns=ss_data(A[idx,idx],B[idx,:],C[:,idx],D)

# verbose && println("System is now of dimension ",(size(A)),".")


# function find_states(A,B)
#
# sA=abs.(A) .> 1e-9 ## find entries in A that are significant
# idx=vec(any(abs.(B) .> 1e-9,dims=2))  ## find excitable rows of B
# didx=idx
# while any(didx)
# 	sidx=vec(any(sA[:,findall(didx)],dims=2))  ## find rows of A that are secondary excitable
# 	didx=sidx.&.~idx  ## isolate only the new entries
# 	idx=idx.|sidx  ## add new entries to list
# end
#
#
# return idx
#
# end
