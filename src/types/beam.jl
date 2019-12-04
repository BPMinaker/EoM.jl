export beam

mutable struct beam
	@add_generic_fields
	location::Vector{Vector{Float64}}
	stiffness::Float64
	s_mtx::Array{Float64,2}
	mpul::Float64
	m_mtx::Array{Float64,2}
	length::Float64
	preload::Vector{Float64}
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}
end

beam(str::String)=beam(
str,
"beam",
["ground","ground"],
zeros(2),
2,
2,
[zeros(3),zeros(3)],
[zeros(3),zeros(3)],
0,
zeros(0,0),
0,
zeros(0,0),
0,
[NaN,NaN,NaN,NaN],
zeros(3),
zeros(3,2),
[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::beam)
	println(io,"Beam:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function name(obj::beam)
	obj.name
end

function num_fm(obj::beam)
	obj.forces+obj.moments
end
