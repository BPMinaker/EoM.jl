export flex_point

type flex_point
	name::String
	group::String
	location::Vector{Float64}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	axis::Vector{Float64}
	rolling_axis::Vector{Float64}
	radius::Vector{Vector{Float64}}
	stiffness::Vector{Float64}
	damping::Vector{Float64}
	d_mtx::Array{Float64,2}
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function flex_point(
	name,
	group="flex_point",
	location=zeros(3),
	body=["ground","ground"],
	body_number=zeros(2),
	forces=0,
	moments=0,
	axis=zeros(3),
	rolling_axis=zeros(3),
	radius=[zeros(3),zeros(3)],
	stiffness=zeros(2),
	damping=zeros(2),
	d_mtx=zeros(0,0),
	preload=Vector{Float64}(0),
	unit=zeros(3),
	rolling_unit=zeros(3),
	nu=zeros(3,2),
	b_mtx=[zeros(2,2),zeros(2,2)])
		new(name,group,location,body,body_number,forces,moments,axis,rolling_axis,radius,stiffness,damping,d_mtx,preload,unit,rolling_unit,nu,b_mtx)
	end
end

function num_fm(obj::flex_point)
	obj.forces+obj.moments
end
