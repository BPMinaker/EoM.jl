function line_bend_jacobian(items::Vector{beam}, num::Int64)

    mtx = zeros(8 * length(items), 6 * num) # Initially define deflection matrix as zero matrix

    idx = 1
    for i in items
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)

        srs = skew(i.radius[1])  # Radius from body1 cg to point of action of directed item on body1; 's'=start
        sre = skew(i.radius[2])  # Radius from body2 cg to point of action of directed item on body2; 'e'=end

        B1 = [i.b_mtx[1] -i.b_mtx[1] * srs; zeros(i.moments, 3) i.b_mtx[2]] 
        B2 = [i.b_mtx[1] -i.b_mtx[1] * sre; zeros(i.moments, 3) i.b_mtx[2]] 

        B = zeros(8, 6 * num)
        B[1:4, ptr_1.+(1:6)] = B1
        B[5:8, ptr_2.+(1:6)] = B2

        mtx[8*idx.+(-7:0), :] = B
        idx += 1
    end

    n = 6 * (num - 1) # n = number of bodies -1 = number of bodies not including ground
    mtx[:, 1:n] # mtx = jacobian / deflection matrix

end ## Leave