function defln_deal!(the_system::mbd_system, static::Vector{Float64}, verb::Bool = false)
    verb && println("Distributing deflections...")

    idx = 1
    for i in the_system.bodys[1:end-1]
        i.deflection = static[idx.+(0:2)]
        i.angular_deflection = static[idx.+(3:5)]
        idx += 6
    end
end
