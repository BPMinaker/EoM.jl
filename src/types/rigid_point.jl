export rigid_point

mutable struct rigid_point
	@add_generic_fields
	location::Vector{Float64}
	axis::Vector{Float64}
	rolling_axis::Vector{Float64}
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
    b_mtx::Vector{Array{Float64,2}}
    force::Vector{Float64}
    moment::Vector{Float64}
end

rigid_point(str::String)=rigid_point(
str,
"rigid_point",
["ground","ground"],
zeros(2),
0,
0,
[zeros(3),zeros(3)],
zeros(3),
zeros(3),
zeros(3),
Vector{Float64}(undef,0),
zeros(3),
zeros(3),
zeros(3,2),
[zeros(3,3),zeros(3,3)],
zeros(3),
zeros(3))

function Base.show(io::IO, obj::rigid_point)
	println(io,"Rigid point:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::rigid_point)
	obj.name
end

function ptr(obj::rigid_point)
	6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::rigid_point)
	obj.forces+obj.moments
end
