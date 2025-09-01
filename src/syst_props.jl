function syst_props(the_system::mbd_system, dir_output::String)

    body_f = open(joinpath(dir_output, "bodydata.out"), "w")
    println(body_f, "###### Body Data\nnum name mass rx ry rz ixx iyy izz ixy iyz ixz")

    # Body data
    idx = 1
    for item in the_system.bodys[1:end-1]
        vals = [
            "{", idx, "} {", item.name, "} ",
            item.mass,
            item.location...,
            item.moments_of_inertia...,
            item.products_of_inertia...
        ]
        println(body_f, join(vals, " "))
        idx += 1
    end
    close(body_f)

    point_f = open(joinpath(dir_output, "pointdata.out"), "w")
    println(point_f, "###### Connection Data\nnum name rx ry rz ux uy uz")

    stiff_f = open(joinpath(dir_output, "stiffnessdata.out"), "w")
    println(
        stiff_f,
        "###### Connection Data\nnum name stiffness damping t_stiffness t_damping",
    )

    # Connection data
    idx = 1
    idx2 = 1

    for item in the_system.rigid_points
        vals = ["{", idx, "} {", item.name, "} ", item.location...]
        if norm(item.axis) > 0
            vec = [vals; item.unit...]
        else
            vec = [vals; "{} {} {}"]
        end
        println(point_f, join(vec, " "))
        idx += 1
    end

    for item in the_system.flex_points
        vals = ["{", idx, "} {", item.name, "} ", item.location...]
        if norm(item.axis) > 0
            vec = [vals; item.unit...]
        else
            vec = [vals; "{} {} {}"]
        end
        println(point_f, join(vec, " "))
        vec = [
            "{", idx2, "} {", item.name, "} ",
            item.stiffness[1], item.damping[1],
            item.stiffness[2], item.damping[2]
        ]
        println(stiff_f, join(vec, " "))
        idx += 1
        idx2 += 1
    end

    for item in the_system.nh_points
        vals = ["{", idx, "} {", item.name, "} ", item.location...]
        if norm(item.axis) > 0
            vec = [vals; item.unit...]
        else
            vec = [vals; "{} {} {}"]
        end
        println(point_f, join(vec, " "))
        idx += 1
    end

    for item in the_system.springs
        vals = [
            "{", idx, "} {", item.name, "} ", item.location[1]..., "{} {} {}\n",
            "{} {} ", item.location[2]..., "{} {} {}"
            ]
        println(point_f, join(vals, " "))
        println(stiff_f, "{", idx2, "} {", item.name, "} ", item.stiffness, " ", item.damping, " {} {}")
        idx += 1
        idx2 += 1
    end

    for item in the_system.links
        vals = [
            "{", idx, "} {", item.name, "} ", item.location[1]..., "{} {} {}\n",
            "{} {} ", item.location[2]..., "{} {} {}"
        ]
        println(point_f, join(vals, " "))
        idx += 1
    end

    for item in the_system.beams
        vals = [
            "{", idx, "} {", item.name, "} ", item.location[1]..., "{} {} {}\n",
            "{} {} ", item.location[2]..., "{} {} {}"
        ]
        println(point_f, join(vals, " "))
        println(stiff_f, "{", idx2, "} {", item.name, "} ", item.stiffness, " {} {} {}")
        idx += 1
        idx2 += 1
    end

    close(point_f)
    close(stiff_f)

    input_f = open(joinpath(dir_output, "inputdata.out"), "w")
    println(input_f, "###### Connection Data\nnum name rx ry rz ux uy uz gain")

    for (idx, item) in enumerate(the_system.actuators)
        vals = [
            "{", idx, "} {", item.name, "} ",
            item.location[1]...,
            item.location[2]...,
            item.gain
        ]
        println(input_f, join(vals, " "))
    end

    close(input_f)

    output_f = open(joinpath(dir_output, "outputdata.out"), "w")
    println(output_f, "###### Connection Data\nnum name rx ry rz ux uy uz gain")

    for (idx, item) in enumerate(the_system.sensors)
        vals = [
            "{", idx, "} {", item.name, "} ",
            item.location[1]...,
            item.location[2]...,
            item.gain
        ]
        println(output_f, join(vals, " "))
    end

    close(output_f)

end  ## Leave