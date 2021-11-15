function summarize(
    system::mbd_system,
    results::EoM.analysis,
    verbose::Bool = false;
    plots = [],
    ss = 1:1:length(system.sensors)*length(system.actuators),
    bode = 1:1:length(system.sensors),
    vpt_name = ["u" "Speed" "m/s"],
)
    summarize([system], 0, results, verbose; plots, ss, bode, vpt_name)
end

function summarize(
    systems::Vector{mbd_system},
    vpts,
    results::EoM.analysis,
    verbose::Bool = false;
    plots = [],
    ss = 1:1:length(systems[1].sensors)*length(systems[1].actuators),
    bode = 1:1:length(systems[1].sensors),
    vpt_name = ["u" "Speed" "m/s"],
)

    ## Copyright (C) 2020, Bruce Minaker
    ## summary.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## summary.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    plotly()

    noeigs = false

    # get names of inputs and outputs
    input_names = getfield.(systems[1].actuators, :name)
    input_units = getfield.(systems[1].actuators, :units)
    output_names = getfield.(systems[1].sensors, :name)
    output_units = getfield.(systems[1].sensors, :units)

    # get number of ins, outs, and number of vpts (velocity points)
    nin = length(input_names)
    nout = length(output_names)

    nvpts = length(vpts)

    println("Results of the analysis of: $(systems[1].name)...")

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && nin * nout < 16 && length(ss) > 0
        labels = []
        gain = []
        # loop over outputs and inputs and vpts
        for i = 1:nout
            for j = 1:nin
                n = (i - 1) * nin + j
                if findnext(ss .== n, 1) !== nothing
                    x = zeros(nvpts)
                    for k = 1:nvpts
                        x[k] = my_round(results.ss_resp[k][i, j])
                    end
                    push!(gain, x[1])

                    if output_units[i] == input_units[j]
                        str_u = ""
                    elseif contains(output_units[i], input_units[j])
                        if contains(output_units[i], "/")
                            str_u = " [$(replace(output_units[i], input_units[j] => "1"))]"
                        else
                            str_u = " [$(replace(output_units[i], input_units[j] => ""))]"
                        end
                    else
                        str_u = " [$(output_units[i])/$(input_units[j])]"
                    end
                    lb = "$(output_names[i])/$(input_names[j])$str_u"
                    push!(labels, lb)
                    # if many vpts, make plot vs velocity
                    if nvpts > 1
                        p = plot(vpts, x, lw = 2, xlabel = vpt_name[2] * " [" * vpt_name[3] * "]", ylabel = lb, label = "", size = (600, 300))
                        display(p)
                    end
                end
            end
        end

        # if only one vpt, make table of the gains
        if nvpts == 1
            println("Steady state gains:")
            header = ["Output/Input", "Gain"]
            pretty_table([labels my_round.(gain)]; header)
        end
    end

    if !noeigs
        # get eigenvalues
        m = maximum(length.(results.e_val))
        s = zeros(m, nvpts) * 1im
        for i = 1:nvpts
            l = length(results.e_val[i])
            s[1:l, i] = results.e_val[i]
        end

        # for one velocity, chart of calcs from eigenvalues, otherwise plot eigenvalues
        if nvpts == 1
            omega = results.omega_n[1]
            zeta = results.zeta[1]
            tau = results.tau[1]
            lambda = results.lambda[1]

            println("Eigenvalues of minimal system:")
            header = ["No.", "σ±ωi [1/s]", "ω_n [Hz]", "ζ", "τ [s]", "λ [s]"]
            pretty_table([1:1:length(tau) my_round.([s omega zeta tau lambda])]; header)

        else
            # sort all zero roots to top
            #sort!(s, dims = 1, by = abs)

            # plot real and imaginary seperately
            sr = real.(s)
            si = imag.(s)

            # eliminate all zero rows
            tr = []
            for i = 1:size(sr, 1)
                if any(sr[i, :] .!= 0)
                    push!(tr, i)
                end
            end
            sr = sr[tr, :]
            tr = []
            for i = 1:size(si, 1)
                if any(si[i, :] .!= 0)
                    push!(tr, i)
                end
            end
            si = si[tr, :]

            # don't plot zeros - but can't have entire row of NaN
            sr[sr.==0] .= NaN
            si[si.==0] .= NaN

            seriestype = :scatter
            ms = 3
            p = plot(xlabel = vpt_name[2] * " [" * vpt_name[3] * "]", ylabel = "Eigenvalue [1/s]", size = (600, 300))

            rr = vec(sr')
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            label = "Real"
            u = size(sr, 1)
            vv = vcat(fill(vpts, u)...)
            plot!(p, vv, rr; seriestype, mc, ms, label)

            rr = vec(si')
            mc = RGB(227 / 255, 111 / 255, 71 / 255)
            label = "Imaginary"
            u = size(si, 1)
            vv = vcat(fill(vpts, u)...)
            plot!(p, vv, rr; seriestype, mc, ms, label)
            display(p)

            label = ""

            omega = unique.(results.omega_n)
            nf = maximum(unique(length.(omega)))

            for i = 1:length(omega)
                if length(omega[i]) < nf
                    append!(omega[i], zeros(nf - length(omega[i])) * NaN)
                end
            end
            omega = hcat(omega...)'
            omega[omega .== 0] .= NaN

            po = plot(xlabel = "", ylabel = "Natural frequency [Hz]", size = (600, 300))
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            if size(omega, 2) > 0
                plot!(po, vpts, omega; seriestype, mc, ms, label)
            end

            zeta = unique.(results.zeta)
            nf = maximum(unique(length.(zeta)))

            for i = 1:length(zeta)
                if length(zeta[i]) < nf
                    append!(zeta[i], zeros(nf - length(zeta[i])) * NaN)
                end
            end
            zeta = hcat(zeta...)'

            pz = plot(xlabel = vpt_name[2] * " [" * vpt_name[3] * "]", ylabel = "Damping ratio", size = (600, 300))
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            if size(zeta, 2) > 0
                plot!(pz, vpts, zeta; seriestype, mc, ms, label)
            end

            p = plot(po, pz, layout = grid(2, 1), size = (600, 400))
            display(p)

            tau = unique.(results.tau)
            nf = maximum(unique(length.(tau)))

            for i = 1:length(tau)
                if length(tau[i]) < nf
                    append!(tau[i], zeros(nf - length(tau[i])) * NaN)
                end
                tau[i][any.(abs.(tau[i]) .> 1e4)] .= 0
            end
            tau = hcat(tau...)'
            tau[tau.==0] .= NaN

            pt = plot(xlabel = "", ylabel = "Time constant [s]", size = (600, 300))
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            if size(tau, 2) > 0
                plot!(pt, vpts, tau; seriestype, mc, ms, label)
            end

            lambda = unique.(results.lambda)
            nf = maximum(unique(length.(lambda)))

            for i = 1:length(lambda)
                if length(lambda[i]) < nf
                    append!(lambda[i], zeros(nf - length(lambda[i])) * NaN)
                end
                lambda[i][any.(abs.(lambda[i]) .> 1e4)] .= 0
            end
            lambda = hcat(lambda...)'
            lambda[lambda.==0] .= NaN

            pl = plot(xlabel = vpt_name[2] * " [" * vpt_name[3] * "]", ylabel = "Wavelength [s]", size = (600, 300))
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            if size(lambda, 2) > 0
                plot!(pl, vpts, lambda; seriestype, mc, ms, label)
            end

            p = plot(pt, pl, layout = grid(2, 1), size = (600, 400))
            display(p)
        end

        # print instant centre of body 1
        if nvpts == 1
            println("Rotation centres of first body for all modes:")
            temp = my_round.([results.mode_vals[1] (results.centre[1][1:6, 1:end])'])
            header = ["No.", "Eigenvalue", "x", "y", "z", "u_x", "u_y", "u_z"]
            pretty_table([1:1:size(temp, 1) temp]; header)
        end
    end

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && length(bode) > 0 && nin * nout < 16
        # pick out up to four representative vpts from the list
        l = unique(Int.(round.((nvpts - 1) .* [1, 3, 5, 7] / 8 .+ 1)))
        if length(l) == 1
            for i = 1:nin
                # fill in for each selected vpt
                w = results.w[l[1]] / 2 / pi
                mag = cat(results.mag[l[1]]..., dims = 3)[bode, i, :]
                phs = cat(results.phase[l[1]]..., dims = 3)[bode, i, :]
                phs[phs.>0] .-= 360
                phs[findall(diff(phs, dims = 2) .> 300)] .= Inf
                phs[findall(diff(phs, dims = 2) .< -300)] .= Inf
                label = hcat(output_names[bode]...)
                label .*= "/" * input_names[i]
                xscale = :log10
                xticks = 10.0 .^ collect(Int(round(log10(w[1]))):1:Int(round(log10(w[end]))))
                p1 = plot(w, mag'; lw = 2, label, xlabel = "", ylabel = "Gain [dB]", xscale, xticks, ylims = (-60, Inf))
                p2 = plot(w, phs'; lw = 2, label = "", xlabel = "Frequency [Hz]", ylabel = "Phase [deg]", xscale, xticks, ylims = (-360, 0), yticks = -360:60:0)
                # merge two subplots
                p = plot(p1, p2, layout = grid(2, 1, heights = [0.66, 0.33]), size = (600, 450))
                display(p)
            end
        else
            # loop over outputs and inputs and selected vpts
            for i = 1:nout
                for j = 1:nin
                    n = (i - 1) * nin + j
                    if !(findnext(bode .== i, 1) === nothing)
                        # make empty plots of magnitude and phase
                        xscale = :log10
                        w = results.w[1] / 2 / pi
                        xticks = 10.0 .^ collect(Int(round(log10(w[1]))):1:Int(round(log10(w[end]))))
                        ylabel = "|$(output_names[i])|/|$(input_names[j])| [dB]"
                        p1 = plot(; xlabel = "", ylabel, xscale, xticks, legend = :top)
                        ylabel = "∠ $(output_names[i])/$(input_names[j]) [deg]"
                        p2 = plot(; xlabel = "Frequency [Hz]", ylabel, xscale, xticks, ylims = (-360, 0), yticks = -360:60:0)
                        # fill in for each selected vpt
                        for k in l
                            w = results.w[k] / 2 / pi
                            mag = cat(results.mag[k]..., dims = 3)[i, j, :]
                            phs = cat(results.phase[k]..., dims = 3)[i, j, :]
                            phs[phs.>0] .-= 360
                            # set wrap arounds in phase to Inf to avoid jumps in plot
                            phs[findall(abs.(diff(phs)) .> 180)] .= Inf
                            if length(l) == 1
                                lb = ""
                            else
                                lb = vpt_name[1] * "=$(my_round(vpts[k])) " * vpt_name[3]
                            end
                            p1 = plot!(p1, w, mag, lw = 2, label = lb)
                            p2 = plot!(p2, w, phs, lw = 2, label = "")
                            # merge two subplots
                            p = plot(p1, p2, layout = grid(2, 1, heights = [0.66, 0.33]), size = (600, 450))
                        end
                        display(p)
                    end
                end
            end
        end
    end

    n = length(plots)
    if n > 0
        println("Time history and other plots")
    end
    for i = 1:n
        display(plots[i])
    end

    # add the static preloads
    println("Preloads of first system:")
    header = ["Connector", "f_x", "f_y", "f_z", "m_x", "m_y", "m_z"]
    items = [
        systems[1].rigid_points
        systems[1].flex_points
        systems[1].springs
        systems[1].links
    ]
    temp = [getfield.(items, :name) my_round.(vcat(getfield.(items, :force)'...)) my_round.(vcat(getfield.(items,:moment)'...))]
    
    #=    for item in the_system.beams
           println(preload_f, "{$idx} {" * item.name * "} shear $(item.force[1][1]), $(item.force[1][2]), $(item.force[1][3]), $(norm(force[1]))")
           println(preload_f, "{} {} moment $(item.moment[1][1]), $(item.moment[1][2]), $(item.moment[1][3]), $(norm(item.moment[1]))")
           println(preload_f, "{} {} shear $(item.force[2][1]), $(item.force[2][2]), $(item.force[2][3]), $(norm(item.force[2]))")
           println(preload_f, "{} {} moment $(item.moment[2][1]), $(item.moment[2][2]), $(item.moment[2][3]), $(norm(item.moment[2]))")
           idx += 1
       end =#

    pretty_table(temp; header)
end
