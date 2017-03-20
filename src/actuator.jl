export actuator
export name
export gain
export rate_gain

type actuator
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
	rate_gain::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function actuator(
	name,
	group="actuator",
	location=[[0,0,0] [0,0,0]],
	body=["ground","ground"],
	body_number=[0,0],
	forces=0,
	moments=0,
	twist=false,
	radius=[[0,0,0] [0,0,0]],
	gain=1,
	rate_gain=0,
	length=0,
	unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
		new(name,group,location,body,body_number,forces,moments,twist,radius,gain,rate_gain,length,unit,nu,b_mtx)
	end
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
