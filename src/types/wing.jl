export wing
export name
export build_mtx

mutable struct wing
	name::String
	group::String
    CXu::Float64
    CXw::Float64
    CXq::Float64
    CYv::Float64
    CYp::Float64
    CYr::Float64
    CZu::Float64
    CZw::Float64
    CZq::Float64
    Clv::Float64
    Clp::Float64
    Clr::Float64
    Cmu::Float64
    Cmw::Float64
    Cmq::Float64
    Cnv::Float64
    Cnp::Float64
    Cnr::Float64
    CX::Float64
    CY::Float64
    CZ::Float64
    Cl::Float64
    Cm::Float64
    Cn::Float64
    chord::Float64
    span::Float64

	function wing(name,group="wing",CXu=0,CXw=0,CXq=0,CYv=0,CYp=0,CYr=0,CZu=0,CZw=0,CZq=0,Clv=0,Clp=0,Clr=0,Cmu=0,Cmw=0,Cmq=0,Cnv=0,Cnp=0,Cnr=0,CX=0,CY=0,CZ=0,Cl=0,Cm=0,Cn=0,chord=0,span=0)
        new(name,group,CXu,CXw,CXq,CYv,CYp,CYr,CZu,CZw,CZq,Clv,Clp,Clr,Cmu,Cmw,Cmq,Cnv,Cnp,Cnr,CX,CY,CZ,Cl,Cm,Cn,chord,span)
	end
end

function name(obj::wing)
	obj.name
end

function build_mtx(obj::wing)
    mtx=zeros(6,6)
    mtx[1,1]=obj.CXu
    mtx[1,3]=obj.CXw
    mtx[1,5]=obj.CXq*obj.chord/2
    mtx[2,2]=obj.CYv
    mtx[2,4]=obj.CYp*obj.span/2
    mtx[2,6]=obj.CYr*obj.span/2
    mtx[3,1]=obj.CZu
    mtx[3,3]=obj.CZw
    mtx[3,5]=obj.CZq*obj.chord/2
    mtx[4,2]=obj.Clv*obj.span
    mtx[4,4]=obj.Clp*obj.span^2/2
    mtx[4,6]=obj.Clr*obj.span^2/2
    mtx[5,1]=obj.Cmu*obj.chord
    mtx[5,3]=obj.Cmw*obj.chord
    mtx[5,5]=obj.Cmq*obj.chord^2/2
    mtx[6,2]=obj.Cnv*obj.span
    mtx[6,4]=obj.Cnp*obj.span^2/2
    mtx[6,6]=obj.Cnr*obj.span^2/2

    mtx
end
