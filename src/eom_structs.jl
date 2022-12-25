Base.@kwdef mutable struct eom_data
    mass::Array{Float64,2} =  zeros(0, 0) ## mass matrix from bodies
    inertia::Array{Float64,2} =  zeros(0, 0) ## mass matrix from springs
    damping::Array{Float64,2} =  zeros(0, 0) ## damping matrix from dampers
    stiffness::Array{Float64,2} =  zeros(0, 0) ## stiffness matrix from springs
    tangent_stiffness::Array{Float64,2} = zeros(0, 0) ## stiffness matrix from internal loads
    load_stiffness::Array{Float64,2} = zeros(0, 0) ## stiffness matrix from external loads
    velocity::Array{Float64,2} = zeros(0, 0) ## velocity matrix for kinematics differential equation
    momentum::Array{Float64,2} = zeros(0, 0) ## momentum matrix that gets added to damping matrix
    constraint::Array{Float64,2} = zeros(0, 0) ## holonomic constraint jacobian
    nh_constraint::Array{Float64,2} = zeros(0, 0) ## nonholonomic constraint jacobian
    deflection::Array{Float64,2} = zeros(0, 0) ## elactic deflections jacobian
    lambda::Vector{Float64} = zeros(0)  ## lagrange multipliers, internal preloads
    static::Vector{Float64} = zeros(0)  ## static deflection
    selection::Array{Float64,2} = zeros(0, 0) ## indicator of which springs preload is known in advance
    spring_stiffness::Array{Float64,2} = zeros(0, 0)  ## all flexible item stiffnesses
    subset_spring_stiffness::Vector{Float64} = zeros(0) ## stiffnesses of springs with known preload
    left_jacobian::Array{Float64,2} = zeros(0, 0)
    right_jacobian::Array{Float64,2} = zeros(0, 0)
    force::Vector{Float64} = zeros(0) ## external forces
    preload::Vector{Float64} = zeros(0) ## all known and NaN preloads
    input::Array{Float64,2} = zeros(0, 0)
    input_rate::Array{Float64,2} = zeros(0, 0)
    output::Array{Float64,2} = zeros(0, 0)
    feedthrough::Array{Float64,2} = zeros(0, 0)
    M::Array{Float64,2} = zeros(0, 0)
    KC::Array{Float64,2} = zeros(0, 0)
    column::Vector{Int64} = zeros(0)
end

Base.@kwdef mutable struct mbd_system
    name::String = "Unnamed System"
    vpt::Number = 0
    item::Vector{Any} = Vector{Any}(undef, 0)
    bodys::Vector{body} = Vector{body}(undef, 0)
    links::Vector{link} = Vector{link}(undef, 0)
    springs::Vector{spring} = Vector{spring}(undef, 0)
    rigid_points::Vector{rigid_point} = Vector{rigid_point}(undef, 0)
    flex_points::Vector{flex_point} = Vector{flex_point}(undef, 0)
    nh_points::Vector{nh_point} = Vector{nh_point}(undef, 0)
    beams::Vector{beam} = Vector{beam}(undef, 0)
    loads::Vector{load} = Vector{load}(undef, 0)
    sensors::Vector{sensor} = Vector{sensor}(undef, 0)
    actuators::Vector{actuator} = Vector{actuator}(undef, 0)
end

mbd_system(str::String) = mbd_system(; name = str)

function Base.show(io::IO, obj::mbd_system)
    println(io, "Multibody dynamic system:")
    println(io, "Name: ", obj.name)
    println(io, "Number of items: ", length(obj.item))
    println(io, "vpt: ", obj.vpt)
end

function add_item!(item::Union{body, link, spring, rigid_point, flex_point, nh_point, beam, load, sensor, actuator}, obj::mbd_system)
    item_init!(item)
    push!(obj.item, item)
end

function sort_items!(item::body, the_system::mbd_system)
    push!(the_system.bodys, item)
end

function sort_items!(item::link, the_system::mbd_system)
    push!(the_system.links, item)
