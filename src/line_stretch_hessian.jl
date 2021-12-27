function hessian(items::Union{Vector{link}, Vector{spring}, Vector{beam}, Vector{sensor}, Vector{actuator}}, num::Int64)
    ## Copyright (C) 2017, Bruce Minaker
    ## line_stretch_hessian.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## line_stretch_hessian.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    mtx = zeros(6 * num, 6 * num) ## Create empty matrix

    for i in items
        # find the two bodies attached by the link, and where they appear in the state vector
        ptr_1, ptr_2 = ptr(i)

        su = skew(i.unit)  ## Unit vector defining axis of action of directed item
        srs = skew(i.radius[1])  ## Radius from body1 cg to point of action of directed item on body1; 's'=start
        sre = skew(i.radius[2])  ## Radius from body2 cg to point of action of directed item on body2; 'e'=end

        t1 = [-su su * srs]
        t2 = [su -su * sre]

        temp = i.preload / i.length
        mtx[ptr_1 .+ (1:6), ptr_1 .+ (1:6)] += temp * t1' * t1
        mtx[ptr_2 .+ (1:6), ptr_2 .+ (1:6)] += temp * t2' * t2
        mtx[ptr_1 .+ (1:6), ptr_2 .+ (1:6)] += temp * t1' * t2
        mtx[ptr_2 .+ (1:6), ptr_1 .+ (1:6)] += temp * t2' * t1

        mtx[ptr_1 .+ (1:6), ptr_1 .+ (4:6)] -= i.preload * t1'
        mtx[ptr_2 .+ (1:6), ptr_2 .+ (4:6)] -= i.preload * t2'

    end

    n = 6 * (num - 1)  ## Eliminates ground body from n
    mtx[1:n, 1:n]

end  ## Leave
