export rigid_point

Base.@kwdef mutable struct rigid_point
    name::String
    group::String = "rigid_point"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Float64} = zeros(3)
    axis::Vector{Float64} = zeros(3)
    rolling_axis::Vector{Float64} = zeros(3)
    preload::Vector{Float64} = Vector{Float64}(undef, 0)
    unit::Vector{Float64} = zeros(3)
    rolling_unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(3, 3), zeros(3, 3)]
    force::Vector{Float64} = zeros(3)
    moment::Vector{Float64} = zeros(3)
end

rigid_point(str::String) = rigid_point(; name = str)

function Base.show(io::IO, obj::rigid_point)
    println(io, "Rigid point:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
end

function ptr(obj::rigid_point)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::rigid_point)
    obj.forces + obj.moments
end
