export link

mutable struct link
	@add_generic_fields
	location::Vector{Vector{Float64}}
	twist::Bool
	preload::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

link(str::String)=link(
str,
"link",
["ground","ground"],
zeros(2),
0,
0,
[zeros(3),zeros(3)],
[zeros(3),zeros(3)],
false,
NaN,
0,
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::link)
	println(io,"Link:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
	println(io,"Preload: ",obj.preload)
end

function name(obj::link)
	obj.name
end

function num_fm(obj::link)
	obj.forces+obj.moments
end
