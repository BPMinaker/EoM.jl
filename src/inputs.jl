function inputs!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)

    # Generate the Jacobian input matrix for the actuators
    verb && println("Building input matrix...")

    nrows = length(the_system.actuators)
    n = length(the_system.bodys)

    # Build input matrix
    temp = point_line_jacobian(the_system.actuators, n)
    f_mtx = -diagm(0 => getfield.(the_system.actuators, :gain)) * temp
    g_mtx = -diagm(0 => getfield.(the_system.actuators, :rate_gain)) * temp

    data.input = f_mtx'
    data.input_rate = g_mtx'  # Transpose
end