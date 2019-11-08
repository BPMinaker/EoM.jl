function input_ex_beam(;m1=10.0,m2=10.0,EI=100.0)

## Copyright (C) 2017, Bruce Minaker
## This file is intended for use with Octave.
## input_ex_beam.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_beam.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

the_system=mbd_system("Masses and Beam")

item=body("body one")
item.mass=m1
item.moments_of_inertia=[2,2,2]
item.products_of_inertia=[0,0,0]
item.location=[0,0,0]
push!(the_system.item,item)

item=body("body two")
item.mass=m2
item.moments_of_inertia=[2,2,2]
item.products_of_inertia=[0,0,0]
item.location=[1,0,0]
push!(the_system.item,item)

item=beam("beam one")
item.body[1]="body one"
item.body[2]="body two"
item.location[1]=[0,0,0]
item.location[2]=[1,0,0]
item.stiffness=EI
push!(the_system.item,item)

item=rigid_point("pin one")
item.body[1]="body one"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=3
item.moments=2
item.axis=[0,1,0]
push!(the_system.item,item)


item=actuator("servo one")
item.body[1]="ground"
item.body[2]="body two"
item.location[1]=[1,-0.5,0]
item.location[2]=[1,0,0]
item.twist=1
item.gain=1
push!(the_system.item,item)


item=sensor("sensor one")
item.body[1]="ground"
item.body[2]="body two"
item.location[1]=[1,-0.5,0]
item.location[2]=[1,0,0]
item.twist=1
item.gain=1
push!(the_system.item,item)

the_system

end
