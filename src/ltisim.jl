function ltisim(
    ss::EoM.ss_data,
    u::Function,
    tspan::Tuple{Number, Number};
    x0 = zeros(size(ss.A, 2)),
    flag::Bool = false
)
    ltisim(ss, u, range(tspan[1], tspan[2], length=1001), x0, flag)
end

function ltisim(
    ss::EoM.ss_data,
    u::Function,
    tspan::StepRangeLen{Float64, Base.TwicePrecision{Float64}, Base.TwicePrecision{Float64}},
    x0 = zeros(size(ss.A, 2)),
    flag::Bool = false
)

    # Copyright (C) 2024, Bruce Minaker
    if typeof(u(x0, 0.)) != Vector{Float64} && typeof(u(x0, 0.)) != Vector{Int64}
        error("Input function must be a vector.")
    end

    (; A, B, C, D) = ss

    LTI = SplitFunction(MatrixOperator(A), (dx, x, p, t) -> dx .= B * u(x, t))
    prob = SplitODEProblem(LTI, x0, (tspan[1], tspan[end]))
    x = solve(prob, ETDRK4(); dt=tspan[2]-tspan[1])

    function y(t)
        C * x(t) + D * u(x(t), t)
    end

    function uu(t)
        u(x(t), t)
    end

    lti_soln(y, uu, tspan)

end

function ltiplot(obj::lti_soln, data::Union{Matrix{Float64}, Vector{Float64}}=zeros(length(obj.t), 0); yidx::Union{Vector{Int}, StepRange{Int, Int}, Colon}=:, uidx::Union{Vector{Int}, StepRange{Int, Int}, Colon}=:, label::Array{String}=String[], xlabel::String = "Time [s]",ylabel::String, title::String=  "EoM " * Dates.format(now(), "yyyy-mm-dd"),titlefontsize::Int=7, titlelocation::Symbol=:left, lw::Int=2, size::Tuple{Int, Int}=(800, 400)) 

    if yidx == [0]
        yidx = []
    end

    if uidx == [0]
        uidx = []
    end

    plot(obj.t, [hcat(obj.y.(obj.t)...)'[:, yidx] hcat(obj.u.(obj.t)...)'[:, uidx] data]; xlabel, ylabel, label, title, titlefontsize, titlelocation, lw, size)
end

function ltilabels(the_system::mbd_system; yidx::Union{Vector{Int}, StepRange{Int, Int}, Colon}=:, uidx::Union{Vector{Int}, StepRange{Int, Int}, Colon}=:)

    if yidx != [0]
        onames = getproperty.(the_system.sensors[yidx], :name)
        ounits = uparse.(getproperty.(the_system.sensors[yidx], :units))
        odesc = getproperty.(the_system.sensors[yidx], :desc)
    else
        onames = String[]
        ounits = String[]
        odesc = String[]
    end

    if uidx != [0]
        inames = getproperty.(the_system.actuators[uidx], :name)
        iunits = uparse.(getproperty.(the_system.actuators[uidx], :units))
        idesc = getproperty.(the_system.actuators[uidx], :desc)
    else
        inames = String[]
        iunits = String[]
        idesc = String[]
    end

    label = reshape([odesc .* " " .* onames; idesc .* " " .* inames], 1, :)
    ylabel = join([onames .* " [" .* ["$i" for i in ounits] .* "]"; inames .* " [" .* ["$i" for i in iunits] .* "]"], ", ")

    label, ylabel
end


#=
    function eomtr(dx, x, p, t)
        dx .= A * x + B * u(x, t)
        nothing
    end

    prob = ODEProblem(eomtr, x0, tspan)
    x = solve(prob, Tsit5())
=#


