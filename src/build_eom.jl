function build_eom(the_system,verb=false)
## Copyright (C) 2017, Bruce Minaker
## build_eom.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## build_eom.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Generate the linearized equations of motion for a multibody system

## Begin construction of equations of motion
verb && println("Okay, got the system info, building equations of motion...")

## Build container
data=matrix_struct()

data.name=the_system.name
data.input_names=broadcast(name,the_system.actuators)
data.output_names=broadcast(name,the_system.sensors)

## Build the mass matrix
mass!(the_system,data,verb)

## Sum external forces and cast into vector
## Determine stiffness matrix for angular motion resulting from applied forces
force!(the_system,data,verb)

## Build the stiffness matrix due to deflections of elastic elements
elastic_connections!(the_system,data,verb)

## Build the matrices describing the rigid constraints
rigid_constraints!(the_system,data,verb)

## Solve for the internal and reaction forces and distribute
preload!(data,verb)
const_frc_deal!(the_system,data.lambda,verb)
defln_deal!(the_system,data.static,verb)

## Build the tangent stiffness matrix from the computed preloads
tangent!(the_system,data,verb)

## Build the input matrix
inputs!(the_system,data,verb)

## Build the output matrix
col=outputs!(the_system,data,verb)

## Assemble the system equations of motion
assemble_eom!(data,col,verb)

## Reduce to standard form
dss2ss!(data,verb)

data

## End of routine
end
