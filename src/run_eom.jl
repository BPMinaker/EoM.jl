function run_eom!(the_system::mbd_system, verb::Bool=false)

    sort_system!(the_system, verb) # sort all the input structs
    the_data = generate_eom(the_system, verb)
    dss_data(assemble_eom!(the_data, verb)..., system_data(the_system))
end

function diagnose!(the_system::mbd_system, verb::Bool=false)

    sort_system!(the_system, verb) # sort all the input structs
    the_data = generate_eom(the_system, verb)
    assemble_eom!(the_data, verb), the_data

end
