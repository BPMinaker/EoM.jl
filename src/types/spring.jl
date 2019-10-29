export spring

mutable struct spring
	name::String
	group::String
	location::Vector{Vector{Float64}}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Vector{Vector{Float64}}
	stiffness::Float64
	damping::Float64
	preload::Float64
	inertance::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

spring(str::String)=spring(
str,
"spring",
[zeros(3),zeros(3)],
["ground","ground"],
zeros(2),
0,
0,
false,
[zeros(3),zeros(3)],
0,
0,
NaN,
0,
0,
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::spring)
	println(io,"Spring:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
	println(io,"Stiffness: ",obj.stiffness)
	println(io,"Damping: ",obj.damping)
end

function name(obj::spring)
	obj.name
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
