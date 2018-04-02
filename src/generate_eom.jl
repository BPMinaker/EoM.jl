function generate_eom(the_system,verbose=false)
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

data=eom_data()
data.name=the_system.name

## Build the mass matrix
data.mass=mass(the_system,verbose)

## Sum external forces and cast into vector
## Determine stiffness matrix for angular motion resulting from applied forces
force!(the_system,data,verbose)

## Build the stiffness matrix due to deflections of elastic elements
elastic_connections!(the_system,data,verbose)

## Build the matrices describing the rigid constraints
rigid_constraints!(the_system,data,verbose)

## Solve for the internal and reaction forces and distribute
preload!(data,verbose)
const_frc_deal!(the_system,data.lambda,verbose)
defln_deal!(the_system,data.static,verbose)

## Build the tangent stiffness matrix from the computed preloads
tangent!(the_system,data,verbose)

## Build the input matrix
inputs!(the_system,data,verbose)

## Build the output matrix
col=outputs!(the_system,data,verbose)

## Assemble the system equations of motion
dss_eqns=assemble_eom!(data,col,verbose)

!verbose && print(".")

dss_eqns

## End of routine
end
