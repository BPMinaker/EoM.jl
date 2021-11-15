export actuator
export name
export gain
export rate_gain

mutable struct actuator
    name::String
    group::String
    body::Vector{String}
    body_number::Vector{Int}
    forces::Int
    moments::Int
    radius::Vector{Vector{Float64}}
    location::Vector{Vector{Float64}}
    twist::Bool
    gain::Float64
    rate_gain::Float64
    length::Float64
    unit::Vector{Float64}
    nu::Array{Float64,2}
    b_mtx::Vector{Array{Float64,2}}
    units::String
end

actuator(str::String) = actuator(str, "actuator", ["ground", "ground"], zeros(2), 0, 0, [zeros(3), zeros(3)], [zeros(3), zeros(3)], false, 1, 0, 0, zeros(3), zeros(3, 2), [zeros(1, 3), zeros(1, 3)], "N")

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
