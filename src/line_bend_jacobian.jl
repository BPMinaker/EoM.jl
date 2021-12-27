function line_bend_jacobian(items::Union{Vector{link}, Vector{spring}, Vector{beam}, Vector{sensor}, Vector{actuator}}, num::Int64) ## Function 'line_bend_jacobian' returns 'mtx' (constraint or deflection matrix of directed items) as a function of 'in' (directed items in system) and 'num' (number of bodies)
    ## Copyright (C) 2017, Bruce Minaker
    ## line_bend_jacobian.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## line_bend_jacobian.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    mtx = zeros(8 * length(items), 6 * num) ## Initially define deflection matrix as zero matrix

    idx = 1
    for i in items
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)

        srs = skew(i.radius[1])  ## Radius from body1 cg to point of action of directed item on body1; 's'=start
        sre = skew(i.radius[2])  ## Radius from body2 cg to point of action of directed item on body2; 'e'=end

        B1 = [i.b_mtx[1] -i.b_mtx[1] * srs; zeros(i.moments, 3) i.b_mtx[2]] 
        B2 = [i.b_mtx[1] -i.b_mtx[1] * sre; zeros(i.moments, 3) i.b_mtx[2]] 

        B = zeros(8, 6 * num)
        B[1:4, ptr_1.+(1:6)] = B1
        B[5:8, ptr_2.+(1:6)] = B2

        mtx[8*idx.+(-7:0), :] = B
        idx += 1
    end

    n = 6 * (num - 1) ## n = number of bodies -1 = number of bodies not including ground
    mtx[:, 1:n] ## mtx = jacobian / deflection matrix

end ## Leave
