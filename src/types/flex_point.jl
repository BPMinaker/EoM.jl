export flex_point

mutable struct flex_point
	name::String
	group::String
	location::Vector{Float64}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	axis::Vector{Float64}
	rolling_axis::Vector{Float64}
	radius::Vector{Vector{Float64}}
	stiffness::Vector{Float64}
	s_mtx::Array{Float64,2}
	damping::Vector{Float64}
	d_mtx::Array{Float64,2}
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

flex_point(str::String)=flex_point(
str,
"flex_point",
zeros(3),
["ground","ground"],
zeros(2),
0,
0,
zeros(3),
zeros(3),
[zeros(3),zeros(3)],
zeros(2),
zeros(0,0),
zeros(2),
zeros(0,0),
Vector{Float64}(undef,0),
zeros(3),
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::flex_point)
	println(io,"Flexible point:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
	println(io,"Stiffness: ",obj.stiffness)
	println(io,"Damping: ",obj.damping)
end

function name(obj::flex_point)
	obj.name
end

function num_fm(obj::flex_point)
	obj.forces+obj.moments
end
