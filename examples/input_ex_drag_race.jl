function input_ex_drag_race(;re=0.3,a=1.2,b=1.4,h_G=0.5,kf=35000,kr=45000,cf=1500,cr=1500,m=1400,I=m*a*b)
the_system=mbd_system("Drag Race Model")

## Copyright (C) 2019, Bruce Minaker


# add one body representing the chassis
item=body("chassis")
item.mass=m
item.moments_of_inertia=[0,I,0] # only the Iy term matters here
item.location=[0,0,h_G]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=flex_point("front spring")
item.body[1]="chassis"
item.body[2]="ground"
item.location=[a,0,re] # front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1] # spring acts in z direction
item.stiffness=[kf,0] # linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cf,0]
push!(the_system.item,item)

item=flex_point("rear spring")
item.body[1]="chassis"
item.body[2]="ground"
item.location=[-b,0,re] # front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1] # spring acts in z direction
item.stiffness=[kr,0] # linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cr,0]
push!(the_system.item,item)

# other constraints
item=rigid_point("chassis planar")
item.body[1]="chassis"
item.body[2]="ground"
item.location=[0,0,h_G]
item.forces=1
item.moments=2
item.axis=[0,1,0]
push!(the_system.item,item)

# outputs
item=sensor("x_G")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,h_G]
item.location[2]=[-0.1,0,h_G]
push!(the_system.item,item)

item=sensor("u_G")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,h_G]
item.location[2]=[-0.1,0,h_G]
item.order=2
push!(the_system.item,item)

item=sensor("Zs_r")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[-b,0,re]
item.location[2]=[-b,0,0]
item.gain=kr
push!(the_system.item,item)

item=sensor("Zd_r")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[-b,0,re]
item.location[2]=[-b,0,0]
item.gain=cr
item.order=2
push!(the_system.item,item)

# inputs
item=actuator("X_a")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,h_G]
item.location[2]=[0.1,0,h_G]
push!(the_system.item,item)

item=actuator("X_t")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[-b,0,0]
item.location[2]=[-b-0.1,0,0]
push!(the_system.item,item)

the_system

end
