using LinearAlgebra
using SparseArrays

function splsim(ss,u,t,x0=zeros(size(ss.A,2),1);verbose=false)

	n=length(t)
	T=t[2]-t[1]
	val,vec=eigen(ss.A)

	h=minimum(0.4./abs.(val.+eps(1.)))
	T>h && println("Warning: step size may be too large")

	##Ad=exp(ss.A*T)
	##Bd=ss.A\(Ad-I)*ss.B

	AT=ss.A*T
	term1=zeros(size(ss.A))+I
	term2=zeros(size(ss.A))+I
	Ad=zeros(size(ss.A))+I
	Bd=zeros(size(ss.A))+I

	for i=1:10
		term1*=AT/i
		term2*=AT/(i+1)
		Ad+=term1
		Bd+=term2
	end
	Bd*=ss.B*T

	Z=sparse([Ad Bd])
	ZZ=sparse([ss.C ss.D])

	ns=size(ss.A,2)
	ni=size(ss.B,2)
	no=size(ss.C,1)
	xu=zeros(ns+ni,n)

	xu[1:ns,1]=x0
	xu[ns+1:ns+ni,:]=hcat(u...)

	for i=2:n
		xu[1:ns,i]=Z*xu[:,i-1]
	end
	temp=ZZ*xu

	y=fill(zeros(no),n)
	for i=1:n
		y[i]=temp[:,i]
	end

	y

end

# sAd=sparse(Ad)
# sBd=sparse(Bd)
# xx=fill(zeros(ns),n)
# xx[1]=x0[:,1]
#
# for i=2:n
# 	xx[i]=sAd*xx[i-1]+sBd*u[i-1]
# end