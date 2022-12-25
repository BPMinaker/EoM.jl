function centngyro(items::Vector{body})
  
    n = length(items) - 1 ## Length of in is the number of bodies
    v_mtx = zeros(6 * n, 6 * n)  ## Set up initial empty matrix
    mv_mtx = zeros(6 * n, 6 * n)

    idx = 1
    for i in items[1:end-1]
        h = inertia_mtx(i) * i.angular_velocity
        if norm(cross(i.angular_velocity, h)) > 1e-6
            error("Body $(i.name) is not rotating about axis of symmetry.")
        end

        mv_mtx[6*idx.+(-2:0), 6*idx.+(-2:0)] = -skew(h)
        mv_mtx[6*idx.+(-5:-3), 6*idx.+(-2:0)] = -skew(i.velocity * i.mass)
        v_mtx[6*idx.+(-5:-3), 6*idx.+(-2:0)] = skew(i.velocity)
        idx += 1
    end

    v_mtx, mv_mtx

end  ## Leave
