function assemble_eom!(data::eom_data, verb::Bool = false)
 
    verb && println("Building equations of motion...")

    mass_mtx = data.mass + data.inertia
    stiff_mtx = data.stiffness + data.tangent_stiffness + data.load_stiffness  ## Sum total system stiffness
    damp_mtx = data.damping + data.momentum
    #symmetric_stiffness=issymmetric(stiff_mtx,1.e-3);  ## Check symmetry of stiffness matrix, if 'stiff_mtx' is symmetric to the tolerance 1.e-3, return the dimension, otherwise return zero

    dim = size(data.constraint, 2)
    nin = size(data.input, 2)
    nout = size(data.output, 1)

    data.M = [
        I zeros(dim, dim + nin)
        zeros(dim, dim) mass_mtx -data.input_rate
        zeros(nin, 2 * dim + nin)
    ]

    data.KC = [
        data.velocity -I zeros(dim, nin)
        stiff_mtx damp_mtx -data.input
        zeros(nin, 2 * dim) I
    ]

    s = size(data.right_jacobian, 1)  ## Compute size of J matrices

    if (s > 0)
        r_orth = nullspace([data.right_jacobian zeros(s, nin)])
        l_orth = nullspace([data.left_jacobian zeros(s, nin)])
    else
        r_orth = diagm(0 => ones(2 * dim + nin))
        l_orth = r_orth
    end

    ## Pre and post multiply by orthogonal complements, and then cast in standard form
    E = l_orth' * data.M * r_orth
    A = -l_orth' * data.KC * r_orth
    B = l_orth' * [zeros(2 * dim, nin); I]
    C = zeros(nout, 2 * dim + nin)

    for i in 1:nout
        if data.column[i] == 1 ## p
            mask = [I zeros(dim, dim + nin)]

        elseif data.column[i] == 2  ## w
            mask = [zeros(dim, dim) I zeros(dim, nin)]

        elseif data.column[i] == 3  ## p dot
            mask = -data.KC[1:dim, :]

        elseif data.column[i] == 4  ## w dot
            mask = -pinv(data.M[dim+1:2*dim, dim+1:2*dim]) * data.KC[dim+1:2*dim, :]

        elseif data.column[i] == 5 ## p dot dot
            mask =
                [data.velocity^2 -data.velocity zeros(dim, nin)] -
                pinv(data.M[dim+1:2*dim, dim+1:2*dim]) * data.KC[dim+1:2*dim, :]
        else
            error("Matrix size error")
        end

        C[i, :] = data.output[i:i, :] * mask  ## Note notation here, [i:i,:] = row, [i,:] = row'
    end

    C *= r_orth
    D = data.feedthrough  ## Add the user defined feed forward
    phys = r_orth[1:dim, :]
    verb && println("Okay, built equations of motion.")

    dss_data(A, B, C, D, E, phys)

end  ## Leave
