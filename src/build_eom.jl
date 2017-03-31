function build_eom(the_system,verb)
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

## Build the mass matrix
data.mass=mass(the_system,verb)

## Sum external forces and cast into vector
## Determine stiffness matrix for angular motion resulting from applied forces
data.force,data.load_stiffness=force(the_system,verb)

## Build the stiffness matrix due to deflections of elastic elements
data.stiffness,data.damping,data.inertia,data.deflection,data.selection,data.preload,data.spring_stiffness,data.subset_spring_stiffness=elastic_connections(the_system,verb)

## Build the matrices describing the rigid constraints
data.constraint,data.nh_constraint,data.right_jacobian,data.left_jacobian,data.momentum,data.velocity=rigid_constraints(the_system,verb)

## Solve for the internal and reaction forces and distribute
data.lambda,data.static=preload(data,verb)
const_frc_deal!(the_system,data.lambda,verb)
defln_deal!(the_system,data.static,verb)

## Build the tangent stiffness matrix from the computed preloads
data.tangent_stiffness=tangent(the_system,verb)

## Build the input matrix
data.input,data.input_rate=inputs(the_system,verb)

## Build the output matrix
data.output,data.feedthrough,col=outputs(the_system,verb)

## Assemble the system equations of motion
assemble_eom!(data,col,verb)

## Reduce to standard form
dss2ss!(data)

data

## End of routine
end
