export sensor
export name
export gain

mutable struct sensor
	@add_generic_fields
	location::Vector{Vector{Float64}}
	twist::Bool
	gain::Float64
	order::Int  ## [1 - position, 2- velocity, 3- acceleration ]
	frame::Int  ## [ 0 - local, 1 - global]
	actuator::String
	actuator_number::Int
 	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

sensor(str::String)=sensor(
str,
"sensor",
["ground","ground"],
zeros(2),
0,
0,
[zeros(3),zeros(3)],
[zeros(3),zeros(3)],
false,
1,
1,
1,
"ground",
0,
0,
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::sensor)
	println(io,"Sensor:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::sensor)
	obj.name
end

function gain(obj::sensor)
	obj.gain
end

function order(obj::sensor)
	obj.order
end

function frame(obj::sensor)
	obj.frame
end

function num_fm(obj::sensor)
	obj.forces+obj.moments
end
