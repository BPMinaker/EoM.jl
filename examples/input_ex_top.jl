function input_ex_top(;r=1,m=1e-2,h=4e-2,It=3e-4,Ia=4e-4,g=9.81)

## Copyright (C) 2017, Bruce Minaker
## input_ex_disk.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_disk.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

## The classic spinning top problem
## See the paper Stability analysis of rigid multibody mechanical systems with holonomic and nonholonomic constraints by M. Pappalardo et al, Arch Appl Mech (2020) 90:1961–2005

the_system=mbd_system("Spinning Top")

# Add the top
item=body("top")
item.mass=m
item.moments_of_inertia=[It,It,Ia]
item.products_of_inertia=[0,0,0]
item.location=[0,0,h]
item.velocity=[0,0,0]
item.angular_velocity=[0,0,r]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

# Add ground contact, vertical and longitudinal forces
item=rigid_point("contact")
item.body[1]="top"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=3
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)


# Add some inputs and outputs
item=sensor("mghϕ")
item.body[1]="top"
item.body[2]="ground";
item.location[1]=[0,0,h]
item.location[2]=[0.1,0,h]
item.twist=1
item.gain=m*g*h
push!(the_system.item,item)

item=sensor("mghθ")
item.body[1]="top"
item.body[2]="ground";
item.location[1]=[0,0,h]
item.location[2]=[0,0.1,h]
item.twist=1
item.gain=m*g*h
push!(the_system.item,item)

item=actuator("L")
item.body[1]="top"
item.body[2]="ground"
item.location[1]=[0,0,h]
item.location[2]=[0.1,0,h]
item.twist=1
push!(the_system.item,item)

item=actuator("M")
item.body[1]="top"
item.body[2]="ground"
item.location[1]=[0,0,h]
item.location[2]=[0,0.1,h]
item.twist=1
push!(the_system.item,item)

the_system

end
