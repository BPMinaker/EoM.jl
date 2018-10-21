export beam

mutable struct beam
	name::String
	group::String
	location::Vector{Vector{Float64}}
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	radius::Vector{Vector{Float64}}
	stiffness::Float64
	s_mtx::Array{Float64,2}
	mpul::Float64
	m_mtx::Array{Float64,2}
	length::Float64
	preload::Vector{Float64}
	unit::Vector{Float64}
	nu::Array{Float64,2}
	b_mtx::Vector{Array{Float64,2}}

	function beam(
	name,
	group="beam",
	location=[zeros(3),zeros(3)],
	body=["ground","ground"],
	body_number=zeros(2),
	forces=2,
	moments=2,
	radius=[zeros(3),zeros(3)],
	stiffness=0,
	s_mtx=zeros(0,0),
	mpul=0,
	m_mtx=zeros(0,0),
	length=0,
	preload=[NaN,NaN,NaN,NaN],
	unit=zeros(3),
	nu=zeros(3,2),
	b_mtx=[zeros(2,2),zeros(2,2)])
		new(name,group,location,body,body_number,forces,moments,radius,stiffness,s_mtx,mpul,m_mtx,length,preload,unit,nu,b_mtx)
	end
end

function num_fm(obj::beam)
	obj.forces+obj.moments
end
