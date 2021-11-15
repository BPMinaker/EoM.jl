function input_n_dof(args...; n = 10, m = 1, k = 1)
    the_system = mbd_system("n dof test")

    ## Copyright (C) 2017, Bruce Minaker
    ## input_n_dof.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_n_dof.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    free = any(args .== :free)

    j = Int64(round(n / 2))

    for i = 1:j
        item = body("lower block $i")
        item.mass = m
        item.location = [i - j / 2 - 0.5, 0, 0] * 0.1
        add_item!(item, the_system)
    end

    for i = 1:j
        item = body("upper block $i")
        item.mass = m
        item.location = [i - j / 2 - 0.5, 1, 0] * 0.1
        add_item!(item, the_system)
    end

    for i = 1:j
        item = rigid_point("lower slider $i")
        item.body[1] = "lower block $i"
        item.body[2] = "ground"
        item.location = [i - j / 2 - 0.5, 0, 0] * 0.1
        item.forces = 2
        item.moments = 3
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    for i = 1:j
        item = rigid_point("upper slider $i")
        item.body[1] = "upper block $i"
        item.body[2] = "ground"
        item.location = [i - j / 2 - 0.5, 1, 0] * 0.1
        item.forces = 2
        item.moments = 3
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    for i = 1:j-1
        item = flex_point("lower spring $i")
        item.body[1] = "lower block $i"
        item.body[2] = "lower block $(i+1)"
        item.location = [i - j / 2, 0, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    for i = 1:j-1
        item = flex_point("upper spring $i")
        item.body[1] = "upper block $i"
        item.body[2] = "upper block $(i+1)"
        item.location = [i - j / 2, 1, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    if !free
        item = flex_point("lower spring 0")
        item.body[1] = "lower block 1"
        item.body[2] = "ground"
        item.location = [-j / 2, 0, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)

        item = flex_point("lower spring $j")
        item.body[1] = "lower block $j"
        item.body[2] = "ground"
        item.location = [j / 2, 0, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)

        item = flex_point("upper spring 0")
        item.body[1] = "upper block 1"
        item.body[2] = "ground"
        item.location = [-j / 2, 1, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)

        item = flex_point("upper spring $j")
        item.body[1] = "upper block $j"
        item.body[2] = "ground"
        item.location = [j / 2, 1, 0] * 0.1
        item.stiffness = [k, 0]
        item.forces = 1
        item.moments = 0
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    item = actuator("f")
    item.body[1] = "lower block 2"
    item.body[2] = "upper block $(j-1)"
    item.location[1] = [-1, 0.5, -0.2] * 0.1
    item.location[2] = [1, 0.5, -0.2] * 0.1
    add_item!(item, the_system)

    item = sensor("kx")
    item.body[1] = "lower block $(j-1)"
    item.body[2] = "upper block 2"
    item.location[1] = [1, 0.5, 0.2] * 0.1
    item.location[2] = [-1, 0.5, 0.2] * 0.1
    item.gain = k
    add_item!(item, the_system)

    the_system

end
