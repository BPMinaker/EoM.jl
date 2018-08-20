#__precompile__()

module EoM

using Printf
using SparseArrays

export run_eom
export analyze
export write_output
export skew

export mbd_system
export thin_rod
export mirror!

# fldr=joinpath(Pkg.dir(),"EoM","src","types")
# types=readdir(fldr)
# for i in types
# 	include(joinpath(fldr,i))
# end

#export run_eom_nl
#include("rotate.jl")
#include("run_eom_nl.jl")
#include("xdot.jl")

include("run_eom.jl")
include("setup.jl")
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


include(joinpath("types","actuator.jl"))
include(joinpath("types","beam.jl"))
include(joinpath("types","body.jl"))
include(joinpath("types","flex_point.jl"))
include(joinpath("types","link.jl"))
include(joinpath("types","load.jl"))
include(joinpath("types","nh_point.jl"))
include(joinpath("types","rigid_point.jl"))
include(joinpath("types","sensor.jl"))
include(joinpath("types","spring.jl"))


# fldr=joinpath(Pkg.dir(),"EoM","examples")
# xmpls=readdir(fldr)
# for i in xmpls
# 	include(joinpath(fldr,i))
# end

mutable struct mbd_system
	name::String
	vpt::Float64
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

	function mbd_system(
	name="Unnamed System",
	vpt=0,
	item=Vector{Any}(0),
	bodys=Vector{body}(0),
	links=Vector{link}(0),
	springs=Vector{spring}(0),
	rigid_points=Vector{rigid_point}(0),
	flex_points=Vector{flex_point}(0),
	nh_points=Vector{nh_point}(0),
	beams=Vector{beam}(0),
	loads=Vector{load}(0),
	sensors=Vector{sensor}(0),
	actuators=Vector{actuator}(0))
		new(name,vpt,item,bodys,links,springs,rigid_points,flex_points,nh_points,beams,loads,sensors,actuators)
	end
end

mutable struct eom_data
	name::String
	input_names::Vector{String}
	output_names::Vector{String}
	mass::SparseMatrixCSC{Float64,Int64}  ## mass matrix from bodies
	inertia::SparseMatrixCSC{Float64,Int64}  ## mass matrix from springs
	damping::SparseMatrixCSC{Float64,Int64}  ## damping matrix from dampers
	stiffness::SparseMatrixCSC{Float64,Int64}  ## stiffness matrix from springs
	tangent_stiffness::SparseMatrixCSC{Float64,Int64}  ## stiffness matrix from internal loads
	load_stiffness::SparseMatrixCSC{Float64,Int64}  ## stiffness matrix from external loads
	velocity::SparseMatrixCSC{Float64,Int64}  ## velocity matrix for kinematics differential equation
	momentum::SparseMatrixCSC{Float64,Int64}  ## momentum matrix that gets added to damping matrix
	constraint::SparseMatrixCSC{Float64,Int64}  ## holonomic constraint jacobian
	nh_constraint::SparseMatrixCSC{Float64,Int64}  ## nonholonomic constraint jacobian
	deflection::SparseMatrixCSC{Float64,Int64}   ## elactic deflections jacobian
	lambda::Vector{Float64}  ## lagrange multipliers, internal preloads
	static::Vector{Float64}  ## static deflection
	selection::SparseMatrixCSC{Float64,Int64}  ## indicator of which springs preload is known in advance
	spring_stiffness::Vector{Float64}  ## all flexible item stiffnesses
	subset_spring_stiffness::Vector{Float64}  ## stiffnesses of springs with known preload
	left_jacobian::SparseMatrixCSC{Float64,Int64}
	right_jacobian::SparseMatrixCSC{Float64,Int64}
	force::Vector{Float64}  ## external forces
	preload::Vector{Float64}  ## all known and NaN preloads
	input::SparseMatrixCSC{Float64,Int64}
	input_rate::SparseMatrixCSC{Float64,Int64}
	output::SparseMatrixCSC{Float64,Int64}
	feedthrough::SparseMatrixCSC{Float64,Int64}
	M::SparseMatrixCSC{Float64,Int64}
	KC::SparseMatrixCSC{Float64,Int64}

	function eom_data(
	name="",
	input_names=[],
	output_names=[],
	mass=speye(0),
	inertia=speye(0),
	damping=speye(0),
	stiffness=speye(0),
	tangent_stiffness=speye(0),
	load_stiffness=speye(0),
	velocity=speye(0),
	momentum=speye(0),
	constraint=speye(0),
	nh_constraint=speye(0),
	deflection=speye(0),
	lambda=Vector{Float64}(0),
	static=Vector{Float64}(0),
	selection=speye(0),
	spring_stiffness=Vector{Float64}(0),
	subset_spring_stiffness=Vector{Float64}(0),
	left_jacobian=speye(0),
	right_jacobian=speye(0),
	force=Vector{Float64}(0),
	preload=Vector{Float64}(0),
	input=speye(0),
	input_rate=speye(0),
	output=speye(0),
	feedthrough=speye(0),
	M=speye(0),
	KC=speye(0))
		new(name,input_names,output_names,mass,inertia,damping,stiffness,tangent_stiffness,load_stiffness,velocity,momentum,constraint,nh_constraint,deflection,lambda,static,selection,spring_stiffness,subset_spring_stiffness,left_jacobian,right_jacobian,force,preload,input,input_rate,output,feedthrough,M,KC)
	end
end

mutable struct dss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
	E::Array{Float64,2}
	phys::Array{Float64,2}


	function dss_data(
		A=Array{Float64}(0,0),
		B=Array{Float64}(0,0),
		C=Array{Float64}(0,0),
		D=Array{Float64}(0,0),
		E=Array{Float64}(0,0),
		phys=Array{Float64}(0,0))
			new(A,B,C,D,E,phys)
	end

end

mutable struct ss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}

	function ss_data(
		A=Array{Float64}(0,0),
		B=Array{Float64}(0,0),
		C=Array{Float64}(0,0),
		D=Array{Float64}(0,0))
			new(A,B,C,D)
	end

end

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

	function analysis(
	ss_eqns=ss_data(),
	jordan=ss_data(),
	e_vect=Array{Float64}(0,0),
	modes=Array{Float64}(0,0),
	e_val=Vector{Float64}(0),
	w=Vector{Float64}(0),
	freq_resp=Array{Float64}(0,0,0),
	ss_resp=Array{Float64}(0,0),
	zero_val=Vector{Float64}(0),
	hsv=Vector{Float64}(0))
		new(ss_eqns,jordan,e_vect,modes,e_val,w,freq_resp,ss_resp,zero_val,hsv)
	end
end

end
