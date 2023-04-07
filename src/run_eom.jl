function run_eom!(the_system::mbd_system, verb::Bool = false)

    sort_system!(the_system, verb) # sort all the input structs
    the_data = generate_eom(the_system, verb)
    assemble_eom!(the_data, verb)

end

function diagnose!(the_system::mbd_system, verb::Bool = false)

    sort_system!(the_system, verb) # sort all the input structs
    the_data = generate_eom(the_system, verb)
    assemble_eom!(the_data, verb), the_data

end