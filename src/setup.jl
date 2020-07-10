function setup(;folder="output",data="data")

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


if ~isdir(folder)  # if no output folder exists
	mkdir(folder)  # create new empty output folder
end

# record the date and time for the output filenames, ISO format
dtstr=Dates.format(now(),"yyyy-mm-dd")
dir_date=joinpath(folder,dtstr)
if ~isdir(dir_date)  # if no dated output folder exists
	mkdir(dir_date)  # create new empty dated output folder
end

dir=joinpath(dir_date,"figures")
if ~isdir(dir)  # if no figures folder exists
	mkdir(dir)  # create new empty system folder
	src=joinpath(dirname(dirname(pathof(EoM))),"images","eom_logo.png")  # get name of logo
	cp(src,joinpath(dir,"eom_logo.png"))
end

dir=joinpath(dir_date,data)
if ~isdir(dir)  # if no system folder exists
	mkdir(dir)  # create new empty system folder
end

tmstr=Dates.format(now(),"HH-MM-SS-s")
dir_output=joinpath(dir,tmstr)
if ~isdir(dir_output)
	mkdir(dir_output)  # create new empty timed output folder
end
dir_time=joinpath(data,tmstr)

dir=joinpath(dir_output,"dss")
if ~isdir(dir)
	mkdir(dir)
end

dir=joinpath(dir_output,"ss")
if ~isdir(dir)
	mkdir(dir)
end

dir_date,dir_time

end  ## Leave


# if ~isfile(joinpath(folder,"eom.mark")) # check if we made this folder before
#
# 	# if not, use folder as base name
# 	dir=folder
# 	if ~isdir(dir)  # if no output folder exists
# 		mkdir(dir)  # create new empty output folder
# 	end
# 	# record the date and time for the output filenames, ISO format
# 	dtstr=Dates.format(now(),"yyyy-mm-dd")
# 	dir=joinpath(dir,dtstr)
# 	if ~isdir(dir)  # if no dated output folder exists
# 		mkdir(dir)  # create new empty dated output folder
# 	end
# 	tmstr=Dates.format(now(),"HH-MM-SS-s")
# 	dir_output=joinpath(dir,tmstr)
# 	if ~isdir(dir_output)
# 		mkdir(dir_output)  # create new empty timed output folder
# 		touch(joinpath(dir_output,"eom.mark")) # mark it
# 	else
# 		println("Warning! Reusing exisiting output folder!")
# 	end
# else
# 	dir_output=folder # if marked, reuse with new data sub folder
# end
