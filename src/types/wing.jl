export wing
export name
export build_mtx

Base.@kwdef mutable struct wing
    name::String
    group::String = "wing"
    CXu::Float64 = 0
    CXw::Float64 = 0
    CXq::Float64 = 0
    CYv::Float64 = 0
    CYp::Float64 = 0
    CYr::Float64 = 0
    CZu::Float64 = 0
    CZw::Float64 = 0
    CZq::Float64 = 0
    Clv::Float64 = 0
    Clp::Float64 = 0
    Clr::Float64 = 0
    Cmu::Float64 = 0
    Cmw::Float64 = 0
    Cmq::Float64 = 0
    Cnv::Float64 = 0
    Cnp::Float64 = 0
    Cnr::Float64 = 0
    CX::Float64 = 0
    CY::Float64 = 0
    CZ::Float64 = 0
    Cl::Float64 = 0
    Cm::Float64 = 0
    Cn::Float64 = 0
    chord::Float64 = 0
    span::Float64 = 0

end

wing(str::String) = wing(; name = str)

function build_mtx(obj::wing)
    mtx = zeros(6, 6)
    mtx[1, 1] = obj.CXu
    mtx[1, 3] = obj.CXw
    mtx[1, 5] = obj.CXq * obj.chord / 2
    mtx[2, 2] = obj.CYv
    mtx[2, 4] = obj.CYp * obj.span / 2
    mtx[2, 6] = obj.CYr * obj.span / 2
    mtx[3, 1] = obj.CZu
    mtx[3, 3] = obj.CZw
    mtx[3, 5] = obj.CZq * obj.chord / 2
    mtx[4, 2] = obj.Clv * obj.span
    mtx[4, 4] = obj.Clp * obj.span^2 / 2
    mtx[4, 6] = obj.Clr * obj.span^2 / 2
    mtx[5, 1] = obj.Cmu * obj.chord
    mtx[5, 3] = obj.Cmw * obj.chord
    mtx[5, 5] = obj.Cmq * obj.chord^2 / 2
    mtx[6, 2] = obj.Cnv * obj.span
    mtx[6, 4] = obj.Cnp * obj.span^2 / 2
    mtx[6, 6] = obj.Cnr * obj.span^2 / 2

    mtx
end
