function find_radius!(item, locations)
    ## Copyright (C) 2017, Bruce Minaker
    ## find_radius.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## find_radius.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Find the distance from each location to the associated body centre of mass

    if item isa body
        return
    elseif item isa link || item isa spring || item isa beam || item isa sensor || item isa actuator
        item.radius[1] = item.location[1] - locations[item.body_number[1]]
        item.radius[2] = item.location[2] - locations[item.body_number[2]]
    elseif item isa rigid_point || item isa flex_point || item isa nh_point
        item.radius[1] = item.location - locations[item.body_number[1]]
        item.radius[2] = item.location - locations[item.body_number[2]]
    elseif item isa load
        item.radius = item.location - locations[item.body_number]
    else
        error("Unknown type.")
    end
end

