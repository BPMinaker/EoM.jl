function mass(the_system::mbd_system, verb::Bool = false)
  
    verb && println("Building mass matrix...")

    temp = mass_mtx.(the_system.bodys[1:end-1])
    n = length(temp)
    mtx = zeros(6 * n, 6 * n)

    for i in eachindex(temp)
        mtx[6*i-5:6*i, 6*i-5:6*i] = temp[i]
    end

    mtx

end ## Leave
