export spring

mutable struct spring
	@add_generic_fields
	location::Vector{Vector{Float64}}
	twist::Bool
	stiffness::Float64
	damping::Float64
	preload::Float64
	inertance::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
    b_mtx::Vector{Array{Float64,2}}
    force::Vector{Float64}
    moment::Vector{Float64}
end

spring(str::String)=spring(
str,
"spring",
["ground","ground"],
zeros(2),
0,
0,
[zeros(3),zeros(3)],
[zeros(3),zeros(3)],
false,
0,
0,
NaN,
0,
0,
zeros(3),
zeros(3,2),
[zeros(1,3),zeros(1,3)],
zeros(3),
zeros(3))

function Base.show(io::IO, obj::spring)
	println(io,"Spring:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
	println(io,"Stiffness: ",obj.stiffness)
	println(io,"Damping: ",obj.damping)
	println(io,"Preload: ",obj.preload)
end

function name(obj::spring)
	obj.name
end

function ptr(obj::spring)
	6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function stiffness(obj::spring)
	obj.stiffness
end

function damping(obj::spring)
	obj.damping
end

function preload(obj::spring)
	obj.preload
end

function inertance(obj::spring)
	obj.inertance
end

function num_fm(obj::spring)
	obj.forces+obj.moments
end
