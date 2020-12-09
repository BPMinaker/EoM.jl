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
function find_bodynum!(item, names)
    if ~(item isa body) && ~(item isa load)
        item.body_number[1] = findnext(item.body[1] .== names, 1)
        item.body_number[2] = findnext(item.body[2] .== names, 1)
        if item.body_number[1] === nothing || item.body_number[2] === nothing
            error("Item $(item.name) is attached to missing body!")
        end
    end
end

function find_bodyframenum!(item, names)
    item.body_number = findnext(item.body .== names, 1)
    item.frame_number = findnext(item.frame .== names, 1)
    if item.body_number === nothing
        error("Item $(item.name) is attached to a missing body!")
    end
    if item.frame_number === nothing
        error("Item $(item.name) is attached a missing frame!")
    end
end

function find_actnum!(item, names)
    if item.actuator != "ground"
        item.actuator_number = findnext(item.actuator .== names, 1)
        if item.actuator_number === nothing
            error("Item $(item.name) actuator not found!")
        end
    end
end
