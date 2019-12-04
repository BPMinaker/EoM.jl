function full_car_a_arm_pushrod(;u=10.0,a=1.2,b=1.3,cf=40000.0,cr=40000.0,m=1400.0,I=2200.0,r=0.3)

## Copyright (C) 2017, Bruce Minaker
## full_car_a_arm_pushrod.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## full_car_a_arm_pushrod.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

the_system=mbd_system("Full Car A-Arm Pushrod")

g=9.81
tw=1.5

item=body("Chassis")
item.mass=m
item.moments_of_inertia=[800.0,2000.0,2200.0]
item.products_of_inertia=[0.0,0.0,0.0]
item.location=[0.0,0.0,0.5]
item.velocity=[u,0.0,0.0]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

susp!(the_system,a=a,tw=tw,r=r,u=u,g=g,str="LF ",front=true)
tire!(the_system,a=a,tw=tw,cf=cf,u=u,g=g,str="LF ",front=true)

susp!(the_system,a=-b,tw=tw,r=r,u=u,g=g,str="LR ",front=false)
tire!(the_system,a=-b,tw=tw,cf=cr,u=u,g=g,str="LR ",front=false)

item=spring("Anti-roll bar")
item.body[1]="LF Anti-roll arm"
item.body[2]="RF Anti-roll arm"
item.location[1]=[a+0.05,0.25,r+0.05]
item.location[2]=[a+0.05,-0.25,r+0.05]
item.stiffness=100.0
item.damping=0.0
item.twist=1
push!(the_system.item,item)

####% Reflect all LF or LR items in y axis
mirror!(the_system)

## Add sensors
item=sensor("z_\\text{LFc}")
item.body[1]="Chassis"
item.body[2]="ground"
item.location[1]=[a,tw/2,r]
item.location[2]=[a,tw/2,r-0.1]
push!(the_system.item,item)

item=sensor("z_\\text{LFc}-z_\\text{LF}")
item.body[1]="Chassis"
item.body[2]="LF Wheel+hub"
item.location[1]=[a,tw/2,r]
item.location[2]=[a,tw/2,r-0.1]
push!(the_system.item,item)

item=sensor("z_\\text{LF}-u_\\text{LF}")
item.body[1]="LF Wheel+hub"
item.body[2]="ground"
item.location[1]=[a,tw/2,r]
item.location[2]=[a,tw/2,r-0.1]
item.actuator="u_\\text{LF }"
push!(the_system.item,item)


## roll centre constraints

# item=actuator("Z")
# item.body[1]="Chassis"
# item.body[2]="ground"
# item.location[1]=[0,0,0.5]
# item.location[2]=[0,0,0]
# push!(the_system.item,item)
# push!(the_system.item,item)
# push!(the_system.item,item)
# push!(the_system.item,item)
#
# item=rigid_point("LF RC")
# item.body[1]="LF Wheel+hub"
# item.body[2]="ground"
# item.location=[a,tw/2,0]
# item.forces=3
# item.moments=0
# push!(the_system.item,item)
#
# item=rigid_point("LR RC")
# item.body[1]="LR Wheel+hub"
# item.body[2]="ground"
# item.location=[-b,tw/2,0]
# item.forces=3
# item.moments=0
# push!(the_system.item,item)

the_system

end ## Leave
