using LinearAlgebra

function lsim(ss,u,t,x0=zeros(size(ss.A,1),1);verbose=false)

	n=length(t)
	T=t[2]-t[1]
	val,vec=eigen(ss.A)

	h=minimum(0.4./abs.(val))

	T>h && println("Warning: step size may be too large")

	Ad=exp(ss.A*T)
	Bd=ss.A\((Ad-I)*ss.B)
	Z=[Ad Bd]
	ZZ=[ss.C ss.D]

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
