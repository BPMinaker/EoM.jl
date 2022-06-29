export flex_point

Base.@kwdef mutable struct flex_point
    name::String
    group::String = "flex_point"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Float64} = zeros(3)
    axis::Vector{Float64} = zeros(3)
    rolling_axis::Vector{Float64} = zeros(3)
    stiffness::Vector{Float64} = zeros(2)
    s_mtx::Array{Float64,2} = zeros(0, 0)
    damping::Vector{Float64} = zeros(2)
    d_mtx::Array{Float64,2} = zeros(0, 0)
    preload::Vector{Float64} = Vector{Float64}(undef, 0)
    unit::Vector{Float64} = zeros(3)
    rolling_unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(3, 3), zeros(3, 3)]
    force::Vector{Float64} = zeros(3)
    moment::Vector{Float64} = zeros(3)
end

flex_point(str::String) = flex_point(; name = str)
   
function Base.show(io::IO, obj::flex_point)
    println(io, "Flexible point:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
    println(io, "Stiffness: ", obj.stiffness)
    println(io, "Damping: ", obj.damping)
end

function ptr(obj::flex_point)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::flex_point)
    obj.forces + obj.moments
end
