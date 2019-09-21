function input_ex_bicycle_rider(;u=0.1)
the_system=mbd_system("Rigid Rider Bicycle")

## Copyright (C) 2017, Bruce Minaker
## input_ex_bicycle_rider.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_bicycle_rider.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

##  This is the benchmark bicycle problem that has been well studied in the literature
##  Meijaard, J.P., Papadopoulos, J.M., Ruina, A., Schwab, A.L., linearised dynamics equations for the balance and steer of a bicycle: a benchmark and review, Proc. Roy. Soc. A., Volume 463, Number 2084, 2007

g=-9.81
rake=pi/10

item=body("frame")
item.mass=85
item.moments_of_inertia=[9.2,11,2.8]
item.products_of_inertia=[0,0,-2.4]
item.location=[0.3,0,-0.9]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

item=body("fork")  ## The front fork, same velocities as the frame
item.mass=4
item.moments_of_inertia=[0.05892,0.06,0.00708]
item.products_of_inertia=[0,0,0.00756]
item.location=[0.9,0,-0.7]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

item=body("front-wheel")  ## The front-wheel, with non-zero angular velocity
item.mass=3
item.moments_of_inertia=[0.1405,0.28,0.1405]
item.products_of_inertia=[0,0,0]
item.location=[1.02,0,-0.35]
item.velocity=[u,0,0]
item.angular_velocity=[0,-u/0.35,0]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

item=body("rear-wheel")  ## The rear-wheel, also with non-zero angular velocity
item.mass=2
item.moments_of_inertia=[0.0603,0.12,0.0603]
item.products_of_inertia=[0,0,0]
item.location=[0,0,-0.3]
item.velocity=[u,0,0]
item.angular_velocity=[0,-u/0.3,0]
push!(the_system.item,item)
push!(the_system.item,weight(item,g))

item=rigid_point("head")   ;  ## The steering head bearing, connects the frame and fork
item.body[1]="frame"
item.body[2]="fork"
item.location=[1.1-0.8*sin(rake),0,-0.8*cos(rake)]
item.forces=3
item.moments=2
item.axis=[sin(rake),0,cos(rake)]
push!(the_system.item,item)

item=rigid_point("rear axle")  ## Rear axle rigid item
item.body[1]="frame"
item.body[2]="rear-wheel"
item.location=[0,0,-0.3]
item.forces=3
item.moments=2
item.axis=[0,1,0]
push!(the_system.item,item)

item=rigid_point("front axle")  ## Front axle rigid item
item.body[1]="fork"
item.body[2]="front-wheel"
item.location=[1.02,0,-0.35]
item.forces=3
item.moments=2
item.axis=[0,1,0]
push!(the_system.item,item)

item=rigid_point("rear road")  ## Rear wheel touches the ground - holonomic constraint in vertical and longitudinal
item.body[1]="rear-wheel"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=2
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)

item=rigid_point("front road")  ## Front wheel touches the ground - holonomic constraint in vertical and longitudinal
item.body[1]="front-wheel"
item.body[2]="ground"
item.location=[1.02,0,0]
item.forces=2
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)

item=nh_point("front tire")  ## Front wheel touches the ground - nonholonomic constraint in lateral (i.e. displacement ok, but not slip)
item.body[1]="front-wheel"
item.body[2]="ground"
item.location=[1.02,0,0]
item.forces=1
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)

item=nh_point("rear tire")  ## Rear wheel touches the ground - nonholonomic constraint in lateral (i.e. displacement ok, but not slip)
item.body[1]="rear-wheel"
item.body[2]="ground"
item.location=[0,0,0]
item.forces=1
item.moments=0
item.axis=[0,1,0]
push!(the_system.item,item)

## Constrain the speed to constant,
item=rigid_point("speed")  ## This could be nonholonomic also, I suppose, but that would just give another zero root
item.body[1]="frame"
item.body[2]="ground"
item.location=[0.3,0,-0.9]
item.forces=1
item.moments=0
item.axis=[1,0,0]
push!(the_system.item,item)


item=sensor("\$\\phi\$")   ## Roll angle sensor
item.body[1]="frame"
item.body[2]="ground"
item.location[1]=[0.3,0,-0.9]
item.location[2]=[0.1,0,-0.9]
item.twist=1
push!(the_system.item,item)

location1=[1.1-0.8*sin(rake),0,-0.8*cos(rake)]
location2=location1+0.25*[sin(rake),0,cos(rake)]

item=sensor("\$\\delta\$")
item.body[1]="frame"
item.body[2]="fork"
item.location[1]=location1
item.location[2]=location2
item.twist=1
push!(the_system.item,item)

item=actuator("\$m_{\\delta}\$")  ## The steer torque is the input
item.body[1]="frame"
item.body[2]="fork"
item.location[1]=location1
item.location[2]=location2
item.twist=1
push!(the_system.item,item)

# item=sensor("\$\\psi\$")   ## Yaw angle sensor
# item.body[1]="frame"
# item.body[2]="ground"
# item.location[1]=[0.3,0,-0.9]
# item.location[2]=[0.3,0,-0.7]
# item.twist=1
# push!(the_system.item,item)

the_system

end
