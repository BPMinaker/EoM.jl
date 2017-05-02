function dss2ss!(data,verb)

verb && println("System is of dimension $(size(data.A)).")
verb && println("Converting from descriptor form to standard state space...")

Q,S,P=svd(data.E)  ##Q'*E*P should = S
S=S[S.>(maximum(size(data.E))*eps(maximum(S)))]
n=length(S)
Sinv=diagm(1./S)

Atilde=Q'*data.A*P
Btilde=Q'*data.B
Ctilde=data.C*P

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
DD=data.D-C2*A22inv*B2

data.At=AA;
data.Bt=BB;
data.Ct=CC;
data.Dt=DD;

verb && println("System is now of dimension $(size(AA)).")
verb && println("Computing minimal realization...")

n=size(AA,1)
nin=size(BB,2)
nout=size(CC,1)

CM=zeros(n,n*nin)
OM=zeros(n*nout,n)

AAA=AA/sum(diag(AA))

temp=eye(n)
U=0
S=0
V=0
p=0
for i=1:n
	CM[:,(i-1)*nin+1:i*nin]=temp*BB
	OM[(i-1)*nout+1:i*nout,:]=CC*temp
	temp*=AAA

	MR=OM*CM
	U,S,V=svd(MR)
	S=S[S.>(maximum(size(MR))*eps(maximum(S)))]
	p=length(S)

	if(p<i && p>0)
		break
	end
end

CM=zeros(n,n*nin)
OM=zeros(n*nout,n)
temp=eye(n)

for i=1:p
	CM[:,(i-1)*nin+1:i*nin]=temp*BB
	OM[(i-1)*nout+1:i*nout,:]=CC*temp
	temp*=AA
end

MR=OM*CM
U,S,V=svd(MR)
S=S[1:p]

MR1=OM*AA*CM
Si=diagm(S.^-0.5)
S=diagm(S.^0.5)

Un=U[:,1:p]
Vn=V[:,1:p]

data.Am=Si*Un'*MR1*Vn*Si
data.Bm=(S*Vn')[:,1:nin]
data.Cm=(Un*S)[1:nout,:]
data.Dm=DD

verb && println("System is now of dimension $(size(data.Am)).")

end
