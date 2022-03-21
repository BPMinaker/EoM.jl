function analyze(dss_eqns::EoM.dss_data, verb::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## analyze.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## analyze.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verb && println("Running linear analysis...")

    result = analysis()

    F = eigen(dss_eqns.A, dss_eqns.E) # find the eigen
    result.mode_vals= F.values[abs.(F.values) .< 1e9] # discard modes with Inf or Nan vals
    result.modes = dss_eqns.phys *  F.vectors[:, abs.(F.values) .< 1e9] # convert vector to physical coordinates
    nb = div(size(result.modes, 1), 6)
    nm = size(result.modes, 2)

    result.centre = zeros(size(result.modes))

    for j in 1:nm # for each mode
        if norm(result.modes[:, j]) > 0 # check for non-zero displacement modes
            k = argmax(abs.(result.modes[:, j])) # find max entry
            result.modes[:, j] /= (2 * result.modes[k, j]) # scale motions to unity by diving by max value, but not abs of max, as complex possible
        end

        for k in 1:nb # for each body
            mtn = result.modes[6 * k .+ (-5:0), j] # motion of body k
            l = argmax(abs.(mtn)) # find max coordinate
            phi = angle(mtn[l]) # find angle of that coordinate
            mtn *= exp(-phi * 1im) # rotate by negative of that angle to remove unnecessary imag parts
            result.centre[6 * k .+ (-5:0), j] = [-pinv(skew(mtn[4:6])) * mtn[1:3]; mtn[4:6] / (norm(mtn[4:6]) + eps(1.0))]
            # radius to the instantaneous center of rotation of the body (rad=omega\v)
        end
    end

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

    result.omega_n = abs.(result.e_val) / 2 / pi
    result.zeta = -real.(result.e_val) ./ abs.(result.e_val)
    result.tau = -1.0 ./ real.(result.e_val)
    result.lambda = abs.(2 * pi ./ imag.(result.e_val))

    idx = abs.(real.(result.e_val)) .< 1e-10
    result.tau[idx] .= Inf
    result.zeta[idx] .= 0

    idx = abs.(imag.(result.e_val)) .< 1e-10
    result.lambda[idx] .= Inf
    result.omega_n[idx] .= 0
    result.zeta[idx] .= NaN

    A = result.ss_eqns.A
    B = result.ss_eqns.B
    C = result.ss_eqns.C
    D = result.ss_eqns.D

    try
        WC = lyap(A, B * B')
        WO = lyap(I * A', C' * C)
        result.hsv = sqrt.(eigvals(WC * WO))
    catch
        result.hsv = zeros(size(A,1))
    end

    nin = size(result.ss_eqns.B, 2)
    nout = size(result.ss_eqns.C, 1)
    result.ss_resp = zeros(nout, nin)
    # compute steady state response
    try
        result.ss_resp = -C * (A \ B) + D
    catch
        verb && println("No system inverse exists, trying individual input-output pairs...")

        result.ss_resp = zeros(nout, nin)
        for m in 1:nin
            for n in 1:nout
                try
                    temp_mn = ss_data(temp_ss.A, temp_ss.B[:, m:m], temp_ss.C[n:n, :], temp_ss.D[n:n, m:m]) # eliminate all the other inputs and outputs
                    ss_eqns = minreal(temp_mn, verb)
                    result.ss_resp[n, m] = -(ss_eqns.C * (ss_eqns.A \ ss_eqns.B))[1, 1] + ss_eqns.D[1, 1] # note only one input and one output here
                catch
                    result.ss_resp[n, m] = Inf
                    verb && println("No steady state exists for at least one input-output pair.")
                end
            end
        end
    end

    t = unique(abs.(result.e_val))
    t = t[t .> 0.0628]
    low = floor(log10(0.5 * minimum(t) / 2 / pi))
    low > -1 && (low = -1)
    # lowest low eigenvalue, round number in Hz
    high = ceil(log10(2.0 * maximum(t) / 2 / pi))
    # highest high eigenvalue, round number in Hz
    nw = Int(high - low)
    if nw == 0
        nw = 1
        high += 1
    end
    wpts = 200 * nw + 1
    # compute evenly spaced range of frequncies in log space to consider
    result.w = 2 * pi * (10.0 .^ range(low, stop = high, length = wpts))

    # compute frequency response
    G(x) = C * ((I * x * 1im - A) \ B) + D
    result.freq_resp = G.(result.w)
    mag(x) =  20 * log10.(abs.(x)) .+ eps(1.0)
    result.mag = mag.(result.freq_resp)
    phs(x) = 180 / pi * angle.(x)
    result.phase = phs.(result.freq_resp)

    result
end

#p = sortperm(round.(tmp_vals, digits = 5), by = x -> (isreal(x), real(x) > 0, abs(x), real(x), abs(imag(x)), -imag(x)


