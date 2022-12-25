function full_ss(dss_eqns::EoM.dss_data, verb::Bool = false)

    verb && println("Converting...")

    nvpts = length(dss_eqns)  ## Number of points to plot
    result = Vector{ss_data}(undef, nvpts)

    for i = 1:nvpts
        m = size(dss_eqns[i].phys, 1)
        n = size(dss_eqns[i].B, 2)

        temp = dss_data(
            dss_eqns[i].A,
            dss_eqns[i].B,
            dss_eqns[i].phys,
            zeros(m, n),
            dss_eqns[i].E,
            dss_eqns[i].phys,
        )
        result[i], val = dss2ss(temp, verbose && i < 2)  ## Reduce to standard form
    end
    result
end ## Leave
