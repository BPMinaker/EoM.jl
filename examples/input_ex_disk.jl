function input_ex_disk(;u=0.1,m=4,r=0.5)
the_system=mbd_system("Rolling Disk")

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

## The classic rolling disk problem
##  Schwab,A.L., Meijaard,J.P., Dynamics Of Flexible Multibody Systems With Non-Holonomic Constraints: A Finite Element Approach, Multibody System Dynamics 10: (2003) pp. 107-123

# vcrit=sqrt(gr/3)

## Add the wheel
item=body("wheel")
item.mass=m
item.moments_of_inertia=[0.25*m*r^2,0.5*m*r^2,0.25*m*r^2]
item.products_of_inertia=[0,0,0]
item.location=[0,0,r]
item.velocity=[u,0,0]
item.angular_velocity=[0,u/r,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

## Add ground contact, vertical and longitudinal forces
item=rigid_point("contact")
item.body[1]="wheel"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=2
item.moments=0
item.axis=[0,1,0]
item.rolling_axis=[0,1,0]
push!(the_system.item,item)

## Add ground contact, lateral
item=nh_point("rolling")
item.body[1]="wheel"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=1
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)

## Add some inputs and outputs
item=sensor("roll rate sensor")
item.body[1]="wheel"
item.body[2]="ground";
item.location[:,1]=[0,0,r]
item.location[:,2]=[0.1,0,r]
item.twist=1
item.order=2
push!(the_system.item,item)

item=sensor("yaw rate sensor")
item.body[1]="wheel"
item.body[2]="ground";
item.location[:,1]=[0,0,r]
item.location[:,2]=[0,0,0]
item.twist=1
item.order=2
push!(the_system.item,item)

item=actuator("yaw servo")
item.body[1]="wheel"
item.body[2]="ground"
item.location[:,1]=[0,0,r]
item.location[:,2]=[0,0,0]
item.twist=1
push!(the_system.item,item)

the_system

end
