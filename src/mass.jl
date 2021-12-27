function mass(the_system::mbd_system, verb::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## mass.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## mass.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verb && println("Building mass matrix...")

    temp = mass_mtx.(the_system.bodys[1:end-1])
    n = length(temp)
    mtx = zeros(6 * n, 6 * n)

    for i = 1:n
        mtx[6*i-5:6*i, 6*i-5:6*i] = temp[i]
    end

    mtx

end ## Leave
