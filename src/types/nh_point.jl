export nh_point

mutable struct nh_point
    name::String
    group::String
    body::Vector{String}
    body_number::Vector{Int}
    forces::Int
    moments::Int
    radius::Vector{Vector{Float64}}
    location::Vector{Float64}
    axis::Vector{Float64}
    rolling_axis::Vector{Float64}
    unit::Vector{Float64}
    rolling_unit::Vector{Float64}
    nu::Array{Float64,2}
    b_mtx::Vector{Array{Float64,2}}
end

nh_point(str::String) = nh_point(str, "nh_point", ["ground", "ground"], zeros(2), 0, 0, [zeros(3), zeros(3)], zeros(3), zeros(3), zeros(3), zeros(3), zeros(3), zeros(3, 2), [zeros(3, 3), zeros(3, 3)])

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
