export sensor
export name
export gain

type sensor
	name::String
	group::String
	location::Array{Float64,2}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Array{Float64,2}
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
	location=[[0,0,0] [0,0,0]],
	body=["ground","ground"],
	body_number=[0,0],
	forces=0,
	moments=0,
	twist=false,
	radius=[[0,0,0] [0,0,0]],
	gain=1,
	order=1,
	frame=1,
	actuator="ground",
	actuator_number=0,
	length=0,
	unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
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
