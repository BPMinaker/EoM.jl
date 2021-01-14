function phi(the_system, data, verb)
    ## Copyright (C) 2020 Bruce Minaker
    ## phi.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## phi.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verb && println("Automatic stiffness calc...")

    num = length(the_system.bodys)


    function f_s(x)
        # make an empty vector
        f = Any[zeros(6 * num)...]

        for i in [the_system.links;the_system.springs]
            # find the two bodies attached by the link, and where they appear in the state vector
            ptr_1, ptr_2 = ptr(i)

            # find the term to compute the moments (r x f)
            srs = skew(i.radius[1])
            sre = skew(i.radius[2])

            # find the location of each end, from the starting location, plus the motion due to the body motion
            rs = i.location[1] + x[ptr_1 .+ (1:3)] - srs * x[ptr_1 .+ (4:6)]
            re = i.location[2] + x[ptr_2 .+ (1:3)] - sre * x[ptr_2 .+ (4:6)]

            # find the stretch / violation
            l = norm(rs - re)
            s = l - i.length

            # set the stiffness to zero for constraint
            if i isa link
                k = 0
            elseif i isa spring
                k = i.stiffness
            else
                error("Not defined for this type.")
            end

            # find the tension force in the spring / link in global  coordinates
            fg = (k * s + i.preload) / l .* (re - rs)

            # build the rotation matrix, transpose, for each body coordinate system
            R_1t = I - skew(x[ptr_1 .+ (4:6)])
            R_2t = I - skew(x[ptr_2 .+ (4:6)])

            # transform to local coordinates
            f_1 = R_1t * fg
            f_2 = R_2t * fg

            # find the force and moment on each body
            f[ptr_1 .+ (1:6)] += [f_1; srs * f_1]
            f[ptr_2 .+ (1:6)] -= [f_2; sre * f_2]

        end
        f
    end

    f_s_x(x) = ForwardDiff.jacobian(f_s, x)

    # evaluate and print to check
    k_4 = -f_s_x(zeros(6 * num))[1:6*(num-1), 1:6*(num-1)]
#    println("k_4")
#    display(round.(k_4.+eps(1e-6), digits = 3))

    function f_fp(x)
        # make an empty vector
        f = vcat([], zeros(6 * num))
        for i in [the_system.rigid_points;the_system.flex_points] 
            # find the two bodies attached by the link, and where they appear in the state vector
            ptr_1, ptr_2 = ptr(i)

            # find the term to compute the moments (r x f)
            srs = skew(i.radius[1])
            sre = skew(i.radius[2])

            # find the location of each end, from the starting location, plus the motion due to the body motion
            rs = x[ptr_1.+(1:3)] - srs * x[ptr_1.+(4:6)]
            re = x[ptr_2.+(1:3)] - sre * x[ptr_2.+(4:6)]

            s_1 = i.b_mtx[1] * (re - rs)
            s_2 = i.b_mtx[2] * (x[ptr_2.+(4:6)] - x[ptr_1.+(4:6)])

            if i isa rigid_point
                k = 0
            elseif i isa flex_point
                k = i.s_mtx
            else
                error("Not defined for this type.")
            end

            # convert the lagrange multipliers to forces and moments in global coordinates
            fg =
                [i.b_mtx[1]' zeros(3, i.moments); zeros(3, i.forces) i.b_mtx[2]'] *
                (k * [s_1; s_2] + i.preload)

            # build the rotation matrix, transpose, for each body coordinate system
            R_1t = I - skew(x[ptr_1.+(4:6)])
            R_2t = I - skew(x[ptr_2.+(4:6)])

            # transform to local coordinates, taking components as needed
            f[ptr_1.+(1:6)] +=
                [
                    R_1t*R_2t'*i.b_mtx[1]'*i.b_mtx[1]*R_2t zeros(3, 3)
                    srs*R_1t*R_2t'*i.b_mtx[1]'*i.b_mtx[1]*R_2t i.b_mtx[2]'*i.b_mtx[2]*R_1t
                ] * fg

            f[ptr_2.+(1:6)] -=
                [
                    i.b_mtx[1]'*i.b_mtx[1]*R_2t zeros(3, 3)
                    (sre+skew(rs-re))*i.b_mtx[1]'*i.b_mtx[1]*R_2t i.b_mtx[2]'*i.b_mtx[2]*R_2t
                ] * fg

        end
        f
    end


    # for i in the_system.rigid_points
    #     println("preload")
    #     display(i.preload)
    #     println("b_1")
    #     display(i.b_mtx[1])
    #     println("b_2")
    #     display(i.b_mtx[2])
    #     display(-i.b_mtx[2]' * i.b_mtx[2])

    # end

    # println("f_p")
    # temp = zeros(6 * num)
    # temp[4] = 0.01
    # display(f_fp(temp))


    f_fp_x(x) = ForwardDiff.jacobian(f_fp, x)

    # evaluate and print to check
    k_5 = -f_fp_x(zeros(6 * num))[1:6*(num-1), 1:6*(num-1)]
