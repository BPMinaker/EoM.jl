function dss2ss!(ss_eqns,verb)

verb && println("System is of dimension $(size(ss_eqns.A)).")
verb && println("Converting from descriptor form to standard state space...")

Q,S,P=svd(ss_eqns.E)  ##Q'*E*P should = S
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

ss_eqns.At=AA;
ss_eqns.Bt=BB;
ss_eqns.Ct=CC;
ss_eqns.Dt=DD;

verb && println("System is now of dimension $(size(AA)).")
verb && println("Computing minimal realization...")


n=size(AA,1)
nin=size(BB,2)
nout=size(CC,1)

CM=zeros(n,n*nin)
OM=zeros(n*nout,n)

#tr=sum(diag(AA))
#println("det ",det(AA))
#println(tr)



# if(abs(tr)<eps(Float64(n)))
# 	tr=1
# end
# AAA=AA
#
temp=eye(n)
tr=1
U=0
S=0
V=0
p=0
for i=1:n

	CM[:,(i-1)*nin+1:i*nin]=temp*BB
	OM[(i-1)*nout+1:i*nout,:]=CC*temp
 	temp*=AA

	MR=OM*CM
	U,S,V=svd(MR)
# 	println(S)
	S=S[S.>(maximum(size(MR))*eps(maximum(S)))]
	p=length(S)
	println("p ",p)
	println("i ",i)
	if(p<i && p>0)
		break
	 end
end

MR1=OM*AA*CM
Si=diagm(S.^-0.5)
S=diagm(S.^0.5)

Un=U[:,1:p]
Vn=V[:,1:p]

ss_eqns.Am=Si*Un'*MR1*Vn*Si*tr
ss_eqns.Bm=(S*Vn')[:,1:nin]
ss_eqns.Cm=(Un*S)[1:nout,:]
ss_eqns.Dm=DD

verb && println("System is now of dimension $(size(ss_eqns.Am)).")

end
