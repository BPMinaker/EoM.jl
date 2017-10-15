export spring

type spring
	name::String
	group::String
	location::Vector{Vector{Float64}}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	twist::Bool
	radius::Vector{Vector{Float64}}
	stiffness::Float64
	damping::Float64
	preload::Float64
	inertance::Float64
	length::Float64
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function spring(
	name,
	group="spring",
	location=[zeros(3),zeros(3)],
	body=["ground","ground"],
	body_number=zeros(2),
	forces=0,
	moments=0,
	twist=false,
	radius=[zeros(3),zeros(3)],
	stiffness=0,
	damping=0,
	preload=NaN,
	inertance=0,
	length=0,
	unit=zeros(3),
	nu=zeros(3,2),
	b_mtx=[zeros(2,2),zeros(2,2)])
		new(name,group,location,body,body_number,forces,moments,twist,radius,stiffness,damping,preload,inertance,length,unit,nu,b_mtx)
	end
end

function stiffness(obj::spring)
	obj.stiffness
end

function damping(obj::spring)
	obj.damping
end

function preload(obj::spring)
	obj.preload
end

function inertance(obj::spring)
	obj.inertance
end

function num_fm(obj::spring)
	obj.forces+obj.moments
end
