export load

mutable struct load
	name::String
	group::String
	location::Vector{Float64}
	body::String
	body_number::Int
	force::Vector{Float64}
	moment::Vector{Float64}
	radius::Vector{Float64}
	frame::String
	frame_number::Int
end

load(str::String)=load(
str,
"load",
zeros(3),
"ground",
0,
zeros(3),
zeros(3),
zeros(3),
"ground",
0)

function Base.show(io::IO, obj::load)
	println(io,"Load:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Body: ",obj.body)
end
