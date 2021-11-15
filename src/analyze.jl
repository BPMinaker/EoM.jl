
function analyze(dss_eqns::EoM.dss_data, verbose::Bool = false)
    analyze([dss_eqns], verbose)
end

function analyze(dss_eqns::Vector{EoM.dss_data}, verbose::Bool = false)
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

    verbose && println("Running linear analysis...")

    nvpts = length(dss_eqns) # number of vpoints (speeds)
    lower = zeros(nvpts)
    upper = zeros(nvpts)

    result = analysis(nvpts)

    temp_ss = Vector{ss_data}(undef, nvpts)
    for i in 1:nvpts

        F = eigen(dss_eqns[i].A, dss_eqns[i].E) # find the eigen
        tmp_vect = F.vectors[:, abs.(F.values) .< 1e9]
        tmp_vals = F.values[abs.(F.values) .< 1e9] # discard modes with Inf or Nan vals

        p = sortperm(round.(tmp_vals, digits = 5), by = x -> (isreal(x), real(x) > 0, abs(x), real(x), abs(imag(x)), -imag(x)))
        result.mode_vals[i] = tmp_vals[p]
        tmp_vect = tmp_vect[:, p]

        result.modes[i] = dss_eqns[i].phys * tmp_vect # convert vector to physical coordinates
        nb = div(size(result.modes[i], 1), 6)
        nm = size(result.modes[i], 2)

        result.centre[i] = zeros(size(result.modes[i]))

        for j in 1:nm # for each mode
            if norm(result.modes[i][:, j]) > 0 # check for non-zero displacement modes
                k = argmax(abs.(result.modes[i][:, j])) # find max entry
                result.modes[i][:, j] /= (2 * result.modes[i][k, j]) # scale motions to unity by diving by max value, but not abs of max, as complex possible
            end

            for k in 1:nb # for each body
                mtn = result.modes[i][6 * k .+ (-5:0), j] # motion of body k
                l = argmax(abs.(mtn)) # find max coordinate
                phi = angle(mtn[l]) # find angle of that coordinate
                mtn *= exp(-phi * 1im) # rotate by negative of that angle to remove unnecessary imag parts

                result.centre[i][6 * k .+ (-5:0), j] = [-pinv(skew(mtn[4:6])) * mtn[1:3]; mtn[4:6] / (norm(mtn[4:6]) + eps(1.0))]
                # radius to the instantaneous center of rotation of the body (rad=omega\v)
            end
        end

        temp_ss[i] = dss2ss(dss_eqns[i], verbose && i < 2 && :verbose) # reduce to standard form
        result.ss_eqns[i] = minreal(temp_ss[i], verbose && i < 2 && :verbose)
        F = eigen(result.ss_eqns[i].A)
        result.e_val[i] = F.values

        # if decomp
        #     temp_1, temp_2 = decompose(temp, verbose && i < 2 && :verbose)
        #     result.ss_eqns[i] = temp_1
        #     result.e_val[i] = temp_2
        # else
        #     result.ss_eqns[i] = temp
        #     result.e_val[i] = result.mode_vals[i]
        # end

        result.omega_n[i] = abs.(result.e_val[i]) / 2 / pi
        result.zeta[i] = -real.(result.e_val[i]) ./ abs.(result.e_val[i])
        result.tau[i] = -1.0 ./ real.(result.e_val[i])
        result.lambda[i] = abs.(2 * pi ./ imag.(result.e_val[i]))

        idx = abs.(real.(result.e_val[i])) .< 1e-10
        result.tau[i][idx] .= Inf
        result.zeta[i][idx] .= 0

        idx = abs.(imag.(result.e_val[i])) .< 1e-10
        result.lambda[i][idx] .= Inf
        result.omega_n[i][idx] .= 0
        result.zeta[i][idx] .= NaN

        t = abs.(result.e_val[i])
        temp = t[(t .> 1e-6) .& (t .< 1e6)]
        if length(temp) == 0
            lower[i] = 1e-6
            upper[i] = 1e6
        else
            lower[i] = minimum(temp)
            upper[i] = maximum(temp)
        end

        A = result.ss_eqns[i].A
        B = result.ss_eqns[i].B
        C = result.ss_eqns[i].C
        try
            WC = lyap(A, B * B')
            WO = lyap(I * A', C' * C)
            result.hsv[i] = sqrt.(eigvals(WC * WO))
        catch
            result.hsv[i] = zeros(size(A,1))
        end
    end

    wpts = 401 # number of frequencies
    low = floor(log10(0.5 * minimum(lower) / 2 / pi))
    # lowest low eigenvalue, round number in Hz
    low < -2 && (low = -2) # limit the min 0.01 Hz
    high = ceil(log10(2.0 * maximum(upper) / 2 / pi))
    # highest high eigenvalue, round number in Hz
    nw = Int(high - low)
    if nw == 2 || nw == 4
        wpts = 401
    elseif nw == 3 || nw == 6
        wpts = 601
    else
        wpts = 501
    end
    w = 2 * pi * (10.0 .^ range(low, stop = high, length = wpts))
    # compute evenly spaced range of frequncies in log space to consider

    for i in 1:nvpts
        result.w[i] = w
        nin = size(result.ss_eqns[i].B, 2)
        nout = size(result.ss_eqns[i].C, 1)

        A = result.ss_eqns[i].A
        B = result.ss_eqns[i].B
        C = result.ss_eqns[i].C
        D = result.ss_eqns[i].D

        result.ss_resp[i] = zeros(nout, nin)

        # compute frequency response
        G(x) = C * ((I * x * 1im - A) \ B) + D
        result.freq_resp[i] = G.(w)
        mag(x) =  20 * log10.(abs.(x)) .+ eps(1.0)
        result.mag[i] = mag.(result.freq_resp[i])
        phs(x) = 180 / pi * angle.(x)
        result.phase[i] = phs.(result.freq_resp[i])

        # compute steady state response
        try
            result.ss_resp[i] = -C * (A \ B) + D
        catch
            verbose && i < 2 && println("No system inverse exists, trying individual input-output pairs...")

            result.ss_resp[i] = zeros(nout, nin)
            for m in 1:nin
                for n in 1:nout
                    try
                        temp_mn = ss_data(temp_ss[i].A, temp_ss[i].B[:, m:m], temp_ss[i].C[n:n, :], temp_ss[i].D[n:n, m:m]) # eliminate all the other inputs and outputs
                        ss_eqns = minreal(temp_mn, verbose && i < 2 && :verbose)
                        result.ss_resp[i][n, m] = -(ss_eqns.C * (ss_eqns.A \ ss_eqns.B))[1, 1] + ss_eqns.D[1, 1] # note only one input and one output here
                    catch
                        result.ss_resp[i][n, m] = Inf
                        verbose && i < 2 && println("No steady state exists for at least one input-output pair.")
                    end
                end
            end
        end

    end
    result
end
