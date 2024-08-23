function analyze(dss_eqns::EoM.dss_data, verb::Bool = false)

    verb && println("Running linear analysis...")

    plotlyjs()

    # if isdefined(Main, :VSCodeServer)
    #     plotly()
    # else
    #     unicodeplots()
    # end

    result = analysis()

    F = eigen(dss_eqns.A, dss_eqns.E) # find the eigen
    result.mode_vals = F.values[abs.(F.values) .< 1e9] # discard modes with Inf or Nan vals
    result.modes = dss_eqns.phys *  F.vectors[:, abs.(F.values) .< 1e9] # convert vector to physical coordinates
    nb = div(size(result.modes, 1), 6)
    result.centre = zeros(size(result.modes))

    for j in axes(result.modes, 2) # for each mode
        if norm(result.modes[:, j]) > 0 # check for non-zero displacement modes
            k = argmax(abs.(result.modes[:, j])) # find max entry
            result.modes[:, j] /= (2 * result.modes[k, j]) # scale motions to unity by diving by max value, but not abs of max, as complex possible
        end

        for k in 1:nb # for each body
            mtn = result.modes[6 * k .+ (-5:0), j] # motion of body k
            l = argmax(abs.(mtn[4:6])) # find max angular coordinate
            phi = angle(mtn[l+3]) # find angle of that coordinate
            mtn *= exp(-phi * 1im) # rotate by negative of that angle to remove unnecessary imag parts
            result.centre[6 * k .+ (-5:0), j] = [-pinv(skew(mtn[4:6])) * mtn[1:3]; mtn[4:6] / (norm(mtn[4:6]) + eps(1.0))]
            # radius to the instantaneous center of rotation of the body (rad=omega\v)
        end
    end

    temp_ss = dss2ss(dss_eqns::dss_data, verb) # reduce to standard form
    min_ss =  minreal(temp_ss::ss_data, verb)

    if size(min_ss.A, 1) < size(temp_ss.A,1)
        result.ss_eqns = min_ss
        F = eigen(result.ss_eqns.A)
        result.e_val = F.values
    else # if the minimal realization is no smaller, discard it
        result.ss_eqns = temp_ss 
        if size(temp_ss.A,1) < length(result.mode_vals)
            F = eigen(result.ss_eqns.A)
            result.e_val = F.values
        else
            result.e_val = result.mode_vals
        end
    end

    result.omega_n = abs.(result.e_val) / 2π
    result.zeta = -real.(result.e_val) ./ abs.(result.e_val)
    result.tau = -1.0 ./ real.(result.e_val)
    result.lambda = abs.(2π ./ imag.(result.e_val))

    idx = abs.(real.(result.e_val)) .< 1e-7
    result.tau[idx] .= Inf
    result.zeta[idx] .= 0

    idx = abs.(imag.(result.e_val)) .< 1e-7
    result.lambda[idx] .= Inf
    result.omega_n[idx] .= 0
    result.zeta[idx] .= NaN

    (; A, B, C, D) = result.ss_eqns

    temp = [A B; C D]
    if size(temp, 1) == size(temp, 2)
        F = eigen(temp, [I zeros(size(B)); zeros(size(C)) zeros(size(D))])
        result.t_zero = F.values[abs.(F.values) .< 1e9]
        result.t_zero_f = abs.(result.t_zero) / 2π
    end

    try
        WC = lyap(A, B * B')
        WO = lyap(I * A', C' * C)
        result.hsv = sqrt.(eigvals(WC * WO))
    catch
        result.hsv = zeros(size(A,1))
    end

    t = unique(abs.(result.e_val))
    t = t[t .> 4π / 10000]
    # t = t[t .< π * 1000]
    low = floor(log10(0.5 * minimum(t) / 2π))
    # lowest low eigenvalue, round number in Hz
    high = ceil(log10(2.0 * maximum(t) / 2π))
    # highest high eigenvalue, round number in Hz
    nw = Int(high - low)
    if nw < 1
        nw = 1
        low = high - 1  #high += 1
    end
    wpts = 200 * nw + 1
    # compute evenly spaced range of frequncies in log space to consider
    result.w = 2π * (10.0 .^ range(low, stop = high, length = wpts))

    # compute frequency response
    G(x::Float64) = C * ((I * x * 1im - A) \ B) + D
    try
        result.freq_resp = G.(result.w)
    catch
        result.freq_resp = Vector{Matrix{ComplexF64}}(undef,size(result.w))
        for i in 1:length(result.w)
            try
                result.freq_resp[i] = G(result.w[i])
            catch
                result.freq_resp[i] = ones(size(D)) * Inf
            end
        end
    end
    mag(x::Matrix{Complex{Float64}}) =  20 * log10.(abs.(x)) .+ eps(1.0)
    result.mag = mag.(result.freq_resp)
    phs(x::Matrix{Complex{Float64}}) = 180 / π .* angle.(x)
    result.phase = phs.(result.freq_resp)

    small(x::Matrix{Float64}) = x .< -120
    function set(x, idx)
        x[idx] .= 0
    end
    set.(result.phase, small.(result.mag))

    # compute steady state response
    if cond(A) < 1e6
        result.ss_resp = -C * (A \ B) + D
    else
        verb && println("System matrix is near singular.  Substituting real part of low frequency response ($(my_round(10.0 ^ (low - 1))) Hz) for steady state...")
        result.ss_resp = real.(G(2π * 10.0 ^ (low - 1)))
    end

    # compute impulse response
    # at least two of the longest wavelengths
    tt = 4π / result.w[1]
    tt == Inf && (tt = 10)
    # try to get 20 steps in the shortest wavelength
    dt = 0.1 * π / result.w[end]
    steps = Int64(round(tt/dt)) + 1
    # cap at 5000 steps, otherwise too much data
    steps = min(5001, steps)
    result.impulse_t = collect(range(0, tt; length = steps))
    dt = tt / (steps - 1)
    result.impulse = fill(zeros(size(C, 1), size(B, 2)), steps)
    temp = fill(zeros(size(A)), steps)
    temp[1] += I
    result.impulse[1] = C * B

    ϕ = exp(A * dt)
    for i in 2:steps
        temp[i] = temp[i-1] * ϕ
        result.impulse[i] = C * temp[i] * B
    end

    result
end
