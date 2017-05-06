function setup()

## Copyright (C) 2017, Bruce Minaker
## setup.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## setup.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Record the date and time for the output filenames, ISO format
dtstr=Dates.format(now(),"yyyy-mm-dd")
tmstr=Dates.format(now(),"HH-MM-SS")
dir_output=joinpath(dtstr,tmstr)

dir=joinpath(pwd(),dtstr)
if(~isdir(dir))  ## If no dated output folder exists
	mkdir(dir)  ## Create new empty dated output folder
end

cp(joinpath(Pkg.dir(),"EoM","src","report"),joinpath(pwd(),dir_output))  ## Create output folder date/time

dir_output

end  ## Leave
