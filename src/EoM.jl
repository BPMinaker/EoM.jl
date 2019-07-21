#__precompile__()

module EoM

using LinearAlgebra
using Dates
using DelimitedFiles
#using Printf

export build_examples
export run_eom
export analyze
export full_ss
export write_output


export skew
export mbd_system
export thin_rod
export mirror!

fldr=joinpath(dirname(pathof(EoM)),"types")
types=readdir(fldr)
for i in types
	include(joinpath(fldr,i))
end

#export run_eom_nl
#include("rotate.jl")
#include("run_eom_nl.jl")
#include("xdot.jl")

include("run_eom.jl")
include("setup.jl")
include("build_examples.jl")
include("mass.jl")
include("sort_system.jl")
include("find_bodynum.jl")
include("find_radius.jl")
include("item_init.jl")
include("generate_eom.jl")
include("force.jl")
include("skew.jl")
include("elastic_connections.jl")
include("rigid_constraints.jl")
include("preload.jl")
include("const_frc_deal.jl")
include("defln_deal.jl")
include("centngyro.jl")
include("point_line_jacobian.jl")
include("line_bend_jacobian.jl")
include("inputs.jl")
include("outputs.jl")
include("tangent.jl")
include("line_stretch_hessian.jl")
include("point_hessian.jl")
include("assemble_eom.jl")
include("analyze.jl")
include("dss2ss.jl")
include("minreal_jordan.jl")
include("write_output.jl")
include("load_defln.jl")
include("syst_props.jl")
include("mirror.jl")
include("thin_rod.jl")

# fldr=joinpath(dirname(dirname(pathof(EoM))),"examples")
# xmpls=readdir(fldr)
# for i in xmpls
# 	include(joinpath(fldr,i))
# end

mutable struct eom_data
	name::String
	input_names::Vector{String}
	output_names::Vector{String}
	mass::Array{Float64,2}  ## mass matrix from bodies
	inertia::Array{Float64,2}  ## mass matrix from springs
	damping::Array{Float64,2}  ## damping matrix from dampers
	stiffness::Array{Float64,2}  ## stiffness matrix from springs
	tangent_stiffness::Array{Float64,2}  ## stiffness matrix from internal loads
	load_stiffness::Array{Float64,2}  ## stiffness matrix from external loads
	velocity::Array{Float64,2}  ## velocity matrix for kinematics differential equation
	momentum::Array{Float64,2}  ## momentum matrix that gets added to damping matrix
	constraint::Array{Float64,2}  ## holonomic constraint jacobian
	nh_constraint::Array{Float64,2}  ## nonholonomic constraint jacobian
	deflection::Array{Float64,2}   ## elactic deflections jacobian
	lambda::Vector{Float64}  ## lagrange multipliers, internal preloads
	static::Vector{Float64}  ## static deflection
	selection::Array{Float64,2}  ## indicator of which springs preload is known in advance
	spring_stiffness::Vector{Float64}  ## all flexible item stiffnesses
	subset_spring_stiffness::Vector{Float64}  ## stiffnesses of springs with known preload
	left_jacobian::Array{Float64,2}
	right_jacobian::Array{Float64,2}
	force::Vector{Float64}  ## external forces
	preload::Vector{Float64}  ## all known and NaN preloads
	input::Array{Float64,2}
	input_rate::Array{Float64,2}
	output::Array{Float64,2}
	feedthrough::Array{Float64,2}
	M::Array{Float64,2}
	KC::Array{Float64,2}
end

eom_data()=eom_data(
"",
[],
[],
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0),
zeros(0,0))

mutable struct mbd_system
	name::String
	item::Vector{Any}
	bodys::Vector{body}
	links::Vector{link}
	springs::Vector{spring}
	rigid_points::Vector{rigid_point}
	flex_points::Vector{flex_point}
	nh_points::Vector{nh_point}
	beams::Vector{beam}
	loads::Vector{load}
	sensors::Vector{sensor}
	actuators::Vector{actuator}
end

mbd_system(str::String="Unnamed System")=mbd_system(
str,
Vector{Any}(undef,0),
Vector{body}(undef,0),
Vector{link}(undef,0),
Vector{spring}(undef,0),
Vector{rigid_point}(undef,0),
Vector{flex_point}(undef,0),
Vector{nh_point}(undef,0),
Vector{beam}(undef,0),
Vector{load}(undef,0),
Vector{sensor}(undef,0),
Vector{actuator}(undef,0))

mutable struct mbd_eom
	vpt::Float64
	system::mbd_system
	data::eom_data
end

mbd_eom()=mbd_eom(
0,
mbd_system(),
eom_data())

struct dss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
	E::Array{Float64,2}
	phys::Array{Float64,2}
end

struct ss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
end

ss_data()=ss_data(zeros(0,0),zeros(0,0),zeros(0,0),zeros(0,0))

mutable struct analysis
	ss_eqns::ss_data
	jordan::ss_data
	e_vect::Array{Complex{Float64},2}
	modes::Array{Complex{Float64},2}
	e_val::Vector{Complex{Float64}}
	w::Vector{Float64}
	freq_resp::Array{Complex{Float64},3}
	ss_resp::Array{Float64,2}
	zero_val::Vector{Complex{Float64}}
	hsv::Vector{Float64}
	centre::Array{Complex{Float64},2}
end

analysis()=analysis(
ss_data(),
ss_data(),
zeros(0,0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0,0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0))

end  # end module



# function analysis(
# ss_eqns=ss_data(),
# jordan=ss_data(),
# e_vect=zeros(0,0),
# modes=zeros(0,0),
# e_val=zeros(0),
# w=zeros(0),
# freq_resp=zeros(0,0,0),
# ss_resp=zeros(0,0),
# zero_val=zeros(0),
# hsv=zeros(0),
# centre=zeros(0,0))
# 	new(ss_eqns,jordan,e_vect,modes,e_val,w,freq_resp,ss_resp,zero_val,hsv,centre)
# end

# function ss_data(
# 	A=Array{Float64}(undef,0,0),
# 	B=Array{Float64}(undef,0,0),
# 	C=Array{Float64}(undef,0,0),
# 	D=Array{Float64}(undef,0,0))
# 		new(A,B,C,D)
# end

# function dss_data(
# 	A=Array{Float64}(undef,0,0),
# 	B=Array{Float64}(undef,0,0),
# 	C=Array{Float64}(undef,0,0),
# 	D=Array{Float64}(undef,0,0),
# 	E=Array{Float64}(undef,0,0),
# 	phys=Array{Float64}(undef,0,0))
# 		new(A,B,C,D,E,phys)
# end

# function mbd_system(
# name="Unnamed System",
# vpt=0,
# item=Vector{Any}(undef,0),
# bodys=Vector{body}(undef,0),
# links=Vector{link}(undef,0),
# springs=Vector{spring}(undef,0),
# rigid_points=Vector{rigid_point}(undef,0),
# flex_points=Vector{flex_point}(undef,0),
# nh_points=Vector{nh_point}(undef,0),
# beams=Vector{beam}(undef,0),
# loads=Vector{load}(undef,0),
# sensors=Vector{sensor}(undef,0),
# actuators=Vector{actuator}(undef,0))
# 	new(name,vpt,item,bodys,links,springs,rigid_points,flex_points,nh_points,beams,loads,sensors,actuators)
# end
