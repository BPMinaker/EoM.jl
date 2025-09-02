function mass(the_system::mbd_system, verb::Bool=false)
  
    verb && println("Building mass matrix...")

    cat(mass_mtx.(the_system.bodys[1:end-1])..., dims=(1,2))
end
