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

if(~isdir(joinpath(pwd(),dir_data)))  ## If no data folder exists
	mkdir(joinpath(pwd(),dir_data))  ## create new empty one
end

if(~isdir(joinpath(pwd(),dir_output)))  ## If no output folder exists
	mkdir(joinpath(pwd(),dir_output))  ## Create new empty output folder
end

if(~isdir(joinpath(pwd(),dir_output,dtstr)))  ## If no dated output folder exists
	mkdir(joinpath(pwd(),dir_output,dtstr))  ## Create new empty dated output folder
end

dir_output=joinpath(dir_output,dtstr,tmstr)
cp(joinpath(pwd(),dir_stock),dir_output)  ## Create new empty output folder date/time

dir_output

end  ## Leave


# type config_struct
# 	dir_output::String
# 	dir_stock::String
#
# 	function config_struct(dtstr="",tmstr="",dir_data="",dir_output="",dir_stock="")
# 		new(dtstr,tmstr,dir_data,dir_output,dir_stock)
# 	end
# end

# type option_struct
# 	analyze::Bool
# 	report::Bool
#
# 	function option_struct(analyze=true,report=false)
# 		new(analyze,report)
# 	end
# end


# option=option_struct()
#
# for i in flags ## Loop over them
# 	if(isa(i,String))  ## Otherwise, look for output control strings
# 		if(i=="report")
# 			option.report=true
# 		elseif(i=="quiet")
# 			option.analyze=false
# 		else
# 			error("Unrecognized flag.")
# 		end
# 	else
# 		error("Invalid argument type.")  ## Don't know what to do
# 	end
# end
