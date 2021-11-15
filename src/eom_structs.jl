mutable struct eom_data
    mass::Array{Float64,2}  ## mass matrix from bodies
    inertia::Array{Float64,2}  ## mass matrix from springs
    damping::Array{Float64,2}  ## damping matrix from dampers
    stiffness::Array{Float64,2}  ## stiffness matrix from springs
    tangent_stiffness::Array{Float64,2}  ## stiffness matrix from internal loads
    load_stiffness::Array{Float64,2}  ## stiffness matrix from external loads
    velocity::Array{Float64,2}  ## velocity matrix for kinematics differential equation
    momentum::Array{Float64,2}  ## momentum matrix that gets added to damping matrix
    constraint::Array{Float64,2}  ## holonomic constraint jacobian
    nh_constraint::Array{Float64,2}  ## nonholonomic constraint jacobian
    deflection::Array{Float64,2}   ## elactic deflections jacobian
    lambda::Vector{Float64}  ## lagrange multipliers, internal preloads
    static::Vector{Float64}  ## static deflection
    selection::Array{Float64,2}  ## indicator of which springs preload is known in advance
    spring_stiffness::Array{Float64,2}  ## all flexible item stiffnesses
    subset_spring_stiffness::Vector{Float64}  ## stiffnesses of springs with known preload
    left_jacobian::Array{Float64,2}
    right_jacobian::Array{Float64,2}
    force::Vector{Float64}  ## external forces
    preload::Vector{Float64}  ## all known and NaN preloads
    input::Array{Float64,2}
    input_rate::Array{Float64,2}
    output::Array{Float64,2}
    feedthrough::Array{Float64,2}
    M::Array{Float64,2}
    KC::Array{Float64,2}
    column::Vector{Int64}
end

eom_data() = eom_data(
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0),
    zeros(0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0),
    zeros(0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0, 0),
    zeros(0)
)

mutable struct mbd_system
    name::String
    vpt::Number
    item::Vector{Any}
    bodys::Vector{body}
    links::Vector{link}
    springs::Vector{spring}
    rigid_points::Vector{rigid_point}
    flex_points::Vector{flex_point}
    nh_points::Vector{nh_point}
    beams::Vector{beam}
    loads::Vector{load}
    sensors::Vector{sensor}
    actuators::Vector{actuator}
end

mbd_system(str::String = "Unnamed System") = mbd_system(
    str,
    0,
    Vector{Any}(undef, 0),
    Vector{body}(undef, 0),
    Vector{link}(undef, 0),
    Vector{spring}(undef, 0),
    Vector{rigid_point}(undef, 0),
    Vector{flex_point}(undef, 0),
    Vector{nh_point}(undef, 0),
    Vector{beam}(undef, 0),
    Vector{load}(undef, 0),
    Vector{sensor}(undef, 0),
    Vector{actuator}(undef, 0),
)

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

mutable struct analysis
    ss_eqns::Vector{ss_data}
    mode_vals::Vector{Vector{Complex{Float64}}}
    modes::Vector{Array{Complex{Float64},2}}
    e_val::Vector{Vector{Complex{Float64}}}
    omega_n::Vector{Vector{Float64}}
    zeta::Vector{Vector{Float64}}
    tau::Vector{Vector{Float64}}
    lambda::Vector{Vector{Float64}}
    w::Vector{Vector{Float64}}
    freq_resp::Vector{Vector{Array{Complex{Float64},2}}}
    mag::Vector{Vector{Array{Float64,2}}}
    phase::Vector{Vector{Array{Float64,2}}}
    ss_resp::Vector{Array{Float64,2}}
    centre::Vector{Array{Complex{Float64},2}}
    hsv::Vector{Vector{Float64}}
end

analysis(nvpts) = analysis(
fill(ss_data(), nvpts),
fill([], nvpts),
fill(zeros(0,0), nvpts),
fill([], nvpts),
fill([], nvpts),
fill([], nvpts),
fill([], nvpts),
fill([], nvpts),
fill([], nvpts),
fill([zeros(0,0)], nvpts),
fill([zeros(0,0)], nvpts),
fill([zeros(0,0)], nvpts),
fill(zeros(0,0), nvpts),
fill(zeros(0,0), nvpts),
fill([], nvpts),
)

function Base.show(io::IO, obj::analysis)
    println(io, "EoM analysis of length $(length(obj.ss_eqns)).")
end

(obj::analysis)() = (obj::analysis)(1)

function (obj::analysis)(idx::Int64)
    result(
        obj.ss_eqns[idx],
        obj.mode_vals[idx],
        obj.modes[idx],
        obj.e_val[idx],
        obj.omega_n[idx],
        obj.zeta[idx],
        obj.tau[idx],
        obj.lambda[idx],
        obj.w[idx],
        obj.freq_resp[idx],
        obj.mag[idx],
        obj.phase[idx],
        obj.ss_resp[idx],
        obj.centre[idx],
        obj.hsv[idx],
    )
end


function (obj::analysis)(idx::StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}})
    obj(collect(idx))
end

# function (obj::analysis)(idx::Vector{Float64})
#     obj.(idx)
# end

mutable struct result
    ss_eqns::ss_data
    mode_vals::Vector{Complex{Float64}}
    modes::Array{Complex{Float64},2}
    e_val::Vector{Complex{Float64}}
    omega_n::Vector{Float64}
    zeta::Vector{Float64}
    tau::Vector{Float64}
    lambda::Vector{Float64}
    w::Vector{Float64}
    freq_resp::Vector{Array{Complex{Float64},2}}
    mag::Vector{Array{Float64,2}}
    phase::Vector{Array{Float64,2}}
    ss_resp::Array{Float64,2}
    centre::Array{Complex{Float64},2}
    hsv::Vector{Float64}
end

function Base.show(io::IO, obj::result)
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

