export sensor
export name
export gain

mutable struct sensor
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
	order::Int  ## [1 - position, 2- velocity, 3- acceleration ]
	frame::Int  ## [ 0 - local, 1 - global]
	actuator::String
	actuator_number::Int
 	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function sensor(
	name,
	group="sensor",
	location=[zeros(3),zeros(3)],
	body=["ground","ground"],
	body_number=zeros(2),
	forces=0,
	moments=0,
	twist=false,
	radius=[zeros(3),zeros(3)],
	gain=1,
	order=1,
	frame=1,
	actuator="ground",
	actuator_number=0,
	length=0,
	unit=zeros(3),
	nu=zeros(3,2),
	b_mtx=[zeros(2,2),zeros(2,2)])
		new(name,group,location,body,body_number,forces,moments,twist,radius,gain,order,frame,actuator,actuator_number,length,unit,nu,b_mtx)
	end
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
