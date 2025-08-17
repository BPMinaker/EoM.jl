function force!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)

    # function 'force' returns 'vec' (external loads), 'mtx' (stiffness matrix for angular motion resulting from applied forces) as a function of 'in' (the loads) and 'num' (the number of bodies)

    verb && println("Summing external forces...")

    num = length(the_system.bodys)
    vec = zeros(6 * num) ## Vec (force vector) is defined as zero vector
    mtx = zeros(6 * num, 6 * num) ## mtx (stiffness matrix) is defined as zero matrix

    for i in the_system.loads ## for each external loads

        ## Total moment = applied moment + (r cross f) <-using skew symmetric matrix
        ## Adds force vector to rows 1,2,3 (for mass 1) of column vector
        ## Adds moment vector to rows 4,5,6 (for mass 1) of column vector

        ptr_1 = 6 * (i.body_number - 1)  ## Row or column where this info is stored
        vec[ptr_1.+(1:6)] += [i.force; i.moment + skew(i.radius) * i.force]

        ptr_2 = 6 * (i.frame_number - 1)
        temp = [skew(i.force); skew(i.radius) * skew(i.force) + skew(i.moment)]
        mtx[ptr_1.+(1:6), ptr_1.+(4:6)] -= temp
        mtx[ptr_1.+(1:6), ptr_2.+(4:6)] += temp
    end

    n = 6 * (num - 1)
    data.force = vec[1:n]
    data.load_stiffness = mtx[1:n, 1:n]

end  ## Leave
