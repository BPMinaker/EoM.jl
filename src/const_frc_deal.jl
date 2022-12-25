function const_frc_deal!(the_system::mbd_system, lambda::Vector{Float64}, verb::Bool = false)

    # Distribute preload solution results to individual items... order is important: rigids, then flex
    # Important because the contents of variable lambda are being shifted throughout the process
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
