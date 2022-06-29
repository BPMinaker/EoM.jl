export nh_point

Base.@kwdef mutable struct nh_point
    name::String
    group::String = "nh_point"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Float64} = zeros(3)
    axis::Vector{Float64} = zeros(3)
    rolling_axis::Vector{Float64} = zeros(3)
    unit::Vector{Float64} = zeros(3)
    rolling_unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(3, 3), zeros(3, 3)]
end

nh_point(str::String) = nh_point(; name = str)

function Base.show(io::IO, obj::nh_point)
    println(io, "Nonholonomic point:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
end

function ptr(obj::nh_point)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::nh_point)
    obj.forces + obj.moments
end
