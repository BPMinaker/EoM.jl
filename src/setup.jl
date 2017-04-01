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

type config_struct
	dtstr::String
	tmstr::String
	dir_data::String
	dir_input::String
	dir_output::String
	dir_stock::String
#	dir_vrml::String
	dir_raw::String

	function config_struct(dtstr="",tmstr="",dir_data="",dir_input="",dir_output="",dir_stock="",dir_raw="")
		new(dtstr,tmstr,dir_data,dir_input,dir_output,dir_stock,dir_raw)
	end
end

type option_struct
	analyze::Bool
	report::Bool
	animate::Bool
	sketch::Bool
	schematic::Bool

	function option_struct(analyze=true,report=false,animate=false,sketch=false,schematic=false)
		new(analyze,report,animate,sketch,schematic)
	end
end

function setup(flags)

config=config_struct()

## Record the date and time for the output filenames, ISO format
config.dtstr=Dates.format(now(),"yyyy-mm-dd")
config.tmstr=Dates.format(now(),"HH-MM-SS")

## Define data directories
config.dir_data="data"
config.dir_input=joinpath(config.dir_data,"input")
config.dir_output=joinpath(config.dir_data,"output")
config.dir_stock=joinpath(config.dir_data,"stock")

if(~isdir(joinpath(pwd(),config.dir_data)))  ## If no data folder exists
	mkdir(joinpath(pwd(),config.dir_data))  ## create new empty one
end

if(~isdir(joinpath(pwd(),config.dir_input)))  ## If no input folder exists
	mkdir(joinpath(pwd(),config.dir_input))  ## create new empty one
end

if(~isdir(joinpath(pwd(),config.dir_output)))  ## If no output folder exists
	mkdir(joinpath(pwd(),config.dir_output))  ## Create new empty output folder
end

option=option_struct()

for i in flags ## Loop over them
	if(isa(i,String))  ## Otherwise, look for output control strings
		if(i=="report")
			option.report=true
		elseif(i=="animate")
			option.animate=true
		elseif(i=="sketch")
			option.sketch=true
		elseif(i=="schematic")
			option.schematic=true
		elseif(i=="quiet")
			option.analyze=false
		else
			error("Unrecognized flag.")
		end
	else
		error("Invalid argument type.")  ## Don't know what to do
	end
end

if(option.report)

	option.analyze=true  ## Must analyze to write report

	if(~isdir(joinpath(pwd(),config.dir_output,config.dtstr)))  ## If no dated output folder exists
		mkdir(joinpath(pwd(),config.dir_output,config.dtstr))  ## Create new empty dated output folder
	end

	config.dir_output=joinpath(config.dir_output,config.dtstr,config.tmstr)
	cp(joinpath(pwd(),config.dir_stock),config.dir_output)  ## Create new empty output folder date/time

	config.dir_raw=joinpath(config.dir_output,"unformatted")
	mkdir(joinpath(pwd(),config.dir_raw))  ## Create unformatted folder

end

config,option

end
