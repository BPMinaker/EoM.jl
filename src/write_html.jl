using Plots

function write_html(
    systems::Vector{mbd_system},
    results::Vector{EoM.analysis},
    args...;
    plots = [],
    folder = "output",
    filename = systems[1].name,
    ss = 1:1:length(systems[1].sensors)*length(systems[1].actuators),
    bode = 1:1:length(systems[1].sensors),
    vpt_name = ["u" "Speed" "m/s"]
)

    ## Copyright (C) 2020, Bruce Minaker
    ## write_html.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## write_html.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    plotly()

    verbose = any(args .== :verbose)
    verbose && println("Writing output...")
#    plots = args[findall(isa.(args, Plots.Plot{Plots.PlotlyBackend}))]

    # set up the paths
    dirs = setup(folder = folder, data = systems[1].name)
    dir_date = dirs[1]
    dir_time = dirs[2]
    dir_data = joinpath(dir_date, dir_time)

    # default html start and end text
    str_open = "<!doctype html>
    <html lang=\"en\" >
    <head>
        <title>EoM Analysis results</title>
        <meta charset=\"utf-8\">
        <meta name=\"description\" content=\"EoM Analysis result\">
        <meta name=\"author\" content=\"automatically generated by EoM\">
        <style>
        table {
        border-collapse: collapse;
        }
        td, th {
        border: 1px solid #dddddd;
        text-align: center;
        padding: 8px;
        }
        tr:nth-child(even) {
        background-color: #dddddd;
        }
        </style>
    </head>
    <body>
    "
    str_close = "
    </body>
    </html>
    "
    #width: 625;
    # get names of inputs and outputs
    input_names = EoM.name.(systems[1].actuators)
    output_names = EoM.name.(systems[1].sensors)

    # get number of ins, outs, and number of vpts (velocity points)
    nin = length(input_names)
    nout = length(output_names)
    nvpts = length(results)

    # get vpts
    v = vpt.(systems)

    # open the base html file to write, and start filling it
    output_f = open(joinpath(dir_date, filename * ".html"), "w")
    println(output_f, str_open)
    println(
        output_f,
        "<img src=\"figures/eom_logo.png\" alt=\"Icon\" style=\"width:200px;\">",
    )
    println(output_f, "<h1>Analysis results</h1>")
    println(output_f, "<p>Here are the results of the analysis of: $(systems[1].name)</p>")

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && nin * nout < 16 && length(ss) > 0
        println(output_f, "<h2>Steady state gains</h2>")
        labels = []
        gain = []
        # loop over outputs and inputs and vpts
        for i in 1:nout
            for j in 1:nin
                n = (i - 1) * nin + j
                if findnext(ss .== n, 1) !== nothing
                    x = zeros(nvpts)
                    for k in 1:nvpts
                        x[k] = my_round(results[k].ss_resp[i, j])
                    end
                    push!(gain, x[1])
                    lb = "$(output_names[i])/$(input_names[j])"
                    push!(labels, lb)
                    # if many vpts, make a plot vs velocity
                    if nvpts > 1
                        p = plot(
                            v,
                            x,
                            lw = 2,
                            xlabel = vpt_name[2]*" ["*vpt_name[3]*"]" ,
                            ylabel = lb,
                            label = "",
                            size = (600, 300),
                        )
                        # save the figure
                        path = joinpath(dir_data, "sstf_$(i)_$(j).html")
                        savefig(p, path)
                        f = open(path, "r")
                        println(output_f, read(f, String))
                        close(f)
                    end
                end
            end
        end

        # if only one vpt, make a table of the gains
        if nvpts == 1
            str = html_table(["Labels" "Gain"; labels my_round.(gain)])
            println(output_f, str)

            path = joinpath(dir_data, "sstf.html")
            temp = open(path, "w")
            println(temp, str_open, str, str_close)
            close(temp)
        end
    end

    # start eigenvalues
    println(output_f, "<h2>Eigenvalues</h2>")

    # get eigenvalues
    m = maximum(length.(e_val.(results)))
    s = zeros(m, nvpts) * 1im
    for i in 1:nvpts
        l = length(results[i].e_val)
        s[1:l, i] = results[i].e_val
    end
    #s=hcat(e_val.(results)...)

    # for one velocity, chart of calcs from eigenvalues, otherwise plot eigenvalues
    if nvpts == 1
        a = hcat(tau.(results)...)
        b = hcat(omega_n.(results)...)
        c = hcat(zeta.(results)...)
        d = hcat(lambda.(results)...)
        title = ["No." "σ±ωi [1/s]" "τ [s]" "ω_n [Hz]" "ζ" "λ [s]"]
        str = html_table([title; 1:1:length(a) my_round.([s a b c d])])
        println(output_f, str)

        path = joinpath(dir_data, "eigen.html")
        temp = open(path, "w")
        println(temp, str_open, str, str_close)
        close(temp)
    else
        # sort all zero roots to top
        sort!(s, dims = 1, by = abs)

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

        p = plot(xlabel =  vpt_name[2]*" ["*vpt_name[3]*"]", ylabel = "Eigenvalue [1/s]", size = (600, 300))
        if size(sr,1) > 0
            plot!(p, v, sr[1,:]; seriestype, label = "Real")
        end
        if size(si,1) > 0
            plot!(p, v, si[1,:]; seriestype, label = "Imaginary")
        end
        mc = RGB(0 / 255, 154 / 255, 250 / 255)
        if size(sr, 1) > 1
            plot!(p, v, sr'[:, 2:end]; seriestype, mc, label = "")
        end
        mc = RGB(227 / 255, 111 / 255, 71 / 255)
        if size(si, 1) > 1
            plot!(p, v, si'[:, 2:end]; seriestype, mc, label = "")
        end
        # save the figure
        path = joinpath(dir_data, "eigen.html")
        savefig(p, path)
        f = open(path, "r")
        println(output_f, read(f, String))
        close(f)

        b = unique.(omega_n.(results))
        nf = maximum(unique(length.(b)))
        
        for i in 1:length(b)
            if length(b[i]) < nf
                append!(b[i], zeros(nf-length(b[i]))*NaN) 
            end
        end
        b = hcat(b...)
        b[b.==0] .= NaN

        p = plot(xlabel =  vpt_name[2]*" ["*vpt_name[3]*"]", ylabel = "Natural frequency [Hz]", size = (600, 300))
        mc = RGB(0 / 255, 154 / 255, 250 / 255)
        if size(b,1) > 0
            plot!(p, v, b'; seriestype, mc, label = "")
        end
        # save the figure
        path = joinpath(dir_data, "freq.html")
        savefig(p, path)
        f = open(path, "r")
        println(output_f, read(f, String))
        close(f)

        c = unique.(zeta.(results))
        nf = maximum(unique(length.(c)))
        
        for i in 1:length(c)
            if length(c[i]) < nf
                append!(c[i], zeros(nf-length(c[i]))*NaN) 
            end
        end
        c = hcat(c...)
        c[c.==0] .= NaN

        p = plot(xlabel =  vpt_name[2]*" ["*vpt_name[3]*"]", ylabel = "Damping ratio", size = (600, 300))
        mc = RGB(0 / 255, 154 / 255, 250 / 255)
        if size(b,1) > 0
            plot!(p, v, c'; seriestype, mc, label = "")
        end
        # save the figure
        path = joinpath(dir_data, "damping.html")
        savefig(p, path)
        f = open(path, "r")
        println(output_f, read(f, String))
        close(f)






    end

    # if there are too many inputs and outputs, skip
    if nin * nout > 0 && length(bode) > 0 && nin * nout < 16
        println(output_f, "<h2>Bode plots</h2>")
        # pick out up to four representative vpts from the list
        l = unique(Int.(round.((nvpts - 1) .* [1, 3, 5, 7] / 8 .+ 1)))
        if length(l) == 1
            for i in 1:nin
                # fill in for each selected vpt
                w = results[l[1]].w / 2 / pi
                mag = 20 * log10.(abs.(results[l[1]].freq_resp[bode, i, :]) .+ eps(1.0))
                phs = 180 / pi * angle.(results[l[1]].freq_resp[bode, i, :])
                phs[phs.>0] .-= 360
                # set wrap arounds in phase to Inf to avoid jumps in plot
                phs[findall(abs.(diff(phs, dims = 2)) .> 180)] .= Inf
                label = hcat(output_names[bode]...)
                label .*= "/" * input_names[i]
                xscale = :log10
                p1 = plot(
                    w,
                    mag';
                    lw = 2,
                    label,
                    xlabel = "",
                    ylabel = "Gain [dB]",
                    xscale,
                    ylims = (-60, Inf),
                )
                p2 = plot(
                    w,
                    phs';
                    lw = 2,
                    label = "",
                    xlabel = "Frequency [Hz]",
                    ylabel = "Phase [deg]",
                    xscale,
                    ylims = (-360, 0),
                    yticks = -360:60:0,
                )
                # merge two subplots
                p = plot(
                    p1,
                    p2,
                    layout = grid(2, 1, heights = [0.66, 0.33]),
                    size = (600, 450),
                )
                # save the figure
                path = joinpath(dir_data, "bode_$i.html")
                savefig(p, path)
                f = open(path, "r")
                println(output_f, read(f, String))
                close(f)
            end
        else
            # loop over outputs and inputs and selected vpts
            for i in 1:nout
                for j in 1:nin
                    n = (i - 1) * nin + j
                    if !(findnext(bode .== i, 1) === nothing)
                        # make empty plots of magnitude and phase
                        xscale = :log10
                        ylabel = "|$(output_names[i])|/|$(input_names[j])| [dB]"
                        p1 = plot(; xlabel = "", ylabel, xscale, legend = :top)
                        ylabel = "∠ $(output_names[i])/$(input_names[j]) [deg]"
                        p2 = plot(;
                            xlabel = "Frequency [Hz]",
                            ylabel,
                            xscale,
                            ylims = (-360, 0),
                            yticks = -360:60:0,
                        )
                        # fill in for each selected vpt
                        for k in l
                            w = results[k].w / 2 / pi
                            mag =
                                20 * log10.(abs.(results[k].freq_resp[i, j, :]) .+ eps(1.0))
                            phs = 180 / pi * angle.(results[k].freq_resp[i, j, :])
                            phs[phs.>0] .-= 360
                            # set wrap arounds in phase to Inf to avoid jumps in plot
                            phs[findall(abs.(diff(phs)) .> 180)] .= Inf
                            if length(l) == 1
                                lb = ""
                            else
                                lb = vpt_name[1]*"=$(my_round(v[k])) "*vpt_name[3]
                            end
                            p1 = plot!(p1, w, mag, lw = 2, label = lb)
                            p2 = plot!(p2, w, phs, lw = 2, label = "")
                            # merge two subplots
                            p = plot(
                                p1,
                                p2,
                                layout = grid(2, 1, heights = [0.66, 0.33]),
                                size = (600, 450),
                            )
                        end
                        # save the figure
                        path = joinpath(dir_data, "bode_$(i)_$(j).html")
                        savefig(p, path)
                        f = open(path, "r")
                        println(output_f, read(f, String))
                        close(f)
                    end
                end
            end
        end
    end

    n = length(plots)
    if n > 0
        println(output_f, "<h2>Time history and other plots</h2>")
    end
    for i in 1:n
        # save the figure
        path = joinpath(dir_data, "plot_$(i).html")
        savefig(plots[i], path)
        f = open(path, "r")
        println(output_f, read(f, String))
        close(f)
    end

    # print instant centre of body 1
    if nvpts == 1
        println(output_f, "<h2>Rotation centres of first body</h2>")
        temp =
            my_round.([results[1].mode_vals (results[1].centre[1:6, 1:end])'])
        str = html_table([["Eigenvalue" "x" "y" "z" "u_x" "u_y" "u_z"]; temp])
        println(output_f, str)

        path = joinpath(dir_data, "centres.html")
        tmp2 = open(path, "w")
        println(tmp2, str_open, str, str_close)
        close(tmp2)
    end

    # add the static preloads
    println(output_f, "<h2>Preloads of first system</h2>")

    temp = ["Connector" "f_x" "f_y" "f_z" "m_x" "m_y" "m_z"]
    for item in [
        systems[1].rigid_points
        systems[1].flex_points
        systems[1].springs
        systems[1].links
    ]
        temp = vcat(
            temp,
            [item.name my_round.(item.force') my_round.(item.moment')],
        )
    end

    #=    for item in the_system.beams
           println(preload_f, "{$idx} {" * item.name * "} shear $(item.force[1][1]), $(item.force[1][2]), $(item.force[1][3]), $(norm(force[1]))")
           println(preload_f, "{} {} moment $(item.moment[1][1]), $(item.moment[1][2]), $(item.moment[1][3]), $(norm(item.moment[1]))")
           println(preload_f, "{} {} shear $(item.force[2][1]), $(item.force[2][2]), $(item.force[2][3]), $(norm(item.force[2]))")
           println(preload_f, "{} {} moment $(item.moment[2][1]), $(item.moment[2][2]), $(item.moment[2][3]), $(norm(item.moment[2]))")
           idx += 1
       end =#

    str = html_table(temp)
    println(output_f, str)

    path = joinpath(dir_data, "preloads.html")
    tmp2 = open(path, "w")
    println(tmp2, str_open, str, str_close)
    close(tmp2)
    # print the end and close the output
    println(output_f, str_close)
    close(output_f)
end

function html_table(mtx)
    # function to put array into html format
    n, m = size(mtx)

    str = "<table><thead>\n<tr>"
    for i in mtx[1, :]
        str *= "<th>$i</th>"
    end
    str *= "</tr>\n</thead><tbody>\n"
    for i = 2:n
        str *= "<tr>"
        for j in mtx[i, :]
            if j isa String || imag(j) != 0
                str *= "<td>$j</td>"
            else
                str *= "<td>$(real(j))</td>"
            end
        end
        str *= "</tr>\n"
    end
    str *= "</tbody></table>"
    str
end
