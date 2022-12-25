function find_bodynum!(item::Union{body, load}, idx::Dict)
    nothing
end

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
