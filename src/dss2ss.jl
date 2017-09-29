function dss2ss!(ss_eqns,verb)

verb && println("System is of dimension ",size(ss_eqns.A),".")
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

verb && println("System is now of dimension ",(size(AA)),".")
verb && println("Computing minimal realization...")

val,vec=eig(AA)

m=length(val)
r=rank(vec)
bb=0

if(r<m)
	println("Vectors are not unique!")
	println("Eigenvector rank is $r.")

	if(r==(m-1))
		println("Trying to replace redundant vector...")
		for i=1:m
			temp=[vec[:,1:i-1] vec[:,i+1:end]]
			t=rank(temp)
			if(t==r)
				bb=i
			end
		end
		if(bb>0)
			vec[:,bb]=pinv(AA-val[bb]*eye(m))*vec[:,bb]
		end
	end
end

r=rank(vec)
println("Eigenvector rank is $r.")

CCC=CC*vec
BBB=vec\BB

sens=(sum(abs.(CCC).^2,1).^0.5)'.*(sum(abs.(BBB).^2,2).^0.5)
flag=find(sens.>maximum(sens)*1e-5)
#println(flag)

s=length(flag)
md=real(val[flag])
ud=zeros(s-1)
ld=zeros(s-1)

#println(val)
#println(vec')

for i=1:m-1
	if ((real(val[i]) == real(val[i+1])) && (imag(val[i]) == -imag(val[i+1])))
		temp=vec[:,i]
		vec[:,i]+=vec[:,i+1]
		vec[:,i+1]-=temp
		vec[:,i+1]*=1im
	end
end


for i=1:s-1
	if ((real(val[flag[i]]) == real(val[flag[i+1]])) && (imag(val[flag[i]]) == -imag(val[flag[i+1]])))
		ud[i]=imag(val[flag[i]])
		ld[i]=-imag(val[flag[i]])
	else
		ud[i]=0
		ld[i]=0
	end
end

#println(vec')

#U=inv(vec)[flag,:]
#ss_eqns.Am=U*AA*vec[:,flag]

ss_eqns.Am=diagm(md)+diagm(ud,1)+diagm(ld,-1)
ss_eqns.Bm=(vec\BB)[flag,:]
ss_eqns.Cm=CC*vec[:,flag]
ss_eqns.Dm=DD

verb && println("System is now of dimension ",size(ss_eqns.Am),".")

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




# val,vec=eig(AA)
# valt,vect=eig(AA')
#
# temp=[val transpose(vec)]
# temp=sortrows(temp)
# val=temp[:,1]
# vec=transpose(temp[:,2:end])
#
# # println(val)
# # println(vec[:,3])
# # println(vec[:,4])
# # println(vec[:,5])
#
# temp=[valt transpose(vect)]
# temp=sortrows(temp)
#
# valt=temp[:,1]
# vect=transpose(temp[:,2:end])
#
# # println(valt)
# # println(vect[3,:])
# # println(vect[4,:])
# # println(vect[5,:])
# #
# # println(transpose(vect)*vec)
#
# err=diag(transpose(vect)*vec).^(-1)
# # println(err)
#
# n=length(err)
# for i=1:n
# 	vect[:,i]*=err[i]
# end
#
# # println(vect)
# # println(diag(transpose(vect)*vec))
# # println("vec rank $(rank(vec))")
#
# CCC=CC*vec
# println(CCC)
#
# BBB=transpose(vect)*BB
# println(BBB)
#
# sens=(sum(abs.(CCC).^2,1).^0.5)'.*(sum(abs.(BBB).^2,2).^0.5)
#
# # println(sens)
#
# flag=find(sens.>(n*eps(maximum(sens))))
#
# # println(maximum(size(sens))*eps(maximum(sens)))
#
# # println(flag)
# # println(val[flag])
#
# for i=1:length(flag)-1
# 	if ((real(val[flag[i]]) == real(val[flag[i+1]])) && (imag(val[flag[i]]) == -imag(val[flag[i+1]])))
# 		temp=vec[:,flag[i]]
# 		vec[:,flag[i]]+=vec[:,flag[i+1]]
# 		vec[:,flag[i+1]]-=temp
# 		vec[:,flag[i+1]]*=1im
# 	end
# end
#
# #println(vec[:,flag])
#
# U=pinv(vec[:,flag])
#
# ss_eqns.Am=U*AA*vec[:,flag]
# ss_eqns.Bm=U*BB
# ss_eqns.Cm=CC*vec[:,flag]
# ss_eqns.Dm=DD
