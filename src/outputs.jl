function outputs!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)

    # Generates the Jacobian output matrix for the sensors
    verb && println("Building output matrix...")

    nin = length(the_system.actuators)
    nout = length(the_system.sensors)
    d_mtx = zeros(nout, nin)

    n = length(the_system.bodys)

    data.output =
        -diagm(0 => getfield.(the_system.sensors, :gain)) * point_line_jacobian(the_system.sensors, n)

    order_vec = getfield.(the_system.sensors, :order)
    frame_vec = getfield.(the_system.sensors, :frame)

    data.column = 2 * order_vec + frame_vec .- 2  # Global psn,vel,acc=1,3,5, local vel,acc=2,4

    idx = 1
    for i in the_system.sensors
        if i.actuator_number > 0
            d_mtx[idx, i.actuator_number] = i.actuator_gain
        end
        idx += 1
    end
    data.feedthrough = d_mtx

end ## Leave