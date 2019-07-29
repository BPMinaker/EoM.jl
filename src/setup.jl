function setup(dir_raw,dir_time)

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

dir=joinpath(pwd(),"output")
if(~isdir(dir))  ## If no output folder exists
	mkdir(dir)  ## Create new empty output folder
end

## Record the date and time for the output filenames, ISO format
dtstr=Dates.format(now(),"yyyy-mm-dd")
dir=joinpath(pwd(),"output",dtstr)
if(~isdir(dir))  ## If no dated output folder exists
	mkdir(dir)  ## Create new empty dated output folder
end

if length(dir_time)==0
	tmstr=Dates.format(now(),"HH-MM-SS-s")
else
	tmstr=dir_time
end
dir_output=joinpath(dir,tmstr)
mkdir(dir_output)  ## Create new empty timed output folder

dir=joinpath(dir_output,dir_raw)
if(~isdir(dir))  ## If no timed output folder exists
	mkdir(dir)  ## Create new empty timed output folder
end

dir=joinpath(dir_output,dir_raw,"dss")
if(~isdir(dir))
	mkdir(dir)
end

dir=joinpath(dir_output,dir_raw,"ss")
if(~isdir(dir))
	mkdir(dir)
end

dir=joinpath(dir_output,dir_raw,"jordan")
if(~isdir(dir))
	mkdir(dir)
end

dir_output

end  ## Leave