end

function sort_items!(item::spring, the_system::mbd_system)
    push!(the_system.springs, item)
end

function sort_items!(item::rigid_point, the_system::mbd_system)
    push!(the_system.rigid_points, item)
end

function sort_items!(item::flex_point, the_system::mbd_system)
    push!(the_system.flex_points, item)
end

function sort_items!(item::nh_point, the_system::mbd_system)
    push!(the_system.nh_points, item)
end

function sort_items!(item::beam, the_system::mbd_system)
    push!(the_system.beams, item)
end

function sort_items!(item::load, the_system::mbd_system)
    push!(the_system.loads, item)
end

function sort_items!(item::sensor, the_system::mbd_system)
    push!(the_system.sensors, item)
end

function sort_items!(item::actuator, the_system::mbd_system)
    push!(the_system.actuators, item)
end

struct dss_data
    A::Array{Float64,2}
    B::Array{Float64,2}
    C::Array{Float64,2}
    D::Array{Float64,2}
    E::Array{Float64,2}
    phys::Array{Float64,2}
end

function Base.show(io::IO, obj::dss_data)
    println(io, "Descriptor state space")
    println(io, "A:")
    show(io, "text/plain", obj.A)
    println(io)
    println(io, "B:")
    show(io, "text/plain", obj.B)
    println(io)
    println(io, "C:")
    show(io, "text/plain", obj.C)
    println(io)
    println(io, "D:")
    show(io, "text/plain", obj.D)
    println(io)
    println(io, "E:")
    show(io, "text/plain", obj.E)
    println(io)
end

struct ss_data
    A::Array{Float64,2}
    B::Array{Float64,2}
    C::Array{Float64,2}
    D::Array{Float64,2}
end

function Base.show(io::IO, obj::ss_data)
    println(io, "State space")
    println(io, "A:")
    show(io, "text/plain", obj.A)
    println(io)
    println(io, "B:")
    show(io, "text/plain", obj.B)
    println(io)
    println(io, "C:")
    show(io, "text/plain", obj.C)
    println(io)
    println(io, "D:")
    show(io, "text/plain", obj.D)
    println(io)
end

ss_data() = ss_data(zeros(0, 0), zeros(0, 0), zeros(0, 0), zeros(0, 0))

Base.@kwdef mutable struct analysis
    ss_eqns::ss_data = ss_data()
    mode_vals::Vector{Complex{Float64}} = zeros(0)
    modes::Array{Complex{Float64},2} = zeros(0,0) * 1im
    e_val::Vector{Complex{Float64}} = zeros(0)
    omega_n::Vector{Float64} = zeros(0)
    zeta::Vector{Float64} = zeros(0)
    tau::Vector{Float64} = zeros(0)
    lambda::Vector{Float64} = zeros(0)
    w::Vector{Float64} = zeros(0)
    freq_resp::Vector{Array{Complex{Float64},2}} = [zeros(0,0) * 1im]
    mag::Vector{Array{Float64,2}} = [zeros(0,0)]
    phase::Vector{Array{Float64,2}} = [zeros(0,0)]
    ss_resp::Array{Float64,2} = zeros(0,0)
    centre::Array{Complex{Float64},2} = zeros(0,0) * 1im
    hsv::Vector{Float64} = zeros(0)
end

function Base.show(io::IO, obj::analysis)
    println(io, "Analysis result: ")
    println(io, "Natural frequencies [Hz]:")
    show(io, "text/plain", my_round.(obj.omega_n))
    println()
    println(io, "Damping ratios:")
    show(io, "text/plain", my_round.(obj.zeta))
    println()
    println(io, "Time constants [s]:")
    show(io, "text/plain", my_round.(obj.tau))
    println()
    println(io, "Wavelengths [s]:")
    show(io, "text/plain", my_round.(obj.lambda))
    println()
    println(io, "Steady state gains []:")
    show(io, "text/plain", my_round.(obj.ss_resp))
    println()
end
