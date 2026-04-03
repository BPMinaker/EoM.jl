# Find the distance from each location to the associated body centre of mass
# Copyright (C) 2021, Bruce Minaker

function find_radius!(item::Union{link, spring, beam, sensor, actuator}, locations::Vector{Vector{Float64}})
    item.radius = [item.location[i] - locations[item.body_number[i]] for i in 1:2]
end

function find_radius!(item::Union{rigid_point, flex_point, nh_point}, locations::Vector{Vector{Float64}})

    item.radius = [item.location - locations[item.body_number[i]] for i in 1:2]
end

function find_radius!(item::Union{load, wing}, locations::Vector{Vector{Float64}})
    item.radius = item.location - locations[item.body_number]
end

function find_radius!(item::body, locations)

end
