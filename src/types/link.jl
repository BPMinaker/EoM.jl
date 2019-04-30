export link

mutable struct link
	name::String
	group::String
	location::Vector{Vector{Float64}}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Vector{Vector{Float64}}
	preload::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

end

link(str::String)=link(str,"link",[zeros(3),zeros(3)],["ground","ground"],zeros(2),0,0,false,[zeros(3),zeros(3)],NaN,0,zeros(3),zeros(3,2),[zeros(2,2),zeros(2,2)])

function Base.show(io::IO, obj::link)
	println(io,"Link:")
	println(io,"Name: ",obj.name)
	println(io,"Location: ",obj.location)
	println(io,"Bodies: ",obj.body)
end

function num_fm(obj::link)
	obj.forces+obj.moments
end

# function link(
# name,
# group="link",
# location=[zeros(3),zeros(3)],
# body=["ground","ground"],
# body_number=zeros(2),
# forces=0,
# moments=0,
# twist=false,
# radius=[zeros(3),zeros(3)],
# preload=NaN,
# length=0,
# unit=zeros(3),
# nu=zeros(3,2),
# b_mtx=[zeros(2,2),zeros(2,2)])
# 	new(name,group,location,body,body_number,forces,moments,twist,radius,preload,length,unit,nu,b_mtx)
# end
