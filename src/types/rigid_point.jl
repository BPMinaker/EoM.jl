export rigid_point

type rigid_point
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
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function rigid_point(
	name,
	group="rigid_point",
	location=[0,0,0],
	body=["ground","ground"],
	body_number=[0,0],
	forces=0,
	moments=0,
	axis=[0,0,0],
	rolling_axis=[0,0,0],
	radius=[[0,0,0] [0,0,0]],
	preload=Vector{Float64}(0),
	unit=[0,0,0],
	rolling_unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	b_mtx=[[0 0;0 0],[0 0;0 0]])
		new(name,group,location,body,body_number,forces,moments,axis,rolling_axis,radius,preload,unit,rolling_unit,nu,b_mtx)
	end
end

function num_fm(obj::rigid_point)
	obj.forces+obj.moments
end


