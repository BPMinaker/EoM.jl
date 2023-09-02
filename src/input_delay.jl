function input_delay!(system::EoM.mbd_system, result::EoM.analysis, delay::Float64, inp::Vector{Int64})

    nin = size(result.freq_resp[1],2)

    n = length(result.w)
    T = zeros(nin, nin) * 1im + I
    c = deleteat!(collect(1:nin), inp[2])
    T = T[:, c]

    for i in 1:n
        T[inp[2], inp[1]] = exp(-result.w[i] * 1im * delay)
        result.freq_resp[i] *= T
    end

    T[inp[2], inp[1]] = 1.0
    result.ss_resp *= T

    mag(x) =  20 * log10.(abs.(x)) .+ eps(1.0)
    result.mag = mag.(result.freq_resp)
    phs(x) = 180 / π * angle.(x)
    result.phase = phs.(result.freq_resp)

    deleteat!(system.actuators, inp[2])

end