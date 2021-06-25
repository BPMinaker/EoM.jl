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
    if !(item isa body) && !(item isa load)
        for i in 1:2
            j = findnext(item.body[i] .== names, 1)
            if j === nothing
                error("Item $(item.name) is attached to missing body!")
            else
                item.body_number[i] = j
            end
        end
    end
end

function find_bodyframenum!(item, names)
    i = findnext(item.body .== names, 1)
    j = findnext(item.frame .== names, 1)
    if i === nothing
        error("Item $(item.name) is attached to a missing body!")
    end
    if j === nothing
        error("Item $(item.name) is attached a missing frame!")
    end
    item.body_number = i
    item.frame_number = j
end

function find_actnum!(item, names)
    if !(item.actuator == "ground")
        i = findnext(item.actuator .== names, 1)
        if i === nothing
            error("Item $(item.name) actuator not found!")
        end
        item.actuator_number = i
    end
end
