function input_ex_beam(; EI1 = 1, EI2 = 1, mpul = 1, l = 1, n = 1)

    ## Copyright (C) 2021, Bruce Minaker
    ## This file is intended for use with Octave.
    ## input_ex_beam.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## input_ex_beam.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    # this input file joins together n beams, each of length l
    # they are joined by massless bodies to act as nodes
    # as you add more beams, the order of the model increases, and it more closely approximates the analytical solution given below
    # it only takes about 5 or 6 beams to match the analytical solution to five significant figures

    # for a cantilever beam, the first three natural frequencies are
    # ω_1 = 1.875^2 (EI/mpul L^4)^0.5
    # ω_2 = 4.694^2 ...
    # ω_3 = 7.885^2 ...
    # note L = nl

    # println(((1.875 / (n * l))^2 * (EI / mpul)^0.5) / 2pi)

    the_system = mbd_system("Beam")

    for i = 1:n

        item = body("body $i")
        item.location = [i * l, 0, 0.1]
        add_item!(item, the_system)

        item = beam("beam $i")
        item.body[1] = "body $i"
        item.body[2] = "body $(i-1)"
        item.location[1] = [i * l, 0, 0.1]
        item.location[2] = [(i - 1) * l, 0, 0.1]
        item.perp = [0, 1, 0]
        item.stiffness = [EI1, EI2]
        item.mpul = mpul
        add_item!(item, the_system)

        item = rigid_point("x $i")
        item.body[1] = "body $i"
        item.body[2] = "ground"
        item.location = [i * l, 0, 0.1]
        item.forces = 1
        item.moments = 1
        item.axis = [1, 0, 0]
        add_item!(item, the_system)
    end

    the_system.item[2].body[2] = "ground"

    item = actuator("Y")
    item.body[1] = "body $n"
    item.body[2] = "ground"
    item.location[1] = [n * l, 0, 0.1]
    item.location[2] = [n * l, -0.1, 0.1]
    item.units = "N"
    add_item!(item, the_system)

    item = sensor("ky")
    item.body[1] = "body $n"
    item.body[2] = "ground"
    item.location[1] = [n * l, 0, 0.1]
    item.location[2] = [n * l, -0.1, 0.1]
    item.gain = 3 * EI1 / (n * l)^3
    item.units = "N"
    add_item!(item, the_system)

    item = actuator("Z")
    item.body[1] = "body $n"
    item.body[2] = "ground"
    item.location[1] = [n * l, 0, 0.1]
    item.location[2] = [n * l, 0, 0]
    item.units = "N"
    add_item!(item, the_system)

    item = sensor("kz")
    item.body[1] = "body $n"
    item.body[2] = "ground"
    item.location[1] = [n * l, 0, 0.1]
    item.location[2] = [n * l, 0, 0]
    item.gain = 3 * EI2 / (n * l)^3
    item.units = "N"
    add_item!(item, the_system)

    the_system

end
