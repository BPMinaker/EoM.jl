export load

Base.@kwdef mutable struct load
	name::String
	group::String = "load"
	location::Vector{Float64} = zeros(3)
	body::String = "ground"
	body_number::Int = 0
	force::Vector{Float64} = zeros(3)
	moment::Vector{Float64} = zeros(3)
	radius::Vector{Float64} = zeros(3)
	frame::String = "ground"
	frame_number::Int = 0
end

load(str::String)=load(; name = str)

function Base.show(io::IO, obj::load)
	println(io,"Load:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Body: ",obj.body)
end
