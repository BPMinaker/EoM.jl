function run_eom!(the_system::mbd_system, verb::Bool = false)

    ## Copyright (C) 2017, Bruce Minaker
    ## run_eom.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## run_eom.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    sort_system!(the_system, verb) # sort all the input structs
    the_data = generate_eom(the_system, verb)
    assemble_eom!(the_data, verb)

end
