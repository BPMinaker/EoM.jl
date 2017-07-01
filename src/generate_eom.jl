function generate_eom(the_system;verbose=false)
## Copyright (C) 2017, Bruce Minaker
## generate_eom.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## generate_eom.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Generate the linearized equations of motion for a multibody system

## Begin construction of equations of motion
verbose && println("Okay, got the system info, building equations of motion...")

nvpts=length(the_system)

## Build container
data=Vector{eom_data}(nvpts)
ss_eqns=Vector{ss_data}(nvpts)

for i=1:nvpts

	data[i]=eom_data()
	data[i].name=the_system[i].name

	## Build the mass matrix
	data[i].mass=mass(the_system[i],(i<2)*verbose)

	## Sum external forces and cast into vector
	## Determine stiffness matrix for angular motion resulting from applied forces
	force!(the_system[i],data[i],(i<2)*verbose)

	## Build the stiffness matrix due to deflections of elastic elements
	elastic_connections!(the_system[i],data[i],(i<2)*verbose)

	## Build the matrices describing the rigid constraints
	rigid_constraints!(the_system[i],data[i],(i<2)*verbose)

	## Solve for the internal and reaction forces and distribute
	preload!(data[i],(i<2)*verbose)
	const_frc_deal!(the_system[i],data[i].lambda,(i<2)*verbose)
	defln_deal!(the_system[i],data[i].static,(i<2)*verbose)

	## Build the tangent stiffness matrix from the computed preloads
	tangent!(the_system[i],data[i],(i<2)*verbose)

	## Build the input matrix
	inputs!(the_system[i],data[i],(i<2)*verbose)

	## Build the output matrix
	col=outputs!(the_system[i],data[i],(i<2)*verbose)

	## Assemble the system equations of motion
	ss_eqns[i]=assemble_eom!(data[i],col,(i<2)*verbose)

	## Reduce to standard form
	dss2ss!(ss_eqns[i],(i<2)*verbose)
end

ss_eqns

## End of routine
end
