export link

type link
	name::String
	group::String
	location::Array{Float64,2}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Array{Float64,2}
	preload::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function link(
	name,
	group="link",
	location=[[0,0,0] [0,0,0]],
	body=["ground","ground"],
	body_number=[0,0],
	forces=0,
	moments=0,
	twist=false,
	radius=[[0,0,0] [0,0,0]],
	preload=NaN,
	length=0,
	unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
		new(name,group,location,body,body_number,forces,moments,twist,radius,preload,length,unit,nu,b_mtx)
	end
end
