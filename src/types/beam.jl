export beam

Base.@kwdef mutable struct beam
    name::String
    group::String = "beam"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 2
    moments::Int = 2
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    stiffness::Vector{Float64} = [0, 0]
    mpul::Float64 = 0
    length::Float64 = 0
    preload::Vector{Float64} = [NaN, NaN, NaN, NaN]
    unit::Vector{Float64} = zeros(3)
    perp::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(2, 3), zeros(2, 3)]
    force::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    moment::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
end

beam(str::String) = beam(; name = str)

function Base.show(io::IO, obj::beam)
    println(io, "Beam:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
end

function ptr(obj::beam)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::beam)
    obj.forces + obj.moments
end
