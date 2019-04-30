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

actuator(str::String)=actuator(str,"actuator",[zeros(3),zeros(3)],["ground","ground"],zeros(2),0,0,false,[zeros(3),zeros(3)],1,0,0,zeros(3),zeros(3,2),[zeros(2,2),zeros(2,2)])

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

# function actuator(
# name,
# group="actuator",
# location=[zeros(3),zeros(3)],
# body=["ground","ground"],
# body_number=zeros(2),
# forces=0,
# moments=0,
# twist=false,
# radius=[zeros(3),zeros(3)],
# gain=1,
# rate_gain=0,
# length=0,
# unit=zeros(3),
# nu=zeros(3,2),
# b_mtx=[zeros(2,2),zeros(2,2)])
# 	new(name,group,location,body,body_number,forces,moments,twist,radius,gain,rate_gain,length,unit,nu,b_mtx)
# end
