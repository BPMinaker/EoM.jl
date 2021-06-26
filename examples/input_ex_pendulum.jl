function input_ex_pendulum(;m=10.0,l=0.5,r=0.05^0.5,I=5.5-m*r^2)

## Copyright (C) 2021, Bruce Minaker
## input_ex_pendulum.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_pendulum.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

# the pendulum example from Anderson Practice of Engineering Dynamics
the_system=mbd_system("Pendulum")

# add the body, and weight force in -ve z
item=body("block")
item.mass=m
item.location=[0,0,1]
item.moments_of_inertia=[I,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item,9.807))

# constrain the body to planar motion in yz
item=rigid_point("planar")
item.body[1]="block"
item.body[2]="ground"
item.location=[0,0,1]
item.forces=1
item.moments=2
item.axis=[1,0,0]
push!(the_system.item,item)

# add a string to connect our body to ground, aligned with z-axis
item=link("string")
item.body[1]="block"
item.body[2]="ground"
item.location[1]=[0,0,1+r]
item.location[2]=[0,0,1+r+l]
push!(the_system.item,item)

# the actuator is a `line item` and defined by two locations, location[1] attaches to body[1]...
item=actuator("Y")
item.body[1]="block"
item.body[2]="ground"
item.location[1]=[0,0,1]
item.location[2]=[0,-1,1]
push!(the_system.item,item)

# the sensor is also `line item` and defined by two locations, location[1] attaches to body[1]...
item=sensor("y")
item.body[1]="block"
item.body[2]="ground"
item.location[1]=[0,0,1]
item.location[2]=[0,-1,1]
push!(the_system.item,item)

the_system

end
