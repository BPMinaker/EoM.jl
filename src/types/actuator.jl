export actuator
export name
export gain
export rate_gain

mutable struct actuator
	name::String
	group::String
	location::Vector{Vector{Float64}}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Vector{Vector{Float64}}
	gain::Float64
	rate_gain::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

actuator(str::String)=actuator(
str,
"actuator",
[zeros(3),zeros(3)],
["ground","ground"],
zeros(2),
0,
0,
false,
[zeros(3),zeros(3)],
1,
0,
0,
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::actuator)
	println(io,"Actuator:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::actuator)
	obj.name
end

function gain(obj::actuator)
	obj.gain
end

function rate_gain(obj::actuator)
	obj.rate_gain
end

function num_fm(obj::actuator)
	obj.forces+obj.moments
end
