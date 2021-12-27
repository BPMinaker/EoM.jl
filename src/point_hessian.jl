function hessian(items::Union{Vector{flex_point}, Vector{rigid_point}, Vector{nh_point}}, num::Int64)
    ## Copyright (C) 2017, Bruce Minaker
    ## point_hessian.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## point_hessian.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------
    ##
    ## in=flex_points or rigid_points, num=number of bodys, mtx=stiffness

    mtx = zeros(6 * num, 6 * num) ## Initially define blank matrix
    n = 6 * (num - 1) ## n excludes the ground body

    for i in items
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)

        rs = i.radius[1]  ## Radius of the point item from the CG at 'start' body
        re = i.radius[2]  ## Radius of the point item from the CG at 'end' body

        forces = i.forces  ## Definition of type of point constraint (1,2, or 3 LINEAR motions constrained)
        moments = i.moments  ## Definition of type of point constraint (1,2, or 3 ANGULAR motions constrained)
        a = i.unit  ## Axis of constraint
        ra = i.rolling_unit

        if moments < 2 && (forces == 1 || forces == 2) && norm(ra) == 0  ## If frames can misalign, and force has defined direction
            ptr_3 = ptr_2  ## Align unit vector with body2
        else
            ptr_3 = n  ## Else, align with ground
        end

        ## Find constraint forces from Jacobian and Lagrange multipliers
        frc = i.b_mtx[1]' * i.preload[1:forces]
        mmt = i.b_mtx[2]' * i.preload[forces+1:end]

        # Component of force due to change in frame orientation
        ff = skew(frc)
        # Change in force causes a change in moment as well
        ff1 = skew(rs) * skew(frc)
        ff2 = skew(re) * skew(frc)

        ## Force terms
        row = ptr_1 .+ (1:3)
        col = ptr_1 .+ (4:6)
        mtx[row, col] -= ff  ## Body1 motion
        col = ptr_3 .+ (4:6)
        mtx[row, col] += ff  ## Reference motion

        row = ptr_2 .+ (1:3)
        col = ptr_2 .+ (4:6)
        mtx[row, col] += ff  ## Body2 motion
        col = ptr_3 .+ (4:6)
        mtx[row, col] -= ff  ## Reference motion

        ## Moment terms
        row = ptr_1 .+ (4:6)
        col = ptr_1 .+ (4:6)
        mtx[row, col] -= ff1
        col = ptr_3 .+ (4:6)
        mtx[row, col] += ff1

        row = ptr_2 .+ (4:6)
        col = ptr_2 .+ (4:6)
        mtx[row, col] += ff2
        col = ptr_3 .+ (4:6)
        mtx[row, col] -= ff2

        ## If relative motion can occur, assume re varies, so add change in moment to body2
        ## Note that for force==0 or forces==3, this should have no effect, as either force=0 or deflection=0
        ## Translation terms
        row = ptr_2 .+ (4:6)
        col = ptr_1 .+ (1:3)
        mtx[row, col] -= ff
        col = ptr_2 .+ (1:3)
        mtx[row, col] += ff

        ## Rotation terms
        ## Note transpose here: skew(f)skew(r) = transpose(skew(r)skew(f))
        col = ptr_1 .+ (4:6)
        mtx[row, col] += ff1'
        col = ptr_2 .+ (4:6)
        mtx[row, col] -= ff2'

        ## Capture change in direction of moment also
        ## If moments==0 or moments==3, then no terms appear, unless rolling

        if norm(ra) == 1 ## Rolling contact -- ignore effect of constraint moments on tangent stiffness -- correct???
            ff = -ff1' * (ra * ra')

            row = ptr_1 .+ (4:6)
            col = ptr_1 .+ (4:6)
            mtx[row, col] -= ff  ## Body1 motion
            col = ptr_2 .+ (4:6)
            mtx[row, col] += ff  ## Reference motion

            row = ptr_2 .+ (4:6)
            col = ptr_2 .+ (4:6)
            mtx[row, col] -= ff  ## Body2 motion
            col = ptr_1 .+ (4:6)
            mtx[row, col] += ff  ## Reference motion

        elseif moments == 2 ## If hinge or revolute joint
            ff = skew(mmt) * (a * a')  ## Note (aa')(theta) is the component of theta in the a dir'n, and skew(a)*skew(a)*skew(mmt) = -skew(mmt)*(a*a') if a'*mmt=0

            row = ptr_1 .+ (4:6)
            col = ptr_1 .+ (4:6)
            mtx[row, col] -= ff  ## Body1 motion

            row = ptr_2 .+ (4:6)
            col = ptr_2 .+ (4:6)
            mtx[row, col] += ff  ## Body2 motion

        elseif moments == 1  ## If CV joint
            ff = skew(mmt) / 2  ## Assume intermediate frame

            row = ptr_1 .+ (4:6)
            col = ptr_1 .+ (4:6)
            mtx[row, col] -= ff  ## Body1 motion
            col = ptr_2 .+ (4:6)
            mtx[row, col] += ff  ## Reference motion

            row = ptr_2 .+ (4:6)
            col = ptr_2 .+ (4:6)
            mtx[row, col] += ff  ## Body2 motion
            col = ptr_1 .+ (4:6)
            mtx[row, col] -= ff  ## Reference motion

        end
    end

    mtx[1:n, 1:n]

end  ## Leave
