function summarize_pluto(
    system::mbd_system,
    results::EoM.analysis;
    ss::Union{Symbol, Matrix, Vector} = :default,
    bode::Union{Symbol, Matrix, Vector} = :default,
    impulse::Union{Symbol, Matrix, Vector} = :default,
)
    summarize([system], 0, [results]; ss, bode, impulse)
end

    # Copyright (C) 2020, Bruce Minaker

function summarize_pluto(
    systems::Vector{mbd_system},
    vpts,
    results::Vector{EoM.analysis};
    ss::Union{Symbol, Matrix, Vector} = :default,
    bode::Union{Symbol, Matrix, Vector} = :default,
    impulse::Union{Symbol, Matrix, Vector} = :default,
    vpt_name = ["u" "Speed" "m/s"],
    )

    plots = []

    println("Printing summary of the analysis of: $(systems[1].name)...")
    noeigs = false

    title = "EoM " * Dates.format(now(), "yyyy-mm-dd")
    titlefontsize = 7
    titlelocation = :left

    # get names of inputs and outputs
    input_names = getfield.(systems[1].actuators, :name)
    input_units = uparse.(getfield.(systems[1].actuators, :units))
    output_names = getfield.(systems[1].sensors, :name)
    output_units = uparse.(getfield.(systems[1].sensors, :units))

    # get number of ins, outs, and number of vpts (velocity points)
    nin = length(input_names)
    nout = length(output_names)
    nvpts = length(vpts)

    if ss == :default
        ss = ones(nout, nin)
    elseif typeof(ss) == Symbol
        ss = zeros(nout, nin)
    end

    if size(ss, 1) != nout || size(ss, 2) != nin
        error("Steady state plot request dimensions are incompatible with system!")
    end

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && any(ss .== 1) && sum(ss .== 1) < 16
        labels = []
        gain = []
        # loop over outputs and inputs and vpts
        for i in 1:nout
            for j in 1:nin
                # n = (i - 1) * nin + j
                #if findnext(ss .== n, 1) !== nothing
                if ss[i, j] == 1
                    x = zeros(nvpts)
                    for k in 1:nvpts
                        x[k] = my_round(results[k].ss_resp[i, j])
                    end
                    push!(gain, x[1])
                    lb = "$(output_names[i])/$(input_names[j]) [$(output_units[i]/input_units[j])]"
                    push!(labels, lb)
                    # if many vpts, make plot vs velocity
                    if nvpts > 1
                        p = plot(
                            vpts,
                            x;
                            lw = 2,
                            xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                            ylabel = lb,
                            label = "",
                            size = (800, 400),
                            title,
                            titlefontsize,
                            titlelocation,
                            #extra_kwargs
                        )
                        push!(plots, p)
                    end
                end
            end
        end

        # if only one vpt, make table of the gains
        if nvpts == 1
            header = ["Output/Input", "Gain"]
            println("Steady state gains:")
            pretty_table([labels my_round.(gain)]; header, vlines = :none)
        end
    end

    if !noeigs
        # get eigenvalues
        l = length.(getfield.(results, :e_val))
        m = maximum(l)
        s = zeros(m, nvpts) * 1im
        for i in 1:nvpts
            s[1:l[i], i] = results[i].e_val
        end

        lz = length.(getfield.(results, :t_zero))
        mz = maximum(lz)
        sz = zeros(mz, nvpts) * 1im
        for i in 1:nvpts
            sz[1:lz[i], i] = results[i].t_zero
        end

        # for one velocity, chart of calcs from eigenvalues, otherwise plot eigenvalues
        if nvpts == 1
            omega = results[1].omega_n
            zeta = results[1].zeta
            tau = results[1].tau
            lambda = results[1].lambda
            header = ["No.", "σ±ωi [rad/s]", "ω_n [Hz]", "ζ", "τ [s]", "λ [s]"]
            println("Eigenvalues of minimal system:")
            pretty_table([1:1:l[1] my_round.([s omega zeta tau lambda])]; header, vlines = :none)

            t_zero = results[1].t_zero
            t_zero_f = results[1].t_zero_f

            header = ["No.", "σ±ωi [rad/s]", "ω [Hz]"]
            println("Zeros of minimal system:")
            pretty_table([1:1:lz[1] my_round.([t_zero t_zero_f])]; header, vlines = :none)
        else
            seriestype = :scatter
            label = ""
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            ms = 3

            sr = real.(s)
            si = imag.(s)
            vsr = vec(sr')
            vsi = vec(si')

            p = plot(vsr, vsi;
                seriestype,
                aspect_ratio = :equal,
                mc,
                ms,
                label,
                xlabel = "Real part [rad/s]",
                ylabel = "Imaginary part [rad/s]",
                size = (800, 400),
                title,
                titlefontsize,
                titlelocation,
                #extra_kwargs
            )
            push!(plots, p)

            # eliminate all zero rows
            tr = []
            for i in eachrow(sr)
                if any(i .!= 0)
                    push!(tr, i)
                end
            end
            sr = hcat(tr...)'
            tr = []
            for i in eachrow(si)
                if any(i .!= 0)
                    push!(tr, i)
                end
            end
            si = hcat(tr...)'

            # don't plot zeros - but can't have entire row of NaN
            sr[sr .== 0] .= NaN
            si[si .== 0] .= NaN

            p = plot(;
                xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                ylabel = "Eigenvalue [rad/s]",
                size = (800, 400),
                title,
                titlefontsize,
                titlelocation,
                #extra_kwargs
            )
            push!(plots, p)

            vsr = vec(sr')
            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            label = "Real"
            u = size(sr, 1)
            vv = vcat(fill(vpts, u)...)
            if length(vsr) > 0
                plot!(p, vv, vsr; seriestype, mc, ms, label)
            end
            vsi = vec(si')
            mc = RGB(227 / 255, 111 / 255, 71 / 255)
            label = "Imaginary"
            u = size(si, 1)
            vv = vcat(fill(vpts, u)...)
            if length(vsi) > 0
                plot!(p, vv, vsi; seriestype, mc, ms, label)
            end
            push!(plots, p)

            mc = RGB(0 / 255, 154 / 255, 250 / 255)
            label=""

            omega = treat(getfield.(results, :omega_n))
            if length(omega) > 0
                po = plot(
                    vpts,
                    omega;
                    seriestype,
                    mc,
                    ms,
                    label,
                    xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                    ylabel = "Natural frequency [Hz]",
                    ylims = (0, Inf),
                    size = (800, 400),
                    title,
                    titlefontsize,
                    titlelocation,
                    #extra_kwargs
                )
                push!(plots, po)
            end

            zeta = treat(getfield.(results, :zeta))
            if length(zeta) > 0
                pz = plot(
                    vpts,
                    zeta;
                    seriestype,
                    mc,
                    ms,
                    label,
                    xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                    ylabel = "Damping ratio",
                    size = (800, 400),
                    title,
                    titlefontsize,
                    titlelocation,
                    #extra_kwargs
                )
                push!(plots, pz)
            end

            tau = treat(getfield.(results, :tau))
            if length(tau) > 0
                pt = plot(
                    vpts,
                    tau;
                    seriestype,
                    mc,
                    ms,
                    label,
                    xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                    ylabel = "Time constant [s]",
                    size = (800, 400),
                    title,
                    titlefontsize,
                    titlelocation,
                    #extra_kwargs
                )
                push!(plots, pt)
            end

            lambda = treat(getfield.(results, :lambda))
            if length(lambda) > 0
                pl = plot(
                    vpts,
                    lambda;
                    seriestype,
                    mc,
                    ms,
                    label,
                    xlabel = vpt_name[2] * " [$(vpt_name[3])]",
                    ylabel = "Wavelength [s]",
                    ylims = (0, Inf),
                    size = (800, 400),
                    title,
                    titlefontsize,
                    titlelocation,
                    #extra_kwargs
                )
                push!(plots, pt)
            end
        end

        # print instant centre of body 1
        if nvpts == 1
            header = ["No.", "Eigenvalue", "x", "y", "z", "u_x", "u_y", "u_z"]
            temp = my_round.([results[1].mode_vals (results[1].centre[1:6, 1:end])'])
            println("Rotation centres of first body for all modes:")
            pretty_table([1:1:size(temp, 1) temp]; header, vlines = :none)
        end
    end

    if bode == :default
        isok(x) = (x == NoDims) 
        bode = isok.(dimension.(output_units * transpose(1 ./ input_units)))
    elseif typeof(bode) == Symbol
        bode = zeros(nout, nin)
    end

    if size(bode, 1) != nout || size(bode, 2) != nin
        error("Bode plot request dimensions are incompatible with system!")
    end

    if impulse == :default
        impulse = ones(nout, nin)
    elseif typeof(impulse) == Symbol
        impulse = zeros(nout, nin)
    end

    if size(impulse, 1) != nout || size(impulse, 2) != nin
        error("Impulse response plot request dimensions are incompatible with system!")
    end

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && any(bode .== 1) && sum(bode .== 1) < 32
        # pick out up to four representative vpts from the list
        l = unique(Int.(round.((nvpts - 1) .* [1, 3, 5, 7] / 8 .+ 1)))
        ll = length(l)

        if ll == 1
            for i in 1:nin
                # fill in for each selected vpt
                r = findall(bode[:, i] .== 1)
                if length(r) > 0
                    w = results[l[1]].w / 2π
                    mag = cat(results[l[1]].mag..., dims = 3)[r, i, :]
                    mag[findall(mag .> 100)] .= Inf
                    phs = cat(results[l[1]].phase..., dims = 3)[r, i, :]
                    phs[phs .> 0.1] .-= 360
                    phs[findall(abs.(diff(phs, dims = 2)) .> 250)] .= Inf
                    label = hcat(output_names[r]...)
                    label .*= "/" * input_names[i]
                    xscale = :log10
                    xticks = w[isinteger.(log10.(w))]
                    p1 = plot(
                        w,
                        mag';
                        lw = 2,
                        label,
                        xlabel = "",
                        ylabel = "Gain [dB]",
                        xscale,
                        xticks,
                        ylims = (-40, Inf),
                        title,
                        titlefontsize,
                        titlelocation,
                        bottom_margin = 5mm,
                        #extra_kwargs
                    )
                    p2 = plot(
                        w,
                        phs';
                        lw = 2,
                        label = "",
                        xlabel = "Frequency [Hz]",
                        ylabel = "Phase [°]",
                        xscale,
                        xticks,
                        ylims = (-365, 5),
                        yticks = -360:60:0,
                        #extra_kwargs
                    )
                    # merge two subplots
                    p = plot(
                        p1,
                        p2,
                        layout = grid(2, 1, heights = [0.67, 0.33]),
                        size = (800, 600)
                    )
                    push!(plots, p)
                end
            end
        else
            # loop over outputs and inputs and selected vpts
            for i in 1:nout
                for j in 1:nin
                    if bode[i,j] == 1
                        # make empty plots of magnitude and phase
                        xscale = :log10
                        w = results[l[1]].w / 2π
                        xticks = w[isinteger.(log10.(w))]
                        ylabel = "|$(output_names[i])|/|$(input_names[j])| [dB]"
                        p1 = plot(;
                            xlabel = "",
                            ylabel,
                            xscale,
                            xticks,
                            ylims = (-40, Inf),
                            bottom_margin = 5mm,
                            title,
                            titlefontsize,
                            titlelocation,
                            #extra_kwargs
                        )
                        ylabel = "∠ $(output_names[i])/$(input_names[j]) [°]"
                        p2 = plot(;
                            xlabel = "Frequency [Hz]",
                            ylabel,
                            xscale,
                            xticks,
                            ylims = (-365, 5),
                            yticks = -360:60:0,
                            #extra_kwargs
                        )
                        # fill in for each selected vpt
                        for k in l
                            w = results[k].w / 2π
                            mag = cat(results[k].mag..., dims = 3)[i, j, :]
                            mag[findall(mag .> 100)] .= Inf
                            phs = cat(results[k].phase..., dims = 3)[i, j, :]
                            phs[phs .> 0] .-= 360
                            # set wrap arounds in phase to Inf to avoid jumps in plot
                            phs[findall(abs.(diff(phs)) .> 180)] .= Inf
                            lb = vpt_name[1] * "=$(my_round(vpts[k]))  $(vpt_name[3])"
                            p1 = plot!(p1, w, mag; lw = 2, label = lb)
                            p2 = plot!(p2, w, phs; lw = 2, label = "")
                        end
                        # merge two subplots
                        p = plot(
                            p1,
                            p2,
                            layout = grid(2, 1, heights = [0.67, 0.33]),
                            size = (800, 600)
                        )
                        push!(plots, p)
                    end
                end
            end
        end

        if ll == 1
            for i in 1:nin
                # fill in for each selected vpt
                r = findall(impulse[:, i] .== 1)
                if length(r) > 0
                    t = results[l[1]].impulse_t
                    imp = cat(results[l[1]].impulse..., dims = 3)[r, i, :]
                    label = hcat(output_names[r]...)
                    label .*= "/" * input_names[i]
                    p = plot(
                        t,
                        imp';
                        lw = 2,
                        label,
                        xlabel = "Time [s]",
                        ylabel = "Output",
                        size = (800, 400),
                        title,
                        titlefontsize,
                        titlelocation,
                        #extra_kwargs
                    )
                    push!(plots, p)
                end
            end
        else
            # loop over outputs and inputs and selected vpts
            for i in 1:nout
                for j in 1:nin
                    if impulse[i,j] == 1
                        # make empty plot
                        ylabel = "|$(output_names[i])|/|$(input_names[j])| "
                        p = plot(;
                            xlabel = "Time [s]",
                            ylabel,
                            size = (800, 400),
                            title,
                            titlefontsize,
                            titlelocation,
                            #extra_kwargs
                        )
                        # fill in for each selected vpt
                        for k in l
                            t = results[k].impulse_t
                            imp = cat(results[k].impulse..., dims = 3)[i, j, :]
                            lb = vpt_name[1] * "=$(my_round(vpts[k]))  $(vpt_name[3])"
                            p = plot!(p, t, imp; lw = 2, label = lb)
                        end
                        push!(plots, p)
                    end
                end
            end
        end
    end

    # add the static preloads
    header = ["Connector", "X", "Y", "Z", "L", "M", "N"]
    items = [
        systems[1].rigid_points
        systems[1].flex_points
        systems[1].springs
        systems[1].links
    ]
    temp =
        [getfield.(items, :name) my_round.(vcat(getfield.(items, :force)'...); lim = 1e-4) my_round.(
            vcat(getfield.(items, :moment)'...);
            lim = 1e-4,
        )]

    #=    for item in the_system.beams
           println(preload_f, "{$idx} {" * item.name * "} shear $(item.force[1][1]), $(item.force[1][2]), $(item.force[1][3]), $(norm(force[1]))")
           println(preload_f, "{} {} moment $(item.moment[1][1]), $(item.moment[1][2]), $(item.moment[1][3]), $(norm(item.moment[1]))")
           println(preload_f, "{} {} shear $(item.force[2][1]), $(item.force[2][2]), $(item.force[2][3]), $(norm(item.force[2]))")
           println(preload_f, "{} {} moment $(item.moment[2][1]), $(item.moment[2][2]), $(item.moment[2][3]), $(norm(item.moment[2]))")
           idx += 1
       end =#
    println("Preloads of first system:")
    pretty_table(temp; header, vlines = :none)

#    return plots
       println("sdfsd")
end

            # for i in axes(si, 1)
            #     if any(si[i, :] .!= 0)
            #         push!(tr, i)
            #     end
            # end
            # si = si[tr, :]

#   xticks = 10.0 .^ collect(Int(round(log10(w[1]))):1:Int(round(log10(w[end]))))

#=                     if output_units[i] == input_units[j]
                        str_u = ""
                    elseif contains(output_units[i], input_units[j])
                        if contains(output_units[i], "/")
                            str_u = " [$(replace(output_units[i], input_units[j] => "1"))]"
                        else
                            str_u = " [$(replace(output_units[i], input_units[j] => ""))]"
                        end
                    else
                        str_u = " [$(output_units[i])/$(input_units[j])]"
                    end =#
