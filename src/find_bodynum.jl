    ## Copyright (C) 2017, Bruce Minaker
    ## find_bodynum.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## find_bodynum.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------
function find_bodynum!(item::Union{spring, link, rigid_point, flex_point, nh_point, beam, actuator, sensor}, idx::Dict)
    for i in 1:2
        j = get(idx, item.body[i], nothing)
        if isnothing(j)
            error("Item $(item.name) is attached to missing body!")
        else
            item.body_number[i] = j
        end
    end
end

function find_bodynum!(item::Union{body, load}, idx::Dict)
    nothing
end

function find_bodyframenum!(item::load, idx::Dict)
    i = get(idx, item.body, nothing)
    if isnothing(i)
        error("Item $(item.name) is attached to a missing body!")
    else
        item.body_number = i
    end
    j = get(idx, item.frame, nothing)
    if isnothing(j)
        error("Item $(item.name) is attached a missing frame!")
    else
        item.frame_number = j
    end
end

function find_actnum!(item::sensor, idx)
    if !(item.actuator == "ground")
        i = get(idx, item.actuator, nothing)
        if isnothing(i)
            error("Item $(item.name) actuator not found!")
        end
        item.actuator_number = i
    end
end
