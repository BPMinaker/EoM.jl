function dss2ss!(ss_eqns,verb)

verb && println("System is of dimension ",size(ss_eqns.A),".")
verb && println("Converting from descriptor form to standard state space...")

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

verb && println("System is now of dimension ",(size(AA)),".")
verb && println("Computing minimal realization...")

val,vec=eig(AA)
m=length(val)

v=cond(vec)
verb && v>1e6 && println("Poorly conditioned eigenvectors!...")
r=rank(vec)

# ck=zeros(m,m)
#
# for i=1:m
# 	for j=i+1:m
# 		ck[i,j]=transpose(vec[:,i])*vec[:,j]
# 	end
# end
# println(ck)

i=1
while r<m && i<m+1
#	println(val)
#	println(vec[:,i])

	#println("Vectors are not unique!")
	#println("Eigenvector rank is $r.")
	#println("Trying to replace redundant vector...")
	t=rank([vec[:,1:i-1] vec[:,i+1:end]])
	if t==r
		verb && println("Replacing vector $i.")
		vec[:,i]=pinv(AA-val[i]*eye(m))*vec[:,i]
		if i<m
			if (val[i] == conj(val[i+1])) && !(val[i] == val[i+1])
				verb && println("Replacing vector $(i+1).")
				vec[:,i+1]=conj(vec[:,i])
				i+=1
			end
		end
	end
	i+=1
	r=rank(vec)
#	println("Eigenvector rank is $r.")
end

CCC=CC*vec
BBB=vec\BB

sens=(sum(abs.(CCC).^2,1).^0.5)'.*(sum(abs.(BBB).^2,2).^0.5)
#println(sens)

flag=find(sens.>maximum(sens)*1e-5)
#println(flag)

s=length(flag)

if s>0
	md=real(val[flag])
	ud=zeros(s-1)
	ld=zeros(s-1)

	for i=1:s-1
		if (val[flag[i]] == conj(val[flag[i+1]])) && !(val[flag[i]] == val[flag[i+1]])
			ud[i]=imag(val[flag[i]])
			ld[i]=-imag(val[flag[i]])
		else
			ud[i]=0
			ld[i]=0
		end
	end

	for i=1:m-1
		if (val[i] == conj(val[i+1])) && !(val[i] == val[i+1])
			temp=vec[:,i]
			vec[:,i]+=vec[:,i+1]
			vec[:,i+1]-=temp
			vec[:,i+1]*=1im
		end
	end

	#println(vec')

	ss_eqns.Am=Tridiagonal(ld,md,ud)
	ss_eqns.Bm=(vec\BB)[flag,:]
	ss_eqns.Cm=CC*vec[:,flag]
	ss_eqns.Dm=DD

	verb && println("System is now of dimension ",size(ss_eqns.Am),".")

else
	println("No observable and controllable modes found.")
end

end

# ------------------- old code ------------------

# n=size(AA,1)
# nin=size(BB,2)
# nout=size(CC,1)
#
# CM=zeros(n,n*nin)
# OM=zeros(n*nout,n)

# temp=eye(n)
# tr=1
# U=0
# S=0
# V=0
# p=0
# for i=1:n
#
# 	CM[:,(i-1)*nin+1:i*nin]=temp*BB
# 	OM[(i-1)*nout+1:i*nout,:]=CC*temp
#  	temp*=AA
#
# 	MR=OM*CM
# 	U,S,V=svd(MR)
# # 	println(S)
# 	S=S[S.>(maximum(size(MR))*eps(maximum(S)))]
# 	p=length(S)
# 	println("p ",p)
# 	println("i ",i)
# 	if(p<i && p>0)
# 		break
# 	 end
# end
#
# MR1=OM*AA*CM
# Si=diagm(S.^-0.5)
# S=diagm(S.^0.5)
#
# Un=U[:,1:p]
# Vn=V[:,1:p]
#
# ss_eqns.Am=Si*Un'*MR1*Vn*Si*tr
# ss_eqns.Bm=(S*Vn')[:,1:nin]
# ss_eqns.Cm=(Un*S)[1:nout,:]
# ss_eqns.Dm=DD
