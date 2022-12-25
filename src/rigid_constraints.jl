function rigid_constraints!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)

    # Form the constraint Jacobian - the form is dependant on the type of constraints
    # Build constraint matrix by setting deflections of rigid items to zero
    verb && println("Checking rigid items...")

    n = length(the_system.bodys)

    cnsrt_mtx = [
        point_line_jacobian(the_system.links, n)
        point_line_jacobian(the_system.rigid_points, n)
    ]
    q = size(cnsrt_mtx, 1)  ## q = the number of rows in the constraint matrix

    nhcnsrt_mtx = point_line_jacobian(the_system.nh_points, n)
    t = size(nhcnsrt_mtx, 1)  ## t = the number of rows in the nh-constraint matrix

    # still need to build v vector and check that it makes constraints happy
    # Build skew symmetric velocity matrix, and the centripetal and gyroscopic terms
    v_mtx, mv_mtx = centngyro(the_system.bodys)
    negjv_mtx = -cnsrt_mtx * v_mtx  ## Build transformation - constraint matrix

    # Check condition of constraint matrix
    verb && println("Checking constraint items...")
    d = 6 * (n - 1)
    if (q + t > 0) ## If the jacobian matrix has more than zero rows (i.e. there are rigid constraint items in the system)
        rkr = rank([cnsrt_mtx; nhcnsrt_mtx])  ## rk = the rank (the maximum number of linearly independent rows or columns) of the constraint matrix
        if rkr == (q + t)  ## If the rank = the number of rows, then there are no redundant constraints (the constraints are all linearly independent)
            verb && println("No redundant constraints in the system. Good.")
        else
            println("Warning: there are redundant constraints in the system!")
        end
        # Assemble the individual constraint matrices to system constraint matrix
        J_r = [cnsrt_mtx zeros(q, d); negjv_mtx cnsrt_mtx; zeros(t, d) nhcnsrt_mtx]
        J_l = [cnsrt_mtx zeros(q, d); zeros(q, d) cnsrt_mtx; zeros(t, d) nhcnsrt_mtx]
    else

        J_l = zeros(0, 2 * d)
        J_r = zeros(0, 2 * d)
    end

    data.constraint = cnsrt_mtx
    data.nh_constraint = nhcnsrt_mtx
    data.right_jacobian = J_r
    data.left_jacobian = J_l
    data.momentum = mv_mtx
    data.velocity = v_mtx

end