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
    force::Vector{Float64}
    moment::Vector{Float64}
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
[zeros(1,3),zeros(1,3)],
zeros(3),
zeros(3))

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

function ptr(obj::link)
	6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function preload(obj::link)
	obj.preload
end

function num_fm(obj::link)
	obj.forces+obj.moments
end
