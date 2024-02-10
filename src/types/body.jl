export body
export name
export location
export weight
export mass_mtx

Base.@kwdef mutable struct body
    name::String
    group::String = "body"
    location::Vector{Float64} = zeros(3)
    orientation::Vector{Float64} = zeros(3)
    mass::Float64 = 0
    moments_of_inertia::Vector{Float64} = zeros(3)
    products_of_inertia::Vector{Float64} = zeros(3)
    velocity::Vector{Float64} = zeros(3)
    angular_velocity::Vector{Float64} = zeros(3)
    deflection::Vector{Float64} = [NaN, NaN, NaN]
    angular_deflection::Vector{Float64} = [NaN, NaN, NaN]
    x3d::String = ""
end

body(str::String) = body(; name = str)

function Base.show(io::IO, obj::body)
    println(io, "Body:")
    println(io, "Name: ", obj.name)
    println(io, "Location: ", obj.location)
    println(io, "Inertia: ", inertia_mtx(obj))
    println(io, "Mass: ", obj.mass)
    println(io, "Velocity: ", obj.velocity)
    println(io, "Angular velocity: ", obj.angular_velocity)
end

function lcn_orn(obj::body)
    [obj.location; obj.orientation]
end

function welocity(obj::body)
    [obj.velocity; obj.angular_velocity]
end

function inertia_mtx(obj::body)
    diagm(0 => obj.moments_of_inertia) - diagm(1 => obj.products_of_inertia[1:2]) - diagm(-1 => obj.products_of_inertia[1:2]) - diagm(2 => [obj.products_of_inertia[3]]) - diagm(-2 => [obj.products_of_inertia[3]])
end

function mass_mtx(obj::body)
    [obj.mass*(zeros(3, 3)+I) zeros(3, 3); zeros(3, 3) inertia_mtx(obj)]  ## Stack mass and inertia terms
end

function weight(obj::body, g = 9.81)
    length(g) == 1 && (g *= [0, 0, -1])
    item = load("$(obj.name) weight")
    item.body = obj.name
    item.location = obj.location
    item.force = obj.mass * g
    item.moment = [0, 0, 0]
    item
end
