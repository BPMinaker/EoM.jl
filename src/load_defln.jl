function load_defln(the_system::mbd_system, dir_output::String)

    preload_f = open(joinpath(dir_output, "preload.out"), "w")
    println(preload_f, "###### Preload\nnum name type fx fy fz fxyz")

    defln_f = open(joinpath(dir_output, "defln.out"), "w")
    println(defln_f, "###### Deflection\nnum name type x y z")

    idx = 1
    for item in [the_system.rigid_points; the_system.flex_points]
        vals_force = ["{$idx}", "{", item.name, "}", "force", item.force..., norm(item.force)]
        println(preload_f, join(vals_force, " "))
        vals_moment = ["{} {}", "moment", item.moment..., norm(item.moment)]
        println(preload_f, join(vals_moment, " "))
        idx += 1
    end

    for item in [the_system.springs; the_system.links]
        vals = ["{$idx}", "{", item.name, "}"]
        if item.twist == 0
            vals_force = [vals..., "force", item.force..., item.preload]
            println(preload_f, join(vals_force, " "))
        else
            vals_moment = [vals..., "moment", item.moment..., item.preload]
            println(preload_f, join(vals_moment, " "))
        end
        idx += 1
    end

    for item in the_system.beams
        vals_shear1 = ["{$idx}", "{", item.name, "}", "shear", item.force[1]..., norm(item.force[1])]
        vals_moment1 = ["{} {}", "moment", item.moment[1]..., norm(item.moment[1])]
        vals_shear2 = ["{} {}", "shear", item.force[2]..., norm(item.force[2])]
        vals_moment2 = ["{} {}", "moment", item.moment[2]..., norm(item.moment[2])]
        println(preload_f, join(vals_shear1, " "))
        println(preload_f, join(vals_moment1, " "))
        println(preload_f, join(vals_shear2, " "))
        println(preload_f, join(vals_moment2, " "))
        idx += 1
    end

    for (idx, item) in enumerate(the_system.bodys[1:end - 1])
        vals_trans = ["{$idx}", "{", item.name, "}", "translation", item.deflection...]
        vals_rot = ["{ } { }", "rotation", item.angular_deflection...]
        println(defln_f, join(vals_trans, " "))
        println(defln_f, join(vals_rot, " "))
    end

    close(preload_f)
    close(defln_f)

end ## Leave
