function const_frc_deal!(the_system, lambda, verb)
    ## Copyright (C) 2017 Bruce Minaker
    ## const_frc_deal.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## cnst_frc_deal.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Distribute preload solution results to individual items... order is important: rigids, then flex
    ## Important because the contents of variable lambda are being shifted throughout the process
    verb && println("Distributing constraint forces...")

    for i in the_system.links
        i.preload = lambda[1]
        lambda = circshift(lambda, -1)
        i.force = i.b_mtx[1]' * [i.preload][1:i.forces]
        i.moment = i.b_mtx[2]' * [i.preload][i.forces+1:end]
    end

    for i in the_system.rigid_points
        num = num_fm(i)  ## Num = the sum of the *number of* forces and moments in the point item
        i.preload = lambda[1:num]
        lambda = circshift(lambda, -num)  ## Performs a circular shift on lambda, equal to the number of forces and moments in the point item
        i.force = i.b_mtx[1]' * i.preload[1:i.forces]
        i.moment = i.b_mtx[2]' * i.preload[i.forces+1:end]
    end

    for i in the_system.springs
        i.preload = lambda[1]
        lambda = circshift(lambda, -1)
        i.force = i.b_mtx[1]' * [i.preload][1:i.forces]
        i.moment = i.b_mtx[2]' * [i.preload][i.forces+1:end]
    end

    for i in the_system.flex_points
        num = num_fm(i)  ## Num = the sum of the *number of* forces and moments in the point item
        i.preload = lambda[1:num]
        lambda = circshift(lambda, -num)  ## Performs a circular shift on lambda, equal to the number of forces and moments in the point item
        i.force = i.b_mtx[1]' * i.preload[1:i.forces]
        i.moment = i.b_mtx[2]' * i.preload[i.forces+1:end]
    end

    for i in the_system.beams
        i.preload = lambda[1:8]
        lambda = circshift(lambda, -8)

        i.force[1] = i.b_mtx[1]' * i.preload[1:2]
        i.moment[1] = i.b_mtx[2]' * i.preload[3:4]
        i.force[2] = i.b_mtx[1]' * i.preload[5:6]
        i.moment[2] = i.b_mtx[2]' * i.preload[7:8]

    end

end ## Leave
