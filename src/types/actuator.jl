export actuator
export name
export gain
export rate_gain

Base.@kwdef mutable struct actuator
    name::String
    group::String = "actuator"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    twist::Bool = false
    gain::Float64 = 1
    rate_gain::Float64 = 0
    length::Float64 = 0
    unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(1, 3), zeros(1, 3)]
    units::String = "N"
end

actuator(str::String) = actuator(; name = str)

function Base.show(io::IO, obj::actuator)
    println(io, "Actuator:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
end

function ptr(obj::actuator)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::actuator)
    obj.forces + obj.moments
end
