function tangent!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)

    # Build angular stiffness matrix from motion of items with preload, both rigid and flexible
    verb && println("Building tangent stiffness...")

    n = length(the_system.bodys)

    data.tangent_stiffness =
        hessian(the_system.links, n) + hessian(the_system.springs, n) +
        hessian(the_system.flex_points, n) + hessian(the_system.rigid_points, n)

end