export load

type load
	name::String
	group::String
	location::Vector{Float64}
	body::String
	body_number::Int
	force::Vector{Float64}
	moment::Vector{Float64}
	radius::Vector{Float64}
	frame::String
	frame_number::Int

	function load(
	name,
	group="load",
	location=[0,0,0],
	body="ground",
	body_number=0,
	force=[0,0,0],
	moment=[0,0,0],
	radius=[0,0,0],
	unit=[0,0,0],
	nu=[[0,0,0] [0,0,0]],
	frame="ground",
	frame_number=0)
		new(name,group,location,body,body_number,force,moment,radius,frame,frame_number)
	end
end
