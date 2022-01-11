function input_delay!(system::EoM.mbd_system, result::EoM.analysis, delay::Float64, inp::Vector{Int64})

    nin = size(result.freq_resp[1],2)

    n = length(result.w)
    for i in 1:n
        T = zeros(nin, 1) * 1im
        T[inp[1], 1] = 1.0
        T[inp[2], 1] = exp(-result.w[i] * 1im * delay)
        result.freq_resp[i] *= T
    end

    T = zeros(nin, 1)
    T[inp[1], 1] = 1.0
    T[inp[2], 1] = 1.0
    result.ss_resp *= T

    mag(x) =  20 * log10.(abs.(x)) .+ eps(1.0)
    result.mag = mag.(result.freq_resp)
    phs(x) = 180 / pi * angle.(x)
    result.phase = phs.(result.freq_resp)

    deleteat!(system.actuators, inp[2])

end

