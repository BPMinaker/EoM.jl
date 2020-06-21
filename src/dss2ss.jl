function dss2ss(dss_eqns::EoM.dss_data,args...)

## Copyright (C) 2020, Bruce Minaker
## dss2ss.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## dss2ss.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

verbose=any(args.==:verbose)
verbose && println("System is of dimension ",size(dss_eqns.A,1),".")
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

n=size(A,1)
verbose && println("System is now of dimension ",n,".")
ss_eqns=ss_data(A,B,C,D)

ss_eqns

end
