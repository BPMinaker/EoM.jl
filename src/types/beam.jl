export beam

mutable struct beam
    name::String
    group::String
    body::Vector{String}
    body_number::Vector{Int}
    forces::Int
    moments::Int
    radius::Vector{Vector{Float64}}
    location::Vector{Vector{Float64}}
    stiffness::Vector{Float64}
    mpul::Float64
    length::Float64
    preload::Vector{Float64}
    unit::Vector{Float64}
    perp::Vector{Float64}
    nu::Array{Float64,2}
    b_mtx::Vector{Array{Float64,2}}
    force::Vector{Vector{Float64}}
    moment::Vector{Vector{Float64}}
end

beam(str::String) =
    beam(str, "beam", ["ground", "ground"], zeros(2), 2, 2, [zeros(3), zeros(3)], [zeros(3), zeros(3)], [0, 0], 0, 0, [NaN, NaN, NaN, NaN], zeros(3), zeros(3), zeros(3, 2), [zeros(2, 3), zeros(2, 3)], [zeros(3), zeros(3)], [zeros(3), zeros(3)])

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
