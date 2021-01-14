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
	actuator_gain::Float64
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
-1,
0,
zeros(3),
zeros(3,2),
[zeros(1,3),zeros(1,3)])

function Base.show(io::IO, obj::sensor)
	println(io,"Sensor:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::sensor)
	obj.name
end

function ptr(obj::sensor)
	6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
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
