function point_line_jacobian(items::Union{Vector{link}, Vector{spring}, Vector{beam}, Vector{flex_point}, Vector{rigid_point}, Vector{nh_point}, Vector{sensor}, Vector{actuator}}, num::Int64)
    ## Copyright (C) 2017, Bruce Minaker
    ## point_line_jacobian.m is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## point_line_jacobian.m is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------
    ## Function 'point_line_jacobian' returns 'mtx' (constraint or deflection matrix of point items) as a function of 'in' (items in system) and 'num' (number of bodies)

    nr = sum(num_fm.(items))  ## Find total number of rows needed
    mtx = zeros(nr, 6 * num)  ## Initially define blank matrix

    idx = 1
    for i in items
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)

        srs = skew(i.radius[1])  ## Radius of the point item from the CG at 'start' body
        sre = skew(i.radius[2])  ## Radius of the point item from the CG at 'end' body

        B1 = [i.b_mtx[1] -i.b_mtx[1] * srs; zeros(i.moments, 3) i.b_mtx[2]] ## The skew rs makes 'theta'x'r'...
        B2 = [i.b_mtx[1] -i.b_mtx[1] * sre; zeros(i.moments, 3) i.b_mtx[2]] ## rotation of the body that creates a translation at the joint, i.e, x1-theta*r = 0

        nrows = num_fm(i)
        B = zeros(nrows, 6 * num)
        B[:, ptr_1.+(1:6)] = B1 ## Positive
        B[:, ptr_2.+(1:6)] = -B2 ## Negative, so the equations sum to zero, i.e x1 - x3 = 0

        idxe = idx + nrows - 1
        mtx[idx:idxe, :] = B ## Stack up the matrix for each flex point or rigid point
        idx = idxe + 1
    end

    n = 6 * (num - 1)
    mtx[:, 1:n]  ## Eliminate ground from matrix (all items of ground motion will be zero anyhow)

end  ## Leave
