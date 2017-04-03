function setup(;dir_data="data",dir_output="output",dir_stock="stock")

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

## Define data directories
dir_output=joinpath(dir_data,dir_output)
dir_stock=joinpath(dir_data,dir_stock)

dir=joinpath(pwd(),dir_data)
if(~isdir(dir))  ## If no data folder exists
	mkdir(dir)  ## create new empty one
end

dir=joinpath(pwd(),dir_output)
if(~isdir(dir))  ## If no output folder exists
	mkdir(dir)  ## Create new empty output folder
end

dir=joinpath(pwd(),dir_output,dtstr)
if(~isdir(dir))  ## If no dated output folder exists
	mkdir(dir)  ## Create new empty dated output folder
end

dir_output=joinpath(dir_output,dtstr,tmstr)
cp(joinpath(pwd(),dir_stock),dir_output)  ## Create new empty output folder date/time

dir_output

end  ## Leave
