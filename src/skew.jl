function skew(vct)
    ## Copyright (C) 2017, Bruce Minaker
    ## skew.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## skew.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## This function forms the skew symmetric matrix for the vector argument

    [0 -vct[3] vct[2]; vct[3] 0 -vct[1]; -vct[2] vct[1] 0]

end  ## Leave
