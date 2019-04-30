export rigid_point

mutable struct rigid_point
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
	preload::Vector{Float64}
	unit::Vector{Float64}
	rolling_unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

end

rigid_point(str::String)=rigid_point(str,"rigid_point",zeros(3),["ground","ground"],zeros(2),0,0,zeros(3),zeros(3),[zeros(3), zeros(3)],Vector{Float64}(undef,0),
zeros(3),zeros(3),zeros(3,2),[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::rigid_point)
	println(io,"Rigid point:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function num_fm(obj::rigid_point)
	obj.forces+obj.moments
end


# function rigid_point(
# name,
# group="rigid_point",
# location=zeros(3),
# body=["ground","ground"],
# body_number=zeros(2),
# forces=0,
# moments=0,
# axis=zeros(3),
# rolling_axis=zeros(3),
# radius=[zeros(3), zeros(3)],
# preload=Vector{Float64}(undef,0),
# unit=zeros(3),
# rolling_unit=zeros(3),
# nu=zeros(3,2),
# b_mtx=[zeros(2,2),zeros(2,2)])
# 	new(name,group,location,body,body_number,forces,moments,axis,rolling_axis,radius,preload,unit,rolling_unit,nu,b_mtx)
# end
