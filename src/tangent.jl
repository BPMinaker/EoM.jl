function tangent!(the_system, data, verb)
    ## Copyright (C) 2017, Bruce Minaker
    ## tangent.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## tangent.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Build angular stiffness matrix from motion of items with preload, both rigid and flexible
    verb && println("Building tangent stiffness...")

    n = length(the_system.bodys)

    data.tangent_stiffness =
        line_stretch_hessian([the_system.links; the_system.springs], n) +
        point_hessian([the_system.flex_points; the_system.rigid_points], n)

end
