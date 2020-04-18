function input_ex_full_car(;u=0,a=1.189,b=2.885-1.189,tf=1.595,tr=1.631,kf=17000,kr=19000,cf=1000,cr=1200,m=16975/9.81,Ix=818,Iy=3267,kt=180000,muf=35,mur=30)

## Copyright (C) 2017, Bruce Minaker
## input_ex_full_car.jl is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## input_ex_full_car.jl is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details at www.gnu.org/copyleft/gpl.html.
##
##--------------------------------------------------------------------

the_system=mbd_system("Full Car Model")

# add one body representing the chassis
item=body("chassis")
item.mass=m
item.moments_of_inertia=[Ix,Iy,0]  ## Only the Iy term matters here
item.products_of_inertia=[0,0,0]
item.location=[0,0,0.25]  ## Put cg at origin, but offset vertically to make animation more clear
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=body("left front unsprung")
item.mass=muf
item.location=[a,tf/2,0.1]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=body("right front unsprung")
item.mass=muf
item.location=[a,-tf/2,0.1]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=body("left rear unsprung")
item.mass=mur
item.location=[-b,tr/2,0.1]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=body("right rear unsprung")
item.mass=mur
item.location=[-b,-tr/2,0.1]
item.velocity=[u,0,0]
push!(the_system.item,item)
push!(the_system.item,weight(item))

# front suspension
item=flex_point("left front spring")
item.body[1]="chassis"
item.body[2]="left front unsprung"
item.location=[a,tf/2,0.25] # front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1] # spring acts in z direction
item.stiffness=[kf,0] # linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cf,0]
push!(the_system.item,item)

item=flex_point("right front spring")
item.body[1]="chassis"
item.body[2]="right front unsprung"
item.location=[a,-tf/2,0.25]  ## Front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1]  ## Spring acts in z direction
item.stiffness=[kf,0]  ## Linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cf,0]
push!(the_system.item,item)

# rear suspension
item=flex_point("left rear spring")
item.body[1]="chassis"
item.body[2]="left rear unsprung"
item.location=[-b,tr/2,0.25]  ## Front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1]  ## Spring acts in z direction
item.stiffness=[kr,0]  ## Linear stiffness "kr" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cr,0]
push!(the_system.item,item)

item=flex_point("right rear spring")
item.body[1]="chassis"
item.body[2]="right rear unsprung"
item.location=[-b,-tr/2,0.25]  ## Front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1]  # spring acts in z direction
item.stiffness=[kr,0]  # linear stiffness "kr" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cr,0]
push!(the_system.item,item)

# tires
item=flex_point("left front tire")
item.body[1]="left front unsprung"
item.body[2]="ground"
item.stiffness=[kt,0]
item.damping=[0,0]
item.location=[a,tf/2,0.15]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

item=flex_point("right front tire")
item.body[1]="right front unsprung"
item.body[2]="ground"
item.stiffness=[kt,0]
item.damping=[0,0]
item.location=[a,-tf/2,0.15]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

item=flex_point("left rear tire")
item.body[1]="left rear unsprung"
item.body[2]="ground"
item.stiffness=[kt,0]
item.damping=[0,0]
item.location=[-b,tr/2,0.15]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

item=flex_point("right rear tire")
item.body[1]="right rear unsprung"
item.body[2]="ground"
item.stiffness=[kt,0]
item.damping=[0,0]
item.location=[-b,-tr/2,0.15]
item.forces=1
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

# suspension constraints
item=rigid_point("left front susp")
item.body[1]="left front unsprung"
item.body[2]="chassis"
item.location=[a,tf/2,0.1]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

item=rigid_point("right front susp")
item.body[1]="right front unsprung"
item.body[2]="chassis"
item.location=[a,-tf/2,0.1]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

item=rigid_point("left rear susp")
item.body[1]="left rear unsprung"
item.body[2]="chassis"
item.location=[-b,tr/2,0.1]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

item=rigid_point("right rear susp")
item.body[1]="right rear unsprung"
item.body[2]="chassis"
item.location=[-b,-tr/2,0.1]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

# constrain to linear motion in z direction (bounce)
item=rigid_point("road frc")
item.body[1]="chassis"
item.body[2]="ground"
item.location=[0,0,0.25]
item.forces=2
item.moments=0
item.axis=[0,0,1]
push!(the_system.item,item)

# constrain to rotational motion around x and y axes (roll and pitch)
item=rigid_point("road mmt")
item.body[1]="chassis"
item.body[2]="ground"
item.location=[0,0,0.25]
item.forces=0
item.moments=1
item.axis=[0,0,1]
push!(the_system.item,item)

# force motion
item=actuator("u_lf")
item.body[1]="left front unsprung"
item.body[2]="ground"
item.location[1]=[a,tf/2,0.25]
item.location[2]=[a,tf/2,0]
item.gain=kt
push!(the_system.item,item)

# measure the bounce, pitch, and roll
item=sensor("z_G")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,0.25]
item.location[2]=[0,0,0]
push!(the_system.item,item)

item=sensor("θ(a+b)")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,0.25]
item.location[2]=[0,0.25,0.25]
item.gain=a+b
item.twist=1
push!(the_system.item,item)

item=sensor("ϕ(t_f)")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,0.25]
item.location[2]=[0.25,0,0.25]
item.gain=tf
item.twist=1
push!(the_system.item,item)

the_system

end
