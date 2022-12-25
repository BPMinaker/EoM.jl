function defln_deal!(the_system::mbd_system, static::Vector{Float64}, verb::Bool = false)

    verb && println("Distributing deflections...")

    for i in the_system.bodys[1:end-1]
        i.deflection = static[1:3]
        i.angular_deflection = static[4:6]
        static = circshift(static, -6)
    end

end ## Leave
