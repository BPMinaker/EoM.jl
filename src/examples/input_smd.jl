function input_smd(m::Float64,c::Float64,k::Float64)
the_system=mbd_system("Spring Mass Damper")

## Add the body
item=body("block")
item.mass=m
item.moments_of_inertia=[0,0,0]
item.products_of_inertia=[0,0,0]
item.location=[0,0,1]
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
item.location[:,1]=[0.05,0,1]
item.location[:,2]=[0.05,0,0]
push!(the_system.item,item)


item=sensor("sensor 1")
item.body[1]="block"
item.body[2]="ground"
item.location[:,1]=[0,0.05,1]
item.location[:,2]=[0,0.05,0]
push!(the_system.item,item)

the_system

end
