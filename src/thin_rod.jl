function thin_rod(name::String, ends::Array{Float64,2}, mass::Union{Float64, Int64})

    # Copyright (C) 2013, Bruce Minaker
    # thin_rod finds the mass matrix and mass centre of a thin rod, given end locations

    len_vec = diff(ends, dims = 2)
    i_mtx = -skew(len_vec)^2 * mass / 12

    item = body(name)
    item.mass = mass
    item.location = 0.5 * (ends[:, 1] + ends[:, 2])
    item.moments_of_inertia = diag(i_mtx)
    item.products_of_inertia = -[i_mtx[1, 2], i_mtx[2, 3], i_mtx[3, 1]]  # Change sign; using defn of Ixy as +ve integral

    item

end  ## Leave