function phi(the_system, verb)
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
    lines = [the_system.links;the_system.springs]
    points = [the_system.rigid_points;the_system.flex_points]

    function f_l!(f, x, i)

        # find the location of each end, from the starting location, plus the motion due to the body motion
        rs = i.location[1] + x[1:3] + cross(x[4:6], i.radius[1])
        re = i.location[2] + x[7:9] + cross(x[10:12], i.radius[2])

        # find the length
        r = re - rs
        l = norm(r)

        # find the tension force in the spring / link in global  coordinates
        if i isa link
            fg = i.preload / l .* r
        elseif i isa spring
            fg = (i.stiffness * (l - i.length) + i.preload) / l .* r
        else
            error("Not defined for this type.")
        end

        # transform to local coordinates
        f_1 =  fg - cross(x[4:6], fg)
        f_2 =  fg - cross(x[10:12], fg)

        # find the force and moment on each body
        f[1:3] -= f_1
        f[4:6] -= cross(i.radius[1], f_1)
        f[7:9] += f_2
        f[10:12] += cross(i.radius[2], f_2)

    end

    k_l = zeros(6 * num, 6 * num)
    input = zeros(12)
    output = zeros(12)
    for i in lines
        f!(f, x) = f_l!(f, x, i)
        k = ForwardDiff.jacobian(f!, output, input)
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)
        k_l[ptr_1 .+ (1:6), ptr_1 .+ (1:6)] += k[1:6,1:6]
        k_l[ptr_1 .+ (1:6), ptr_2 .+ (1:6)] += k[1:6,7:12]
        k_l[ptr_2 .+ (1:6), ptr_1 .+ (1:6)] += k[7:12,1:6]
        k_l[ptr_2 .+ (1:6), ptr_2 .+ (1:6)] += k[7:12,7:12]
    end

#    display(round.(k_l[1:48,1:48],digits=2))


    function f_p!(f, x, i)

        # find the location of each end, from the starting location, plus the motion due to the body motion
        rs = i.location + x[1:3] + cross(x[4:6], i.radius[1])
        re = i.location + x[7:9] + cross(x[10:12], i.radius[2])

        s_1 = i.b_mtx[1] * (re - rs)
        s_2 = i.b_mtx[2] * (x[10:12] - x[4:6])

        if i isa rigid_point
            fg = [i.b_mtx[1]' zeros(3, i.moments); zeros(3, i.forces) i.b_mtx[2]'] * i.preload
        elseif i isa flex_point
            fg = [i.b_mtx[1]' zeros(3, i.moments); zeros(3, i.forces) i.b_mtx[2]'] * (i.s_mtx * [s_1; s_2] + i.preload)
        else
            error("Not defined for this type.")
        end

        if i.moments < 2 && (i.forces == 1 || i.forces == 2)  ## If frames can misalign, and force has defined direction, align unit vector with body2
            R_12 = I - skew(x[4:6]-x[10:12])  ## neglect second order term in product
            f_2 = fg[1:3]
            m_2 = fg[4:6]
            f_1 = R_12 * f_2
            m_1 = R_12 * m_2
        else  ## Else, align with ground
            # build the rotation matrix, transpose, for each body coordinate system
            R_1t = I - skew(x[4:6])
            R_2t = I - skew(x[10:12])
            # transform to local coordinates, taking components as needed
            f_1 = R_1t * fg[1:3]
            m_1 = (i.b_mtx[2]' * i.b_mtx[2]) * R_1t * fg[4:6]
            f_2 = R_2t * fg[1:3]
            m_2 = (i.b_mtx[2]' * i.b_mtx[2]) * R_2t * fg[4:6]
        end

        f[1:3] -= f_1
        f[4:6] -= cross(i.radius[1], f_1) + m_1
        f[7:9] += f_2
        f[10:12] += cross(i.radius[2] + rs - re, f_2) + m_2
    end

    k_p = zeros(6 * num, 6 * num)
    for i in points 
        f!(f, x) = f_p!(f, x, i)
        k = ForwardDiff.jacobian(f!, output, input)
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)
        k_p[ptr_1 .+ (1:6), ptr_1 .+ (1:6)] += k[1:6,1:6]
        k_p[ptr_1 .+ (1:6), ptr_2 .+ (1:6)] += k[1:6,7:12]
        k_p[ptr_2 .+ (1:6), ptr_1 .+ (1:6)] += k[7:12,1:6]
        k_p[ptr_2 .+ (1:6), ptr_2 .+ (1:6)] += k[7:12,7:12]
    end

    k_l[1:6 * (num - 1), 1:6 * (num - 1)] + k_p[1:6 * (num - 1), 1:6 * (num - 1)]
end



    # function f_s!(f, x)

    #     for i in lines 
    #         # find the two bodies attached by the link, and where they appear in the state vector
    #         ptr_1, ptr_2 = ptr(i)

    #         # find the location of each end, from the starting location, plus the motion due to the body motion
    #         rs = i.location[1] + x[ptr_1 .+ (1:3)] + cross(x[ptr_1 .+ (4:6)], i.radius[1])
    #         re = i.location[2] + x[ptr_2 .+ (1:3)] + cross(x[ptr_2 .+ (4:6)], i.radius[2])

    #         # find the length
    #         r = re - rs
    #         l = norm(r)

    #         # find the tension force in the spring / link in global  coordinates
    #         if i isa link
    #             fg = i.preload / l .* r
    #         elseif i isa spring
    #             fg = (i.stiffness * (l - i.length) + i.preload) / l .* r
    #         else
    #             error("Not defined for this type.")
    #         end

    #         # transform to local coordinates
    #         f_1 =  fg - cross(x[ptr_1 .+ (4:6)], fg)
    #         f_2 =  fg - cross(x[ptr_2 .+ (4:6)], fg)

    #         # find the force and moment on each body
    #         f[ptr_1 .+ (1:6)] += [f_1; cross(i.radius[1], f_1)]
    #         f[ptr_2 .+ (1:6)] -= [f_2; cross(i.radius[2], f_2)]

    #     end
    # end

    # input = zeros(6 * num)
    # output = zeros(6 * num)
    # if nl > 0
    #     k_s = - ForwardDiff.jacobian(f_s!, output, input)[1:6 * (num - 1), 1:6 * (num - 1)]
    # else
    #     k_s = zeros(6 * (num -1), 6 * (num - 1))
    # end

    # display(round.(k_s[1:48,1:48],digits=2))

#    sparsity_pattern = jacobian_sparsity(f_s!, output, input)
#    jac = Float64.(sparse(sparsity_pattern))
#    colors = matrix_colors(jac)

    # jac=spzeros(6 * num, 6 * num)

    # for i in lines 
    #     ptr_1, ptr_2 = ptr(i)
    #     jac[ptr_1 .+ (1:6), ptr_1 .+ (1:6)] = ones(6,6)
    #     jac[ptr_1 .+ (1:6), ptr_2 .+ (1:6)] = ones(6,6)
    #     jac[ptr_2 .+ (1:6), ptr_1 .+ (1:6)] = ones(6,6)
    #     jac[ptr_2 .+ (1:6), ptr_2 .+ (1:6)] = ones(6,6)
    # end

    # colors = matrix_colors(jac)
    # input = zeros(6 * num)
    # forwarddiff_color_jacobian!(jac, f_s!, input, colorvec = colors)

    # k_ss = - jac[1:6 * (num - 1), 1:6 * (num - 1)]
    # display(round.(Matrix(k_ss[1:48,1:48]),digits=2))
    # display(round.(k_s[1:48,1:48]-k_ss[1:48,1:48],digits=2))



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


