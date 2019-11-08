function input_ex_quarter_car(;mu=50,ms=500,ks=18000,kt=180000,cs=1500)

## Copyright (C) 2017, Bruce Minaker
## input_ex_quarter_car.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_quarter_car.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## A 'quarter-car' model, two bodys, constrained to ground, allowing translation
## in the z axis only, with two point springs connecting them.  The point spring
## has stiffness and damping defined in translation along the z axis only.  An
## actuator connects the sprung mass to the ground as well, to provide input forces.
##  Note that the ground body is pre-defined.
the_system=mbd_system("Quarter Car Model")

## Add the unsprung mass, along the z-axis
item=body("unsprung")
item.mass=mu
item.location=[0,0,0.3]
push!(the_system.item,item)
push!(the_system.item,weight(item))

## Add another identical rigid body, along the z-axis
item=body("sprung")
item.mass=ms
item.location=[0,0,0.6]
push!(the_system.item,item)
push!(the_system.item,weight(item))

## Add a spring, with no damping, to connect our unsprung mass to ground, aligned with z-axis
item=flex_point("tire")
item.body[1]="unsprung"
item.body[2]="ground"
item.stiffness=[kt,0]
item.location=[0,0,0.15]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

## Add another spring, with damping, to connect our sprung and unsprung mass
item=flex_point("susp")
item.body[1]="sprung"
item.body[2]="unsprung"
item.stiffness=[ks,0]
item.damping=[cs,0]
item.location=[0,0,0.45]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

## Constrain unsprung mass to translation in z-axis, no rotation
item=rigid_point("slider one")
item.body[1]="unsprung"
item.body[2]="ground"
item.location=[0,0,0.3]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

## Constrain sprung mass to translation in z-axis, no rotation
item=rigid_point("slider two")
item.body[1]="sprung"
item.body[2]="ground"
item.location=[0,0,0.6]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

## Add external force between unsprung mass and ground (represents ground motion)
item=actuator("z_0")
item.body[1]="unsprung"
item.body[2]="ground"
item.gain=kt
item.location[1]=[0.05,0,0.3]
item.location[2]=[0.05,0,0]
push!(the_system.item,item)

## Add measure between ground and sprung mass
item=sensor("z_1")
item.body[1]="sprung"
item.body[2]="ground"
item.location[1]=[0,0.05,0.6]
item.location[2]=[0,0.05,0]
push!(the_system.item,item)

## Add measure between sprung mass and unsprung mass
item=sensor("z_1-z_2")
item.body[1]="unsprung"
item.body[2]="sprung"
item.location[1]=[0.1,0,0.3]
item.location[2]=[0.1,0,0.6]
push!(the_system.item,item)

## Add measure between ground and unsprung mass
item=sensor("z_2-z_0")
item.body[1]="unsprung"
item.body[2]="ground"
item.actuator="z_0"
item.location[1]=[0.1,0,0.3]
item.location[2]=[0.1,0,0]
push!(the_system.item,item)

the_system

end
