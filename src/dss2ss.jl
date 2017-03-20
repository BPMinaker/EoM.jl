function dss2ss(A,B,C,D,E,lim=1e-10)

Q,S,P=svd(E)

#Q'*E*P should = S

S=S[S.>lim]
n=length(S)
Sinv=diagm(1./S)

Atilde=Q'*A*P
Btilde=Q'*B
Ctilde=C*P

A11=Atilde[1:n,1:n]
A12=Atilde[1:n,n+1:end]
A21=Atilde[n+1:end,1:n]
A22=Atilde[n+1:end,n+1:end]

B1=Btilde[1:n,:]
B2=Btilde[n+1:end,:]

C1=Ctilde[:,1:n]
C2=Ctilde[:,n+1:end]

A22inv=inv(A22)

AA=Sinv*(A11-A12*A22inv*A21)
BB=Sinv*(B1-A12*A22inv*B2)
CC=C1-C2*A22inv*A21
DD=D-C2*A22inv*B2

n=size(AA,1)
nin=size(BB,2)
nout=size(CC,1)

CM=zeros(n,n*nin)
OM=zeros(n*nout,n)

for i=0:(n-1)
	CM[:,i*nin+1:i*nin+nin]=AA^i*BB
	OM[i*nout+1:i*nout+nout,:]=CC*AA^i
end

MR=OM*CM
MR1=OM*AA*CM

U,S,V=svd(MR)

S=S[S.>lim]
p=length(S)
Si=diagm(S.^-0.5)
S=diagm(S.^0.5)

Un=U[:,1:p]
Vn=V[:,1:p]

Am=Si*Un'*MR1*Vn*Si
Bm=(S*Vn')[:,1:nin]
Cm=(Un*S)[1:nout,:]
Dm=DD

Am,Bm,Cm,Dm
end
