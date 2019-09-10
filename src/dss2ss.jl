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

# b=norm(B)
# c=norm(C)
#
# B*=(c/b)^0.5
# C*=(b/c)^0.5

rows=find_states(A,B)
cols=find_states(A',C')
states=rows .& cols
idx=findall(states)

ss_eqns=ss_data(A[idx,idx],B[idx,:],C[:,idx],D)

verbose && println("System is now of dimension ",(size(ss_eqns.A)),".")

ss_eqns

end

function find_states(A,B)

sA=abs.(A) .> 1e-9 ## find entries in A that are significant
idx=vec(any(abs.(B) .> 1e-9,dims=2))  ## find excitable rows of B
didx=idx
while any(didx)
	sidx=vec(any(sA[:,findall(didx)],dims=2))  ## find rows of A that are secondary excitable
	didx=sidx.&.~idx  ## isolate only the new entries
	idx=idx.|sidx  ## add new entries to list
end


return idx

end
