function input_ex_smd(;m=1.0,c=0.1,k=10.0,v=[0,0,0],w=[0,0,0],I=[1,1,1])
the_system=mbd_system("Spring Mass Damper")

## Copyright (C) 2017, Bruce Minaker
## input_ex_smd.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_smd.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## Add the body
item=body("block")
item.mass=m
item.moments_of_inertia=I
item.products_of_inertia=[0,0,0]
item.location=[0,0,1]
item.velocity=v
item.angular_velocity=w
push!(the_system.item,item)

## Constrain the body to one translation in z, and no rotations
item=rigid_point("slider 1")
item.body[1]="block"
item.body[2]="ground"
item.location=[0,0,1]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

## Add a flex_point, with damping, to connect our body to ground, aligned with z-axis
item=flex_point("spring 1")
item.body[1]="block"
item.body[2]="ground"
item.location=[0,0,0.5]
item.stiffness=[k,0]
item.damping=[c,0]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

## The actuator is a 'line item' and defined by two locations, location[1] attaches to body[1]...
item=actuator("actuator 1")
item.body[1]="block"
item.body[2]="ground"
item.location[1]=[0.05,0,1]
item.location[2]=[0.05,0,0]
push!(the_system.item,item)

item=sensor("sensor 1")
item.body[1]="block"
item.body[2]="ground"
item.location[1]=[0,0.05,1]
item.location[2]=[0,0.05,0]
push!(the_system.item,item)

the_system

end
