export nh_point

type nh_point
	name::String
	group::String
	location::Vector{Float64}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	axis::Vector{Float64}
	rolling_axis::Vector{Float64}
	radius::Array{Float64,2}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function nh_point(
	name,
	group="nh_point",
	location=[0,0,0],
	body=["ground","ground"],
	body_number=[0,0],
	forces=0,
	moments=0,
	axis=[0,0,0],
	rolling_axis=[0,0,0],
	radius=[[0,0,0] [0,0,0]],
	unit=[0,0,0],
	rolling_unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
		new(name,group,location,body,body_number,forces,moments,axis,rolling_axis,radius,unit,rolling_unit,nu,b_mtx)
	end
end
