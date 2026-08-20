@kwdef mutable struct eom_data
    mass::Array{Float64,2} = zeros(0, 0) ## mass matrix from bodies
    inertia::Array{Float64,2} = zeros(0, 0) ## mass matrix from springs
    damping::Array{Float64,2} = zeros(0, 0) ## damping matrix from dampers
    stiffness::Array{Float64,2} = zeros(0, 0) ## stiffness matrix from springs
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

@kwdef mutable struct mbd_system
    name::String = "Unnamed System"
    vpt::Number = 0
    item::Vector{Union{body,link,spring,rigid_point,flex_point,nh_point,beam,load,sensor,actuator,wing}} = Vector{Union{body,link,spring,rigid_point,flex_point,nh_point,beam,load,sensor,actuator,wing}}(undef, 0)
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
    wings::Vector{wing} = Vector{wing}(undef, 0)
    bodys_name::Dict{String,body} = Dict{String,body}()
    links_name::Dict{String,link} = Dict{String,link}()
    springs_name::Dict{String,spring} = Dict{String,spring}()
    rigid_points_name::Dict{String,rigid_point} = Dict{String,rigid_point}()
    flex_points_name::Dict{String,flex_point} = Dict{String,flex_point}()
    nh_points_name::Dict{String,nh_point} = Dict{String,nh_point}()
    beams_name::Dict{String,beam} = Dict{String,beam}()
    loads_name::Dict{String,load} = Dict{String,load}()
    sensors_name::Dict{String,sensor} = Dict{String,sensor}()
    actuators_name::Dict{String,actuator} = Dict{String,actuator}()
    wings_name::Dict{String,wing} = Dict{String,wing}()
    bidx::Dict{String,Int} = Dict{String,Int}()
    aidx::Dict{String,Int} = Dict{String,Int}()
    sidx::Dict{String,Int} = Dict{String,Int}()
    scratch::Any = 0
end

mbd_system(str::String) = mbd_system(; name=str)

function (system::mbd_system)(dict::Symbol, idx::Vector{String})
    get.([getproperty(system, dict)], idx, 0)
end

function Base.show(io::IO, obj::mbd_system)
    println(io, "Multibody dynamic system:")
    println(io, "Name: ", obj.name)
    println(io, "Number of items: ", length(obj.item))
    println(io, "vpt: ", obj.vpt)
end

function add_item!(item::Union{body,link,spring,rigid_point,flex_point,nh_point,beam,load,sensor,actuator,wing}, obj::mbd_system)
    item_init!(item)
    push!(obj.item, item)
end

mutable struct system_data
    name::String
    aidx::Dict{String,Int}
    sidx::Dict{String,Int}
    adesc::Vector{String}
    sdesc::Vector{String}
    aunits::Vector{Unitful.Units}
    sunits::Vector{Unitful.Units}
    anames::Vector{String}
    snames::Vector{String}
end

system_data() = system_data(
    "",
    Dict{String,Int}(),
    Dict{String,Int}(),
    [""],
    [""],
    Vector{Unitful.Units}([]),
    Vector{Unitful.Units}([]),
    [""],
    [""]
)

system_data(system::mbd_system) = system_data(
    system.name,
    system.aidx,
    system.sidx,
    getproperty.(system.actuators, :desc),
    getproperty.(system.sensors, :desc),
    uparse.(getproperty.(system.actuators, :units)),
    uparse.(getproperty.(system.sensors, :units)),
    getproperty.(system.actuators, :name),
    getproperty.(system.sensors, :name)
)

struct dss_data
    A::Array{Float64,2}
    B::Array{Float64,2}
    C::Array{Float64,2}
    D::Array{Float64,2}
    E::Array{Float64,2}
    phys::Array{Float64,2}
    sys_data::system_data
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

@kwdef struct response_data
    time::Vector{Float64} = zeros(0)
    response::Array{Vector{Float64},2} = [zeros(0) for i in 1:0, j in 1:0]
end

@kwdef mutable struct analysis
    ss_eqns::DescriptorStateSpace{T} where T = dss(zeros(5)...)
    mode_vals::Vector{Complex{Float64}} = zeros(0)
    modes::Array{Complex{Float64},2} = zeros(0, 0) * 1im
    e_val::Vector{Complex{Float64}} = zeros(0)
    omega_n::Vector{Float64} = zeros(0)
    zeta::Vector{Float64} = zeros(0)
    tau::Vector{Float64} = zeros(0)
    lambda::Vector{Float64} = zeros(0)
    t_zero::Vector{Complex{Float64}} = zeros(0)
    t_zero_f::Vector{Float64} = zeros(0)
    w::Vector{Float64} = zeros(0)
    freq_resp::Vector{Array{Complex{Float64},2}} = [zeros(0, 0) * 1im]
    mag::Vector{Array{Float64,2}} = [zeros(0, 0)]
    phase::Vector{Array{Float64,2}} = [zeros(0, 0)]
    ss_resp::Array{Float64,2} = zeros(0, 0)
    centre::Array{Complex{Float64},2} = zeros(0, 0) * 1im
    hsv::Vector{Float64} = zeros(0)
    impulse_resp::response_data = response_data()
    step_resp::response_data = response_data()
    ss::Union{Symbol,Matrix,Vector} = :default
    bode::Union{Symbol,Matrix,Vector} = :default
    impulse::Union{Symbol,Matrix,Vector} = :default
    sys_data::system_data = system_data()
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

struct lti_soln
    y::Vector{Vector{Float64}}
    u::Vector{Vector{Float64}}
    t::Union{Vector{Float64},StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}}
    sys_data::system_data
end

function Base.getindex(obj::lti_soln, idx::Union{Int,Vector{Int},StepRange{Int,Int},UnitRange{Int}}, ::Colon)
    hcat(obj.y...)[idx, :]
end

function Base.getindex(obj::lti_soln, ::Colon, ::Colon)
    hcat(obj.y...)
end

function Base.getindex(obj::lti_soln, idx::Union{Int,Vector{Int},StepRange{Int,Int},UnitRange{Int}})
    hcat(obj.y...)'[:, idx]
end

function Base.show(io::IO, obj::lti_soln)
    println(io, "LTI solution")
    println(io, "t:")
    show(io, "text/plain", collect(obj.t))
    println(io)
    println(io, "y:")
    show(io, "text/plain", obj.y)
    println(io)
    println(io, "u:")
    show(io, "text/plain", obj.u)
    println(io)
end
