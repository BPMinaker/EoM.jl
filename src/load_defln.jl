function load_defln(the_system::mbd_system, dir_output::String)
    ## Copyright (C) 2017, Bruce Minaker
    ## load_defln.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## load_defln.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    preload_f = open(joinpath(dir_output, "preload.out"), "w")
    println(preload_f, "###### Preload\nnum name type fx fy fz fxyz")

    defln_f = open(joinpath(dir_output, "defln.out"), "w")
    println(defln_f, "###### Deflection\nnum name type x y z")

    idx = 1
    for item in [the_system.rigid_points; the_system.flex_points]
        print(preload_f, "{$idx} {" * item.name * "} ")
        println(preload_f, "force $(item.force[1]), $(item.force[2]), $(item.force[3]), $(norm(item.force))")
        print(preload_f, "{} {} ")
        println(preload_f, "moment $(item.moment[1]), $(item.moment[2]), $(item.moment[3]), $(norm(item.moment))")
        idx += 1
    end

    for item in [the_system.springs; the_system.links]

        print(preload_f, "{$idx} {" * item.name * "} ")
        if item.twist == 0
            println(preload_f, "force $(item.force[1]), $(item.force[2]), $(item.force[3]), $(item.preload)")
        else
            println(preload_f, "moment $(item.moment[1]), $(item.moment[2]), $(item.moment[3]), $(item.preload)")
        end
        idx += 1
    end

    for item in the_system.beams
        println(preload_f, "{$idx} {" * item.name * "} shear $(item.force[1][1]), $(item.force[1][2]), $(item.force[1][3]), $(norm(item.force[1]))")
        println(preload_f, "{} {} moment $(item.moment[1][1]), $(item.moment[1][2]), $(item.moment[1][3]), $(norm(item.moment[1]))")
        println(preload_f, "{} {} shear $(item.force[2][1]), $(item.force[2][2]), $(item.force[2][3]), $(norm(item.force[2]))")
        println(preload_f, "{} {} moment $(item.moment[2][1]), $(item.moment[2][2]), $(item.moment[2][3]), $(norm(item.moment[2]))")
        idx += 1
    end

    idx = 1
    for item in the_system.bodys[1:end - 1]
        println(defln_f, "{$idx} {" * item.name * "} translation $(item.deflection[1]), $(item.deflection[2]), $(item.deflection[3])")
        println(defln_f, "{ } { } rotation $(item.angular_deflection[1]), $(item.angular_deflection[2]), $(item.angular_deflection[3])")
        idx += 1
    end

    close(preload_f)
    close(defln_f)

end ## Leave
