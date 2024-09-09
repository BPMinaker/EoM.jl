function ltisim(
    ss::EoM.ss_data,
    u::Function,
    tspan::Tuple{Number, Number};
    x0 = zeros(size(ss.A, 2)),
    flag::Bool = false
)

    # Copyright (C) 2024, Bruce Minaker
    if typeof(u(x0, 0.)) != Vector{Float64} && typeof(u(x0, 0.)) != Vector{Int64}
        error("Input function must be a vector.")
    end

    (; A, B, C, D) = ss

    function eomtr(dx, x, p, t)
        dx .= A * x + B * u(x, t)
        nothing
    end

    prob = ODEProblem(eomtr, x0, tspan)
    x = solve(prob, Tsit5())

    function y(t)
        C * x(t) + D * u(x(t), t)
    end

    y

end
