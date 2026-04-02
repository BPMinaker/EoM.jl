function item_locations(syst::mbd_system, pout)
## Copyright (C) 2017, Bruce Minaker
## This file is intended for use with Octave.
## item_locations.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## item_locations.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## This function computes the locations of the connector item endpoints from body position time history

    function location(temp, bnum, k, radius)
        radius + temp[6 * bnum .+ (-5:-3), k] + cross(temp[6 * bnum .+ (-2:0), k], radius)
    end

    n = size(pout, 2)
    temp = [pout; zeros(6, n)]  ## Add zeros for ground for now

    for j in [syst.rigid_points; syst.flex_points]
        lcn = hcat([location(temp, j.body_number[1], k, j.radius[1]) for k in 1:n]...)
        pout = [pout; lcn]  ## Add rigid_point locations to output
    end

    for j in syst.loads
        lcn = hcat([location(temp, j.body_number, k, j.radius) for k in 1:n]...)
        pout = [pout; lcn]  ## Add load end locations to output
    end

    for j in [syst.links; syst.springs]        
        lcn1 = hcat([location(temp, j.body_number[1], k, j.radius[1]) for k in 1:n]...)
        lcn2 = hcat([location(temp, j.body_number[2], k, j.radius[2]) for k in 1:n]...)
        pout = [pout;lcn1;lcn2]  ## Add link end locations to output
    end

    pout
end  ## Leave
