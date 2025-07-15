function ltisim(result::analysis, u::Function, tspan::Tuple{Number,Number}, x0=zeros(size(result.ss_eqns.A, 1)); flag::Bool=false)

    if typeof(u(x0, 0.0)) != Vector{Float64} && typeof(u(x0, 0.0)) != Vector{Int64}
        error("Input function must be a vector.")
    end

    (; A, B, C, D) = discrete(result, 0.001)
    t = tspan[1]:0.001:tspan[2]

    nin = size(B, 2)
    nout = size(C, 1)
    n = size(A, 1)

    xi = [zeros(n) for i in t]
    xi[1] = x0

    y = [zeros(nout) for i in t]
    uu = [zeros(nin) for i in t]

    for i in 1:length(t)-1
        uu[i] = u(xi[i], t[i])
        y[i] = C * xi[i] + D * uu[i]
        xi[i+1] = A * xi[i] + B * uu[i]
    end

    uu[end] = u(xi[end], t[end])
    y[end] = C * xi[end] + D * uu[end]

    lti_soln(y, uu, t)

end

function ltiplot(
    the_system::mbd_system,
    obj::lti_soln,
    data::Union{Matrix{Float64},Vector{Float64}}=zeros(length(obj.t), 0),
    t::Union{Vector{Float64},StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64},Int64}}=obj.t;
    yidx::Union{Vector{Int},StepRange{Int,Int},Colon}=:,
    uidx::Union{Vector{Int},StepRange{Int,Int},Colon}=:,
    label::Union{Array{String},Nothing}=nothing,
    xlabel::String="Time [s]",
    ylabel::Union{String,Nothing}=nothing,
    title::String="EoM " * Dates.format(now(), "yyyy-mm-dd"),
    titlefontsize::Int=7,
    titlelocation::Symbol=:left,
    lw::Int=2,
    size::Tuple{Int,Int}=(800, 400),
    scale::Int=0,
    kwargs...)

    if yidx != [0]
        onames = getproperty.(the_system.sensors[yidx], :name)
        ounits = uparse.(getproperty.(the_system.sensors[yidx], :units))
        odesc = getproperty.(the_system.sensors[yidx], :desc)
    else
        onames = String[]
        ounits = String[]
        odesc = String[]
        yidx = []
    end

    if uidx != [0]
        inames = getproperty.(the_system.actuators[uidx], :name)
        iunits = uparse.(getproperty.(the_system.actuators[uidx], :units))
        idesc = getproperty.(the_system.actuators[uidx], :desc)
    else
        inames = String[]
        iunits = String[]
        idesc = String[]
        uidx = []
    end

    if isnothing(label)
        label = reshape([odesc .* " " .* onames; idesc .* " " .* inames], 1, :)
    else
        label = [reshape([odesc .* " " .* onames; idesc .* " " .* inames], 1, :) label]
    end
    if isnothing(ylabel)
        ylabel = join([onames .* " [" .* ["$i" for i in ounits] .* "]"; inames .* " [" .* ["$i" for i in iunits] .* "]"], ", ")
    elseif ylabel[1] == ','
        ylabel = join([onames .* " [" .* ["$i" for i in ounits] .* "]"; inames .* " [" .* ["$i" for i in iunits] .* "]"], ", ") * ylabel
    end

    if scale == 0
        scale = Int(round(length(t) / 2000))
    end
    scale < 1 && (scale = 1)

    plot(t[1:scale:end], [hcat(obj.y...)'[1:scale:end, yidx] hcat(obj.u...)'[1:scale:end, uidx] data[1:scale:end, :]]; xlabel, ylabel, label, title, titlefontsize, titlelocation, lw, size, kwargs...)

end


#    (; A, B, C, D) = ss

#    LTI = SplitFunction(MatrixOperator(A), (dx, x, p, t) -> dx .= B * u(x, t))
#    prob = SplitODEProblem(LTI, x0, (tspan[1], tspan[end]))
#    x = solve(prob, ETDRK4(); dt=tspan[2]-tspan[1])

# function eomtr(dx, x, p, t)
#     dx .= A * x + B * u(x, t)
#     nothing
# end
# prob = ODEProblem(eomtr, x0, tspan)
# x = solve(prob, Tsit5())
