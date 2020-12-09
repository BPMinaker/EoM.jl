function syst_props(the_system, dir_output)
    ## Copyright (C) 2017, Bruce Minaker
    ## syst_props.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## syst_props.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    body_f = open(joinpath(dir_output, "bodydata.out"), "w")
    println(body_f, "###### Body Data\nnum name mass rx ry rz ixx iyy izz ixy iyz ixz")

    point_f = open(joinpath(dir_output, "pointdata.out"), "w")
    println(point_f, "###### Connection Data\nnum name rx ry rz ux uy uz")

    stiff_f = open(joinpath(dir_output, "stiffnessdata.out"), "w")
    println(
        stiff_f,
        "###### Connection Data\nnum name stiffness damping t_stiffness t_damping",
    )

    ## Body data
    idx = 1
    for item in the_system.bodys[1:end-1]
        print(
            body_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.mass,
            " ",
            item.location[1],
            " ",
            item.location[2],
            " ",
            item.location[3],
            " ",
        )
        print(
            body_f,
            item.moments_of_inertia[1],
            " ",
            item.moments_of_inertia[2],
            " ",
            item.moments_of_inertia[3],
            " ",
        )
        println(
            body_f,
            item.products_of_inertia[1],
            " ",
            item.products_of_inertia[2],
            " ",
            item.products_of_inertia[3],
        )
        idx += 1
    end
    close(body_f)

    ## Connection data
    idx = 1
    for item in the_system.rigid_points
        print(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1],
            " ",
            item.location[2],
            " ",
            item.location[3],
            " ",
        )
        if norm(item.axis) > 0
            println(point_f, item.unit[1], " ", item.unit[2], " ", item.unit[3])
        else
            println(point_f, "{} {} {}")
        end
        idx += 1
    end

    idx2 = 1
    for item in the_system.flex_points
        print(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1],
            " ",
            item.location[2],
            " ",
            item.location[3],
            " ",
        )
        if norm(item.axis) > 0
            println(point_f, item.unit[1], " ", item.unit[2], " ", item.unit[3])
        else
            println(point_f, "{} {} {}")
        end
        println(
            stiff_f,
            "{",
            idx2,
            "} {",
            item.name,
            "} ",
            item.stiffness[1],
            " ",
            item.damping[1],
            " ",
            item.stiffness[2],
            " ",
            item.damping[2],
        )
        idx += 1
        idx2 += 1
    end

    for item in the_system.nh_points
        print(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1],
            " ",
            item.location[2],
            " ",
            item.location[3],
            " ",
        )
        if norm(item.axis) > 0
            println(point_f, item.unit[1], " ", item.unit[2], " ", item.unit[3])
        else
            println(point_f, "{} {} {}")
        end
        idx += 1
    end

    for item in the_system.springs
        println(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1][1],
            " ",
            item.location[1][2],
            " ",
            item.location[1][3],
            " {} {} {}",
        )
        println(
            point_f,
            "{} {} ",
            item.location[2][1],
            " ",
            item.location[2][2],
            " ",
            item.location[2][3],
            " {} {} {}",
        )
        println(
            stiff_f,
            "{",
            idx2,
            "} {",
            item.name,
            "} ",
            item.stiffness,
            " ",
            item.damping,
            " {} {}",
        )
        idx += 1
        idx2 += 1
    end

    for item in the_system.links
        println(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1][1],
            " ",
            item.location[1][2],
            " ",
            item.location[1][3],
            " {} {} {}",
        )
        println(
            point_f,
            "{} {} ",
            item.location[2][1],
            " ",
            item.location[2][2],
            " ",
            item.location[2][3],
            " {} {} {}",
        )
        idx += 1
    end

    for item in the_system.beams
        println(
            point_f,
            "{",
            idx,
            "} {",
            item.name,
            "} ",
            item.location[1][1],
            " ",
            item.location[1][2],
            " ",
            item.location[1][3],
            " {} {} {}",
        )
        println(
            point_f,
            "{} {} ",
            item.location[2][1],
            " ",
            item.location[2][2],
            " ",
            item.location[2][3],
            " {} {} {}",
        )
        println(stiff_f, "{", idx2, "} {", item.name, "} ", item.stiffness, " {} {} {}")
        idx += 1
        idx2 += 1
    end

    for item in the_system.actuators
        println(
            point_f,
            "{",
            idx,
            "} {\$",
            item.name,
            "\$} ",
            item.location[1][1],
            " ",
            item.location[1][2],
            " ",
            item.location[1][3],
            " {} {} {}",
        )
        println(
            point_f,
            "{} {} ",
            item.location[2][1],
            " ",
            item.location[2][2],
            " ",
            item.location[2][3],
            " {} {} {}",
        )
        println(stiff_f, "{", idx2, "} {\$", item.name, "\$} ", item.gain, " {} {} {}")
        idx += 1
        idx2 += 1
    end

    for item in the_system.sensors
        println(
            point_f,
            "{",
            idx,
            "} {\$",
            item.name,
            "\$} ",
            item.location[1][1],
            " ",
            item.location[1][2],
            " ",
            item.location[1][3],
            " {} {} {}",
        )
        println(
            point_f,
            "{} {} ",
            item.location[2][1],
            " ",
            item.location[2][2],
            " ",
            item.location[2][3],
            " {} {} {}",
        )
        println(stiff_f, "{", idx2, "} {\$", item.name, "\$} ", item.gain, " {} {} {}")
        idx += 1
        idx2 += 1
    end

    close(point_f)
    close(stiff_f)

end  ## Leave