#    println("k_5")
#    display(round.(k_5.+eps(1e-6), digits = 3))


    k_4,k_5
end




    # # form the constraint equation for each link from the state vector
    # function line_phi(x)
    #     # make an empty vector
    #     phi = []
    #     for i in the_system.links
    #         # find the two bodies attached by the link, and where they appear in the state vector
    #         ptr_1, ptr_2 = ptr(i)

    #         # find the term to compute the moments (r x f)
    #         srs = skew(i.radius[1])
    #         sre = skew(i.radius[2])

    #         # find the location of each end, from the starting location, plus the motion due to the body motion
    #         rs = i.location[1] + x[ptr_1.+(1:3)] - srs * x[ptr_1.+(4:6)]
    #         re = i.location[2] + x[ptr_2.+(1:3)] - sre * x[ptr_2.+(4:6)]

    #         # find the distance between the ends minus the length
    #         # add  to the end of the vector
    #         push!(phi, norm(rs - re) - i.length)
    #     end
    #     # the constraint vector is the return argument
    #     phi
    # end


    # # check the result, should be zero
    # phi_0 = line_phi(zeros(6 * num))
    # println("phi_0")
    # display(phi_0)

    # # differentiate to find the jacobian
    # line_phi_x(x) = ForwardDiff.jacobian(line_phi, x)

    # # find the jacobian, print to check
    # J_0 = line_phi_x(zeros(6 * num))[:, 1:6*(num-1)]
    # println("J_0")
    # display(J_0)


    # function point_phi(x)
    #     # make an empty vector
    #     phi = []
    #     for i in the_system.rigid_points
    #         # find the two bodies attached by the link, and where they appear in the state vector
    #         ptr_1, ptr_2 = ptr(i)

    #         # find the location of each end, from the starting location, plus the motion due to the body motion
    #         rs = x[ptr_1.+(1:3)] - skew(i.radius[1]) * x[ptr_1.+(4:6)]
    #         re = x[ptr_2.+(1:3)] - skew(i.radius[2]) * x[ptr_2.+(4:6)]

    #         # find the difference in angular motion
    #         d = x[ptr_1.+(4:6)] - x[ptr_2.+(4:6)]

    #         # build the rotation matrix, transpose, for each body coordinate system
    #         R_1 = I + skew(x[ptr_1.+(4:6)])
    #         R_2 = I + skew(x[ptr_2.+(4:6)])

    #         phi = vcat(phi, [i.b_mtx[1] * R_2' * (rs - re); i.b_mtx[2] * R_2' * d])

    #     end
    #     phi

    # end

    # phi_0 = point_phi(zeros(6 * num))
    # println("ϕ_0")
    # display(phi_0)

    # point_phi_x(x) = ForwardDiff.jacobian(point_phi, x)
    # J_0 = point_phi_x(zeros(6 * num))[:, 1:6*(num-1)]
    # display(J_0)


