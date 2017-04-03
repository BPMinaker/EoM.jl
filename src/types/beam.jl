export beam

type beam
	name::String
	group::String
	location::Array{Float64,2}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	radius::Array{Float64,2}
	stiffness::Float64
	length::Float64
	preload::Vector{Float64}
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function beam(
	name,
	group="beam",
	location=[[0,0,0] [0,0,0]],
	body=["ground","ground"],
	body_number=[0,0],
	forces=2,
	moments=2,
	radius=[[0,0,0] [0,0,0]],
	stiffness=0,
	length=0,
	preload=[NaN,NaN,NaN,NaN],
	unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
		new(name,group,location,body,body_number,forces,moments,radius,stiffness,length,preload,unit,nu,b_mtx)
	end
end
