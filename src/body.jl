export body
export name
export location
export weight

type body
	name::String
	group::String
	location::Vector{Float64}
	orientation::Vector{Float64}
	mass::Float64
	moments_of_inertia::Vector{Float64}
	products_of_inertia::Vector{Float64}
	velocity::Vector{Float64}
	angular_velocity::Vector{Float64}
	deflection::Vector{Float64}
	angular_deflection::Vector{Float64}

	function body(name,group="body",location=[0,0,0],orientation=[0,0,0],mass=0,moments_of_inertia=[0,0,0],products_of_inertia=[0,0,0],velocity=[0,0,0],angular_velocity=[0,0,0],deflection=[NaN,NaN,NaN],angular_deflection=[NaN,NaN,NaN])
		new(name,group,location,orientation,mass,moments_of_inertia,products_of_inertia,velocity,angular_velocity,deflection,angular_deflection)
	end
end

function name(obj::body)
	obj.name
end

function location(obj::body)
	obj.location
end

function inertia_mtx(obj::body)
	mtx=diagm(obj.moments_of_inertia)  ## Put inertia on diagonal
	mtx[1,2]=-obj.products_of_inertia[1]  ## Put -ve cross products in
	mtx[2,1]=-obj.products_of_inertia[1]
	mtx[2,3]=-obj.products_of_inertia[2]
	mtx[3,2]=-obj.products_of_inertia[2]
	mtx[1,3]=-obj.products_of_inertia[3]
	mtx[3,1]=-obj.products_of_inertia[3]
	mtx
end

function mass_mtx(obj::body)
	[obj.mass*eye(3) zeros(3,3); zeros(3,3) inertia_mtx(obj)]  ## Stack mass and inertia terms
end

function weight(obj::body,g=9.81)
	g*=[0,0,-1]
	item=load("$obj.name weight")
	item.body=obj.name
	item.location=obj.location
	item.force=obj.mass*g;
	item.moment=[0,0,0]
	item
end
