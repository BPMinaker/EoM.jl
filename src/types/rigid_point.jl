export rigid_point

mutable struct rigid_point
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
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

rigid_point(str::String)=rigid_point(
str,
"rigid_point",
zeros(3),
["ground","ground"],
zeros(2),
0,
0,
zeros(3),
zeros(3),
[zeros(3), zeros(3)],
Vector{Float64}(undef,0),
zeros(3),
zeros(3),
zeros(3,2),
[zeros(2,2),
zeros(2,2)])

function Base.show(io::IO, obj::rigid_point)
	println(io,"Rigid point:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::rigid_point)
	obj.name
end

function num_fm(obj::rigid_point)
	obj.forces+obj.moments
end
