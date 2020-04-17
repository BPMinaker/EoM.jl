mutable struct eom_data
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
end

mbd_system(str::String="Unnamed System")=mbd_system(
str,0,
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

function vpt(obj::mbd_system)
	obj.vpt
end

struct dss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
	E::Array{Float64,2}
	phys::Array{Float64,2}
end

function Base.show(io::IO, obj::dss_data)
	println(io,"Descriptor state space")
	println(io,"A: ",obj.A)
	println(io,"B: ",obj.B)
	println(io,"C: ",obj.C)
	println(io,"D: ",obj.D)
	println(io,"E: ",obj.E)
end

struct ss_data
	A::Array{Float64,2}
	B::Array{Float64,2}
	C::Array{Float64,2}
	D::Array{Float64,2}
end

function Base.show(io::IO, obj::ss_data)
	println(io,"State space")
	println(io,"A: ",obj.A)
	println(io,"B: ",obj.B)
	println(io,"C: ",obj.C)
	println(io,"D: ",obj.D)
end

ss_data()=ss_data(zeros(0,0),zeros(0,0),zeros(0,0),zeros(0,0))

mutable struct analysis
	ss_eqns::ss_data
	mode_vals::Vector{Complex{Float64}}
	modes::Array{Complex{Float64},2}
	e_val::Vector{Complex{Float64}}
	omega_n::Vector{Float64}
	zeta::Vector{Float64}
	tau::Vector{Float64}
	lambda::Vector{Float64}
	w::Vector{Float64}
	freq_resp::Array{Complex{Float64},3}
	ss_resp::Array{Float64,2}
	zero_val::Vector{Complex{Float64}}
	hsv::Vector{Float64}
	centre::Array{Complex{Float64},2}
end

analysis()=analysis(
ss_data(),
zeros(0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0),
zeros(0),
zeros(0),
zeros(0),
zeros(0,0,0),
zeros(0,0),
zeros(0),
zeros(0),
zeros(0,0))

function e_val(obj::analysis)
	obj.e_val
end

function omega_n(obj::analysis)
	obj.omega_n
end

function zeta(obj::analysis)
	obj.zeta
end

function tau(obj::analysis)
	obj.tau
end

function lambda(obj::analysis)
	obj.lambda
end
