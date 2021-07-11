function input_ex_rotor(;r=1)

## Copyright (C) 2021, Bruce Minaker
## input_ex_rotor.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_rotor.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

##  Rotor stator model from D. Negrut and J.L. Ortiz, A practical approach for the linearisation of the constrained multibody dynamics equations, J. Comp. Nonlinear Dynam. 1 (2006), pp. 230–239.
the_system=mbd_system("Rotor and stator")

item=body("rotor")
item.mass=1300
item.moments_of_inertia=[500,500,1000]
item.products_of_inertia=[0,0,0]
item.location=[0,0,0.75]
item.velocity=[0,0,0]
item.angular_velocity=[0,0,r]
push!(the_system.item,item)

item=body("stator")
item.mass=200
item.moments_of_inertia=[50,50,10]
item.products_of_inertia=[0,0,0]
item.location=[0,0,0]
item.velocity=[0,0,0]
item.angular_velocity=[0,0,0]
push!(the_system.item,item)

item=rigid_point("bearing")
item.body[1]="rotor"
item.body[2]="stator"
item.location=[0,0,0]
item.forces=3
item.moments=2
item.axis=[0,0,1]
push!(the_system.item,item)

item=flex_point("bushing")
item.body[1]="stator"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=3
item.moments=2
item.axis=[0,0,1]
item.stiffness=[1000,10000]
item.damping=[1,10]
push!(the_system.item,item)

item=flex_point("bushing")
item.body[1]="stator"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=0
item.moments=1
item.axis=[0,0,1]
item.stiffness=[0,100000]
item.damping=[0,100]
push!(the_system.item,item)

# Add some inputs and outputs
item=sensor("kx")
item.body[1]="rotor"
item.body[2]="ground";
item.location[1]=[0,0,0]
item.location[2]=[0.1,0,0]
item.gain=1000
push!(the_system.item,item)

item=sensor("ky")
item.body[1]="rotor"
item.body[2]="ground";
item.location[1]=[0,0,0]
item.location[2]=[0,0.1,0]
item.gain=1000
push!(the_system.item,item)

item=sensor("kz")
item.body[1]="rotor"
item.body[2]="ground";
item.location[1]=[0,0,0]
item.location[2]=[0,0,0.1]
item.gain=1000
push!(the_system.item,item)

item=actuator("X")
item.body[1]="rotor"
item.body[2]="ground"
item.location[1]=[0,0,0]
item.location[2]=[0.1,0,0]
push!(the_system.item,item)

item=actuator("Z")
item.body[1]="rotor"
item.body[2]="ground"
item.location[1]=[0,0,0]
item.location[2]=[0,0,0.1]
push!(the_system.item,item)



the_system

end
