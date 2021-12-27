function force!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## force.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## force.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------
    ## function 'force' returns 'vec' (external loads), 'mtx' (stiffness matrix for angular motion resulting from applied forces) as a function of 'in' (the loads) and 'num' (the number of bodies)

    verb && println("Summing external forces...")

    num = length(the_system.bodys)
    vec = zeros(6 * num) ## Vec (force vector) is defined as zero vector
    mtx = zeros(6 * num, 6 * num) ## mtx (stiffness matrix) is defined as zero matrix

    for i in the_system.loads ## for each external loads
        ptr_1 = 6 * (i.body_number - 1)  ## Row or column where this info is stored
        ptr_2 = 6 * (i.frame_number - 1)

        ## Total moment = applied moment + (r cross f) <-using skew symmetric matrix
        vec[ptr_1.+(1:3)] += i.force ## Adds force vector to rows 1,2,3 (for mass 1) of column vector
        vec[ptr_1.+(4:6)] += i.moment + (skew(i.radius) * i.force) ## Adds moment vector to rows 4,5,6 (for mass 1) of column vector

        mtx[ptr_1.+(1:3), ptr_1.+(4:6)] -= skew(i.force)
        mtx[ptr_1.+(1:3), ptr_2.+(4:6)] += skew(i.force)  ## Note same row, different column

        mtx[ptr_1.+(4:6), ptr_1.+(4:6)] -= skew(i.radius) * skew(i.force) + skew(i.moment)
        mtx[ptr_1.+(4:6), ptr_2.+(4:6)] += skew(i.radius) * skew(i.force) + skew(i.moment)  ## If 'body' = 'axes', then matrix terms will cancel
    end

    n = 6 * (num - 1)
    data.force = vec[1:n]
    data.load_stiffness = mtx[1:n, 1:n]

end  ## Leave
