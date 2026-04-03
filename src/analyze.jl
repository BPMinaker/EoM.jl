function analyze(
    dss_eqns::dss_data,
    verb::Bool=false;
    freq::Tuple{Int64,Int64}=(0, 0),
    ss::Union{Symbol,Matrix,Vector}=:default,
    bode::Union{Symbol,Matrix,Vector}=:default,
    impulse::Union{Symbol,Matrix,Vector}=:default,
    t_zeros::Symbol=:default
)

    verb && println("Running linear analysis...")

    result = analysis(; sys_data=dss_eqns.sys_data)

    # get number of ins, outs
    nout, nin = size(dss_eqns.D)

    F = eigen(dss_eqns.A, dss_eqns.E) # find the eigen
    result.mode_vals = F.values[abs.(F.values).<1e9] # discard modes with Inf or Nan vals
    result.modes = dss_eqns.phys * F.vectors[:, abs.(F.values).<1e9] # convert vector to physical coordinates
    nb = div(size(result.modes, 1), 6)
    result.centre = zeros(size(result.modes))

    for j in axes(result.modes, 2) # for each mode
        if norm(result.modes[:, j]) > 0 # check for non-zero displacement modes
            k = argmax(abs.(result.modes[:, j])) # find max entry
            result.modes[:, j] /= (2 * result.modes[k, j]) # scale motions to unity by diving by max value, but not abs of max, as complex possible
        end

        for k in 1:nb # for each body
            mtn = result.modes[6*k.+(-5:0), j] # motion of body k
            l = argmax(abs.(mtn[4:6])) # find max angular coordinate
            phi = angle(mtn[l+3]) # find angle of that coordinate
            mtn *= exp(-phi * 1im) # rotate by negative of that angle to remove unnecessary imag parts
            result.centre[6*k.+(-5:0), j] = [-pinv(skew(mtn[4:6])) * mtn[1:3]; mtn[4:6] / (norm(mtn[4:6]) + eps(1.0))]
            # radius to the instantaneous center of rotation of the body (rad=omega\v)
        end
    end

    ss1 = dss(dss_eqns.A, dss_eqns.E, dss_eqns.B, dss_eqns.C, dss_eqns.D)
    ss2 = gminreal(ss1)

    if order(ss2) > 0
        result.ss_eqns, _, _, _ = dss2ss(ss2)
    else
        result.ss_eqns, _, _, _ = dss2ss(ss1)
    end

    result.e_val, _ = eigen(result.ss_eqns.A)

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

    if t_zeros !== :default && t_zeros !== :skip
        result.t_zero = gzero(result.ss_eqns)
        result.t_zero_f = abs.(result.t_zero) / 2π
    end

    #_, result.hsv = 
    #    display(ghanorm(result.ss_eqns))

    (; A, B, C, D) = result.ss_eqns

    compute = true
    if typeof(bode) == Symbol && bode != :default
        bode = zeros(nout, nin)
        compute = false
    end
    result.bode = bode

    if freq[1] == freq[2]
        t = unique(abs.(result.e_val)) / 2π
        t = t[t.>2e-5]
        low = Int(floor(log10(0.5 * minimum(t))))
        # lowest low eigenvalue, round number in Hz
        high = Int(ceil(log10(2.0 * maximum(t))))
        # highest high eigenvalue, round number in Hz
    else
        low = freq[1]
        high = freq[2]
    end
    if (high - low) < 1
        low = high - 1
    end
    result.w = 2π * 10.0 .^ (low:0.005:high)

    if compute
        # compute frequency response
        result.freq_resp = collect(eachslice(freqresp(result.ss_eqns, result.w); dims=3))

        mag(x::Matrix{Complex{Float64}}) = 20 * log10.(abs.(x)) .+ eps(1.0)
        result.mag = mag.(result.freq_resp)
        phs(x::Matrix{Complex{Float64}}) = 180 / π .* angle.(x)
        result.phase = phs.(result.freq_resp)

        small(x::Matrix{Float64}) = x .< -120
        set(x, idx) = (x[idx] .= 0)
        set.(result.phase, small.(result.mag))
    end

    compute = true
    if typeof(ss) == Symbol && ss != :default
        ss = zeros(nout, nin)
        compute = false
    end
    result.ss = ss

    if compute
        # compute steady state response
        if cond(A) < 1e6
            result.ss_resp = -C * (A \ B) + D
        else
            println("System matrix is near singular.  Substituting real part of low frequency response ($(my_round(10.0 ^ (low - 1))) Hz) for steady state...")
            result.ss_resp = real.( C * (( I * 1im * 2π * 10.0^(low - 1) - A ) \ B ) + D )
        end
    end

    compute = true
    if typeof(impulse) == Symbol && impulse != :default
        impulse = zeros(nout, nin)
        compute = false
    end
    result.impulse = impulse

    if compute
        # compute impulse response
        # at least one of the longest wavelengths
        tt = 2π / result.w[1]
        tt == Inf && (tt = 10)
        # try to get 10 steps in the shortest wavelength
        dt = 0.2π / result.w[end]
        steps = Int64(round(tt / dt)) + 1

        if steps > 25005
            # much too long, take 5000 steps of the longest possible step, shorten the time
            dt *= 5
            tt = 5000 * dt
            steps = 5001
        elseif steps > 5001 && steps <= 25005
            # still too long, take 5000 steps of a longer step, but make the time
            dt = tt / 5000
            steps = 5001
        end

        temp = fill(zeros(size(A)), steps)
        temp[1] += I
        impulse = fill(zeros(size(D)), steps)
        impulse[1] = C * B
        step_r = fill(zeros(size(D)), steps)
        step_r[1] = D

        ϕ = exp(A * dt)
        for i in 2:steps
            temp[i] = temp[i-1] * ϕ
            impulse[i] = C * temp[i] * B
            step_r[i] = step_r[i-1] + 0.5 * (impulse[i] + impulse[i-1]) * dt
        end

        # instead of a vector of matrices, we will have a matrix of vectors
        # each vector will contain the impulse response for each output-input pair
        temp_ii = [zeros(0) for _ in D]
        temp_iii = [zeros(0) for _ in D]
        for i in CartesianIndices(D)
            temp_ii[i] = [temp[i] for temp in impulse]
            temp_iii[i] = [temp[i] for temp in step_r]
        end

        result.impulse_resp = response_data(collect(range(0, tt; length=steps)), temp_ii)
        result.step_resp = response_data(collect(range(0, tt; length=steps)), temp_iii)
    end

    result
end




#= 
     ns = size(A, 1)

     result.t_zero = [zeros(0) for _ in 1:nout, _ in 1:nin]
     result.t_zero_f = [zeros(0) for _ in 1:nout, _ in 1:nin]

     for i in 1:nout
         for j in 1:nin
             temp = [A B[:, j:j]; C[i:i, :] D[i:i, j:j]]
             F = eigen(temp, [I zeros(ns, 1); zeros(1, ns) 0])
             result.t_zero[i, j] = F.values[abs.(F.values) .< 1e6]
             result.t_zero_f[i,j] = abs.(result.t_zero[i, j]) / 2π
         end
     end

 #    try
 #        WC = lyap(A, B * B')
 #        WO = lyap(I * A', C' * C)
 #        result.hsv = sqrt.(eigvals(WC * WO))
 #    catch
 #        result.hsv = zeros(size(A,1))
 #    end

 =#




#=
temp_ss = dss2ss(dss_eqns, verb) # reduce to standard form
min_ss =  minreal(temp_ss, verb)

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
=#

#=
G(x::Float64) = C * ((I * x * 1im - A) \ B) + D

if compute
    # compute evenly spaced range of frequncies in log space to consider
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
end
=#
