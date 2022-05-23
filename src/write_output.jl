function write_output(
    system::mbd_system,
    result::EoM.analysis,
    verbose::Bool = false;
    folder::String = "output",
    filename::String = system.name,
)
    write_output([system], 0, [result], verbose; folder, filename)
end

function write_output(
    systems::Vector{mbd_system},
    vpts,
    results::Vector{EoM.analysis},
    verbose::Bool = false;
    folder::String = "output",
    filename::String = systems[1].name,
)

    ## Copyright (C) 2017, Bruce Minaker
    ## write_output.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## write_output.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verbose && println("Writing output...")

    # set up the paths
    dirs = setup(folder = folder, data = filename)
    dir_date = dirs[1]
    dir_time = dirs[2]
    dir_data = joinpath(dir_date, dir_time)

    # get names of inputs and outputs
    input_names = getfield.(systems[1].actuators, :name)
    #    input_units = getfield.(systems[1].actuators, :units)
    output_names = getfield.(systems[1].sensors, :name)
    #    output_units = getfield.(systems[1].sensors, :units)

    # get number of ins, outs, and number of vpts (velocity points)
    nin = length(input_names)
    nout = length(output_names)

    nvpts = length(vpts)

    ## Initialize output strings

    eigen_f = open(joinpath(dir_data, "eigen.out"), "w")
    println(
        eigen_f,
        "###### Eigenvalues\nnum vpt real imag realhz imaghz nfreq zeta tau lambda",
    )

    mode_f = open(joinpath(dir_data, "eigen_modes.out"), "w")
    println(mode_f, "###### Eigenvalues\nnum vpt real imag")

    centre_f = open(joinpath(dir_data, "centre.out"), "w")
    println(centre_f, "###### Rotation centre, Axis of rotation\n num name speed r ri")

    sstf_f = open(joinpath(dir_data, "sstf.out"), "w")
    println(sstf_f, "###### Steady State Transfer Function")
    if (nvpts > 1)
        print(sstf_f, "vpt")
        for i in 1:nin*nout
            print(sstf_f, " ", i)
        end
        println(sstf_f, "")
    end

    bode_f = open(joinpath(dir_data, "bode.out"), "w")
    println(bode_f, "###### Bode Mag Phase")
    print(bode_f, "vpt frequency")

    for i in 1:nin*nout
        print(bode_f, " m$i")
    end
    for i in 1:nin*nout
        print(bode_f, " p$i")
    end
    println(bode_f, "")

    #hsv_f=open(joinpath(dir_output,"hsv.out"),"w")
    #println(hsv_f,"###### Hankel SVD\nnum speed hsv")

    for i in 1:nvpts
        for j in 1:length(results[i].mode_vals)
            rr = real(results[i].mode_vals[j])
            ii = imag(results[i].mode_vals[j])
            ## Write the number, the speed, then the eigenvalue
            println(mode_f, "{", j, "} ", vpts[i], " ", rr, " ", ii)
            for k in 1:length(systems[i].bodys)-1
                for m in 1:6
                    ## Write the number, the speed ...
                    print(centre_f, "{", j, "} ")
                    print(centre_f, "{", systems[i].bodys[k].name, "} ")
                    print(centre_f, vpts[i])
                    print(centre_f, " ", real(results[i].centre[6*k-6+m, j]))
                    println(centre_f, " ", imag(results[i].centre[6*k-6+m, j]))
                end
                println(centre_f, "")
            end
            println(centre_f, "")
        end
        println(mode_f, "")

        for j in 1:length(results[i].e_val)
            realpt = real(results[i].e_val[j])
            imagpt = imag(results[i].e_val[j])
            ## Write the number, the speed, then the eigenvalue
            print(eigen_f, "{", j, "} ", vpts[i], " ")
            print(eigen_f, realpt, " ", imagpt, " ", realpt / 2pi, " ", imagpt / 2pi)
            print(eigen_f, " ", results[i].omega_n[j])
            print(eigen_f, " ", results[i].zeta[j])
            print(eigen_f, " ", results[i].tau[j])
            println(eigen_f, " ", results[i].lambda[j])
        end
        println(eigen_f, "")
    end

    if nin * nout > 0
        for i in 1:nvpts
            if nvpts == 1
                println(sstf_f, "num outputtoinput gain")
                for j in 1:nout
                    for k in 1:nin
                        print(sstf_f, "{", (j - 1) * nin + k, "} ")
                        print(sstf_f, "{", output_names[j], "/")
                        print(sstf_f, input_names[k], "} ")
                        println(sstf_f, results[i].ss_resp[j, k])
                    end
                end
            else
                ## Each row starts with vpoint, followed by first column, written as a row, then next column, as a row
                print(sstf_f, vpts[i], " ")
                for k in vec(results[i].ss_resp[:, :])
                    print(sstf_f, k, " ")
                end
                println(sstf_f, "")
            end

            for j in 1:length(results[i].w) ## Loop over frequency range
                ## Each row starts with vpt, then freq in Hz
                print(bode_f, vpts[i], " ", results[i].w[j] / 2 / pi, " ")
                # Followed by first mag column, written as a row, then next column, as a row
                for k in vec(results[i].mag[j])
                    print(bode_f, k, " ")
                end
                # Followed by first phase column, written as a row, then next column, as a row
                for k in vec(results[i].phase[j])
                    print(bode_f, k, " ")
                end
                println(bode_f, "")
            end
            println(bode_f, "")

            #for j=1:length(results[i].hsv)
            #	println(hsv_f,"{",j,"} ",the_list[i].vpt," ",results[i].hsv[j])  ## Write the vpoint (e.g. speed), then the hankel_sv
            #end
            #println(hsv_f,"")
        end
    end

    close(sstf_f)
    close(eigen_f)
    close(mode_f)
    close(centre_f)
    close(bode_f)

    #close(hsv_f)

    load_defln(systems[1], dir_data)
    syst_props(systems[1], dir_data)

    ss_path = joinpath(dir_data, "ss")
    ~isdir(ss_path) && (mkdir(ss_path))

    writedlm(joinpath(ss_path, "A.out"), results[1].ss_eqns.A)
    writedlm(joinpath(ss_path, "B.out"), results[1].ss_eqns.B)
    writedlm(joinpath(ss_path, "C.out"), results[1].ss_eqns.C)
    writedlm(joinpath(ss_path, "D.out"), results[1].ss_eqns.D)

    dir_data

end ## Leave


# dss_path = joinpath(dir_data, "dss")
# ~isdir(dss_path) && (mkdir(dss_path))

# writedlm(joinpath(dss_path, "A.out"), eoms.A)
# writedlm(joinpath(dss_path, "B.out"), eoms.B)
# writedlm(joinpath(dss_path, "C.out"), eoms.C)
# writedlm(joinpath(dss_path, "D.out"), eoms.D)
# writedlm(joinpath(dss_path, "E.out"), eoms.E)
