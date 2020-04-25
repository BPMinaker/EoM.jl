function input_ex_drag_race(;re=0.3,a=1.2,b=1.4,h_G=0.5,kf=35000,kr=45000,cf=1500,cr=1500,m=1400,I=m*a*b,kt=150000)
the_system=mbd_system("Drag Race Model")

## Copyright (C) 2019, Bruce Minaker

item=spring("rear spring")
item.body[1]="chassis"
item.body[2]="axle"
item.location[1]=[-b-0.1,0,re+0.4]
item.location[2]=[-b-0.1,0,re]
item.stiffness=kr
item.damping=cr
push!(the_system.item,item)

item=link("lower link")
item.body[1]="chassis"
item.body[2]="axle"
item.location[1]=[-b+0.5,0,re-0.1]
item.location[2]=[-b,0,re-0.1]
push!(the_system.item,item)

item=link("upper link")
item.body[1]="chassis"
item.body[2]="axle"
item.location[1]=[-b+0.5,0,re+0.20]
item.location[2]=[-b,0,re+0.20]
push!(the_system.item,item)

# add one body representing the chassis
item=body("chassis")
item.mass=m
item.moments_of_inertia=[0,I,0] # only the Iy term matters here
item.location=[0,0,h_G]
push!(the_system.item,item)
push!(the_system.item,weight(item))

# front suspension
item=body("front unsprung")
item.mass=25
item.moments_of_inertia=[0,0,0]
item.location=[a,0,re]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=flex_point("front spring")
item.body[1]="chassis"
item.body[2]="front unsprung"
item.location=[a,0,re] # front axle "a" m ahead of cg
item.forces=1
item.moments=0
item.axis=[0,0,1] # spring acts in z direction
item.stiffness=[kf,0] # linear stiffness "kf" N/m; (torsional stiffness zero, not a torsion spring so has no effect
item.damping=[cf,0]
push!(the_system.item,item)

item=rigid_point("front susp")
item.body[1]="chassis"
item.body[2]="front unsprung"
item.location=[a,0,re]
item.forces=2
item.moments=3
item.axis=[0,0,1]
push!(the_system.item,item)

item=flex_point("front tire")
item.body[1]="front unsprung"
item.body[2]="ground"
item.location=[a,0,0]
item.forces=1
item.moments=0
item.axis=[0,0,1]
item.stiffness=[kt,0]
push!(the_system.item,item)

# rear suspension
item=body("axle")
item.mass=25
item.moments_of_inertia=[0,5,0]
item.location=[-b,0,re]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=body("wheel")
item.mass=25
item.moments_of_inertia=[0,1,0]
item.location=[-b,0,re]
push!(the_system.item,item)
push!(the_system.item,weight(item))

item=rigid_point("wheel bearing")
item.body[1]="wheel"
item.body[2]="axle"
item.location=[-b,0,re]
item.forces=3
item.moments=2
item.axis=[0,1,0]
push!(the_system.item,item)

item=flex_point("rear tire")
item.body[1]="wheel"
item.body[2]="ground"
item.location=[-b,0,0]
item.forces=1
item.moments=0
item.axis=[0,0,1]
item.rolling_axis=[0,1,0]
item.stiffness=[150000,0]
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

item=rigid_point("axle planar")
item.body[1]="axle"
item.body[2]="ground"
item.location=[-b,0,re]
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

item=sensor("u_w")
item.body[1]="wheel"
item.body[2]="ground"
item.location[1]=[-b,0,re]
item.location[2]=[-b-0.1,0,re]
item.order=2
push!(the_system.item,item)

item=sensor("Z_r")
item.body[1]="wheel"
item.body[2]="ground"
item.location[1]=[-b,0,re]
item.location[2]=[-b,0,0]
item.gain=-kt
push!(the_system.item,item)

item=sensor("Z_f")
item.body[1]="front unsprung"
item.body[2]="ground"
item.location[1]=[a,0,re]
item.location[2]=[a,0,0]
item.gain=-kt
push!(the_system.item,item)

item=sensor("ω_w")
item.body[1]="wheel"
item.body[2]="ground"
item.location[1]=[-b,0,re]
item.location[2]=[-b,-0.1,re]
item.twist=1
push!(the_system.item,item)

item=sensor("z_f")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[a,0,h_G]
item.location[2]=[a,0,0]
push!(the_system.item,item)

item=sensor("z_r")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[-b,0,h_G]
item.location[2]=[-b,0,0]
push!(the_system.item,item)

item=sensor("z_r-z_w")
item.body[1]="chassis"
item.body[2]="wheel"
item.location[1]=[-b,0,re+0.1]
item.location[2]=[-b,0,re]
push!(the_system.item,item)

# inputs
item=actuator("X_a")
item.body[1]="chassis"
item.body[2]="ground"
item.location[1]=[0,0,h_G]
item.location[2]=[0.1,0,h_G]
push!(the_system.item,item)

item=actuator("X_t")
item.body[1]="wheel"
item.body[2]="ground"
item.location[1]=[-b,0,0]
item.location[2]=[-b-0.1,0,0]
push!(the_system.item,item)

item=actuator("t_w")
item.body[1]="wheel"
item.body[2]="chassis"
item.location[1]=[-b,0,re]
item.location[2]=[-b,-0.1,re]
item.twist=1
push!(the_system.item,item)

the_system

end
