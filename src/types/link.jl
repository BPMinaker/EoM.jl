export link

Base.@kwdef mutable struct link
    name::String
    group::String = "link"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    twist::Bool = false
    preload::Float64 = NaN
    length::Float64 = 0
    unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(1, 3), zeros(1, 3)]
    force::Vector{Float64} = zeros(3)
    moment::Vector{Float64} = zeros(3)
end

link(str::String) = link(; name = str)

function Base.show(io::IO, obj::link)
    println(io, "Link:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
    println(io, "Preload: ", obj.preload)
end

function ptr(obj::link)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::link)
    obj.forces + obj.moments
end
