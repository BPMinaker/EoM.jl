## Copyright (C) 2021, Bruce Minaker
#     ## find_radius.jl is free software; you can redistribute it and/or modify it
#     ## under the terms of the GNU General Public License as published by
#     ## the Free Software Foundation; either version 2, or (at your option)
#     ## any later version.
#     ##
#     ## find_radius.jl is distributed in the hope that it will be useful, but
#     ## WITHOUT ANY WARRANTY; without even the implied warranty of
#     ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
#     ##
#     ##--------------------------------------------------------------------

#     ## Find the distance from each location to the associated body centre of mass

function find_radius!(item::Union{link, spring, beam, sensor, actuator}, locations::Vector{Vector{Float64}})
    item.radius[1] = item.location[1] - locations[item.body_number[1]]
    item.radius[2] = item.location[2] - locations[item.body_number[2]]
end

function find_radius!(item::Union{rigid_point, flex_point, nh_point}, locations::Vector{Vector{Float64}})
    item.radius[1] = item.location - locations[item.body_number[1]]
    item.radius[2] = item.location - locations[item.body_number[2]]
end

function find_radius!(item::load, locations::Vector{Vector{Float64}})
    item.radius = item.location - locations[item.body_number]
end

function find_radius!(item::body, locations)

end