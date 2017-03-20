__precompile__()

module EoM
export run_eom
export mbd_system

include("body.jl")
include("link.jl")
include("spring.jl")
include("rigid_point.jl")
include("flex_point.jl")
include("nh_point.jl")
include("beam.jl")
include("load.jl")
include("actuator.jl")
include("sensor.jl")

include("run_eom.jl")
include("setup.jl")
include("sort_system.jl")
include("find_bodynum.jl")
include("find_radius.jl")
include("item_init.jl")
include("build_eom.jl")
include("force.jl")
include("skew.jl")
include("elastic_connections.jl")
include("rigid_constraints.jl")
include("preload.jl")
include("const_frc_deal.jl")
include("centngyro.jl")
include("point_line_jacobian.jl")
include("line_bend_jacobian.jl")
include("inputs.jl")
include("outputs.jl")
include("tangent.jl")
include("line_stretch_hessian.jl")
include("point_hessian.jl")
include("assemble_eom.jl")
include("linear_analysis.jl")
include("dss2ss.jl")

type mbd_system
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

	function mbd_system(
	name="Unnamed System",
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
		new(name,item,bodys,links,springs,rigid_points,flex_points,nh_points,beams,loads,sensors,actuators)
	end
end

type matrix_struct
	mass::Array{Float64,2}  ## mass matrix from bodies
	eq_mass::Array{Float64,2}  ## mass matrix from spring inertia
 	damping::Array{Float64,2}  ## damping matrix from dampers
 	stiffness::Array{Float64,2}  ## stiffness matrix from springs
	tangent_stiffness::Array{Float64,2}  ## stiffness matrix from internal loads
	load_stiffness::Array{Float64,2}  ## stiffness matrix from external loads
 	velocity::Array{Float64,2}  ## velocity matrix for kinematics differential equation
	momentum::Array{Float64,2}  ## momentum matrix that gets added to damping matrix
	constraint::Array{Float64,2}  ## holonomic constraint jacobian
	nh_constraint::Array{Float64,2}  ## nonholonomic constraint jacobian
	deflection::Array{Float64,2}  ## elactic deflections jacobian
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
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
	E::Array{Float64,2}
	AA::Array{Float64,2}
	BB::Array{Float64,2}
	CC::Array{Float64,2}
	DD::Array{Float64,2}
	e_vect::Array{Complex{Float64},2}
	e_val::Vector{Complex{Float64}}

	function matrix_struct(
	mass=Array{Float64}(0,0),
	eq_mass=Array{Float64}(0,0),
 	damping=Array{Float64}(0,0),
 	stiffness=Array{Float64}(0,0),
	tangent_stiffness=Array{Float64}(0,0),
	load_stiffness=Array{Float64}(0,0),
 	velocity=Array{Float64}(0,0),
	momentum=Array{Float64}(0,0),
	constraint=Array{Float64}(0,0),
	nh_constraint=Array{Float64}(0,0),
	deflection=Array{Float64}(0,0),
	lambda=Vector{Float64}(0),
	static=Vector{Float64}(0),
	selection=Array{Float64}(0,0),
	spring_stiffness=Vector{Float64}(0),
	subset_spring_stiffness=Vector{Float64}(0),
	left_jacobian=Array{Float64}(0,0),
	right_jacobian=Array{Float64}(0,0),
	force=Vector{Float64}(0),
	preload=Vector{Float64}(0),
	input=Array{Float64}(0,0),
	input_rate=Array{Float64}(0,0),
	output=Array{Float64}(0,0),
	feedthrough=Array{Float64}(0,0),
	A=Array{Float64}(0,0),
	B=Array{Float64}(0,0),
	C=Array{Float64}(0,0),
	D=Array{Float64}(0,0),
	E=Array{Float64}(0,0),
	AA=Array{Float64}(0,0),
	BB=Array{Float64}(0,0),
	CC=Array{Float64}(0,0),
	DD=Array{Float64}(0,0),
	e_vect=Array{Float64}(0,0),
	e_val=Vector{Float64}(0))
		new(mass,eq_mass,damping,stiffness,tangent_stiffness,load_stiffness,velocity,momentum,constraint,nh_constraint,deflection,lambda,static,selection,spring_stiffness,subset_spring_stiffness,left_jacobian,right_jacobian,force,preload,input,input_rate,output,feedthrough,A,B,C,D,E,AA,BB,CC,DD,e_vect,e_val)
	end
end

end
