export spring

Base.@kwdef mutable struct spring
    name::String
    group::String = "spring"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    twist::Bool = false
    stiffness::Float64 = 0
    damping::Float64 = 0
    preload::Float64 = NaN
    inertance::Float64 = 0
    length::Float64 = 0
    unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(1, 3), zeros(1, 3)]
    force::Vector{Float64} = zeros(3)
    moment::Vector{Float64} = zeros(3)
end

spring(str::String) = spring(; name = str)

function Base.show(io::IO, obj::spring)
    println(io, "Spring:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
    println(io, "Stiffness: ", obj.stiffness)
    println(io, "Damping: ", obj.damping)
    println(io, "Preload: ", obj.preload)
end

function ptr(obj::spring)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::spring)
    obj.forces + obj.moments
end
