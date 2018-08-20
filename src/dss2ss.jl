function dss2ss(dss_eqns,verbose=false)

verbose && println("System is of dimension ",size(dss_eqns.A),".")
verbose && println("Converting from descriptor form to standard state space...")

Q,S,P=svd(dss_eqns.E)  ##Q'*E*P should = S
#println(S)
S=S[S.>(maximum(size(dss_eqns.E))*eps(maximum(S)))]
n=length(S)
Sinv=diagm(1.0 ./S)

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

# println("det ",det(A22))
# println("rank ",rank(A22))
# println("size ",size(A22))

A22i=pinv(A22)
#println(A22i)

ss_eqns=ss_data()

ss_eqns.A=Sinv*(A11-A12*A22i*A21)
ss_eqns.B=Sinv*(B1-A12*A22i*B2)
ss_eqns.C=C1-C2*A22i*A21
ss_eqns.D=dss_eqns.D-C2*A22i*B2

verbose && println("System is now of dimension ",(size(ss_eqns.A)),".")

ss_eqns

end
