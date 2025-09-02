function const_frc_deal!(the_system::mbd_system, lambda::Vector{Float64}, verb::Bool = false)
    verb && println("Distributing constraint forces...")

    idx = 1

    for i in the_system.links
        i.preload = lambda[idx]
        i.force = i.b_mtx[1]' * [i.preload][1:i.forces]
        i.moment = i.b_mtx[2]' * [i.preload][i.forces+1:end]
        idx += 1
    end

    for i in the_system.rigid_points
        num = num_fm(i)
        i.preload = lambda[idx:idx+num-1]
        i.force = i.b_mtx[1]' * i.preload[1:i.forces]
        i.moment = i.b_mtx[2]' * i.preload[i.forces+1:end]
        idx += num
    end

    for i in the_system.springs
        i.preload = lambda[idx]
        i.force = i.b_mtx[1]' * [i.preload][1:i.forces]
        i.moment = i.b_mtx[2]' * [i.preload][i.forces+1:end]
        idx += 1
    end

    for i in the_system.flex_points
        num = num_fm(i)
        i.preload = lambda[idx:idx+num-1]
        i.force = i.b_mtx[1]' * i.preload[1:i.forces]
        i.moment = i.b_mtx[2]' * i.preload[i.forces+1:end]
        idx += num
    end

    for i in the_system.beams
        i.preload = lambda[idx:idx+7]
        i.force[1] = i.b_mtx[1]' * i.preload[1:2]
        i.moment[1] = i.b_mtx[2]' * i.preload[3:4]
        i.force[2] = i.b_mtx[1]' * i.preload[5:6]
        i.moment[2] = i.b_mtx[2]' * i.preload[7:8]
        idx += 8
    end

end ## Leave
