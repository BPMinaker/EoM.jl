export body
export name
export location
export weight

#export inertia_mtx
#export lcn_orn
#export welocity

mutable struct body
	name::String
	group::String
	location::Vector{Float64}
	orientation::Vector{Float64}
	mass::Float64
	moments_of_inertia::Vector{Float64}
	products_of_inertia::Vector{Float64}
	velocity::Vector{Float64}
	angular_velocity::Vector{Float64}
	deflection::Vector{Float64}
	angular_deflection::Vector{Float64}
	x3d::String
end

body(str::String)=body(
str,
"body",
zeros(3),
zeros(3),
0,
zeros(3),
zeros(3),
zeros(3),
zeros(3),
[NaN,NaN,NaN],
[NaN,NaN,NaN],
"")

function Base.show(io::IO, obj::body)
	println(io,"Body:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Inertia: ",inertia_mtx(obj))
	println(io,"Mass: ",obj.mass)
	println(io,"Velocity: ",obj.velocity)
	println(io,"Angular velocity: ",obj.angular_velocity)
end

function name(obj::body)
	obj.name
end

function location(obj::body)
	obj.location
end

function lcn_orn(obj::body)
	[obj.location;obj.orientation]
end

function welocity(obj::body)
	[obj.velocity;obj.angular_velocity]
end

function inertia_mtx(obj::body)
	diagm(0=>obj.moments_of_inertia)-diagm(1=>obj.products_of_inertia[1:2])-diagm(-1=>obj.products_of_inertia[1:2])-diagm(2=>[obj.products_of_inertia[3]])-diagm(-2=>[obj.products_of_inertia[3]])
end

function mass_mtx(obj::body)
	[obj.mass*(zeros(3,3)+I) zeros(3,3); zeros(3,3) inertia_mtx(obj)]  ## Stack mass and inertia terms
end

function weight(obj::body,g=9.81)
	g*=[0,0,-1]
	item=load("$(obj.name) weight")
	item.body=obj.name
	item.location=obj.location
	item.force=obj.mass*g;
	item.moment=[0,0,0]
	item
end
