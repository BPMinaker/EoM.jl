export sensor
export name
export gain

Base.@kwdef mutable struct sensor
    name::String
    group::String = "sensor"
    body::Vector{String} = ["ground", "ground"]
    body_number::Vector{Int} = zeros(2)
    forces::Int = 0
    moments::Int = 0
    radius::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    location::Vector{Vector{Float64}} = [zeros(3), zeros(3)]
    twist::Bool = false
    gain::Float64 = 1
    order::Int = 1  ## [1 - position, 2- velocity, 3- acceleration ]
    frame::Int = 1  ## [ 0 - local, 1 - global]
    actuator::String = "ground"
    actuator_number::Int = 0
    actuator_gain::Float64 = -1
    length::Float64 = 0
    unit::Vector{Float64} = zeros(3)
    nu::Array{Float64,2} = zeros(3, 2)
    b_mtx::Vector{Array{Float64,2}} = [zeros(1, 3), zeros(1, 3)]
    units::String = "m"
end

sensor(str::String) = sensor(; name = str)

function Base.show(io::IO, obj::sensor)
    println(io, "Sensor:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Bodies: ", obj.body)
end

function ptr(obj::sensor)
    6 * (obj.body_number[1] - 1), 6 * (obj.body_number[2] - 1)
end

function num_fm(obj::sensor)
    obj.forces + obj.moments
end
