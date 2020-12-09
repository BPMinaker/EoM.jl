function inputs!(the_system, data, verb)
    ## Copyright (C) 2017, Bruce Minaker
    ## inputs.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## inputs.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Generate the Jacobian input matrix for the actuators
    verb && println("Building input matrix...")

    nrows = length(the_system.actuators)
    n = length(the_system.bodys)

    ## Build input matrix
    temp = point_line_jacobian(the_system.actuators, n)
    f_mtx = -diagm(0 => gain.(the_system.actuators)) * temp
    g_mtx = -diagm(0 => rate_gain.(the_system.actuators)) * temp

    data.input = f_mtx'
    data.input_rate = g_mtx'  ## Transpose
end
