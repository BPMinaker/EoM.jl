function mirror!(the_system::mbd_system)

    for old in the_system.item
        if occursin("LF ", old.name) || occursin("LR ", old.name) || occursin("_lf", old.name) || occursin("_lr", old.name)

            item = deepcopy(old)

            item.name = replace(item.name, "LF" => "RF")
            item.name = replace(item.name, "LR" => "RR")

            item.name = replace(item.name, "lf" => "rf")
            item.name = replace(item.name, "lr" => "rr")

            if isa(item, body)

                item.location[2] = -item.location[2]
                item.products_of_inertia[1] = -item.products_of_inertia[1]
                item.products_of_inertia[2] = -item.products_of_inertia[2]
                add_item!(item, the_system)

            elseif isa(item, rigid_point) || isa(item, flex_point)

                item.body[1] = replace(item.body[1], "LF" => "RF")
                item.body[1] = replace(item.body[1], "LR" => "RR")
                item.body[2] = replace(item.body[2], "LF" => "RF")
                item.body[2] = replace(item.body[2], "LR" => "RR")

                item.location[2] = -item.location[2]
                item.axis[2] = -item.axis[2]
                item.rolling_axis[2] = -item.rolling_axis[2]
                add_item!(item, the_system)

            elseif isa(item, link) || isa(item, spring) || isa(item, beam)

                item.body[1] = replace(item.body[1], "LF" => "RF")
                item.body[1] = replace(item.body[1], "LR" => "RR")
                item.body[2] = replace(item.body[2], "LF" => "RF")
                item.body[2] = replace(item.body[2], "LR" => "RR")

                item.location[1][2] = -item.location[1][2]
                item.location[2][2] = -item.location[2][2]
                add_item!(item, the_system)

            elseif isa(item, sensor) || isa(item, actuator)

                item.body[1] = replace(item.body[1], "LF" => "RF")
                item.body[1] = replace(item.body[1], "LR" => "RR")
                item.body[2] = replace(item.body[2], "LF" => "RF")
                item.body[2] = replace(item.body[2], "LR" => "RR")

                del = item.location[2] - item.location[1]
                item.location[1][2] = -item.location[1][2]
                item.location[2] = item.location[1] + del
                add_item!(item, the_system)

            elseif isa(item, load)

                item.body = replace(item.body, "LF" => "RF")
                item.body = replace(item.body, "LR" => "RR")

                item.location[2] = -item.location[2]
                item.force[2] = -item.force[2]
                item.moment[2] = -item.moment[2]
                add_item!(item, the_system)

            end
        end
    end
end ## Leave
