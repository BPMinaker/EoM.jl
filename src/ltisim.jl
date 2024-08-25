function ltisim(
    ss::EoM.ss_data,
    u::Function,
    tspan::Tuple{Number, Number};
    x0 = zeros(size(ss.A, 2), 1),
    flag::Bool = false
)

    # Copyright (C) 2024, Bruce Minaker

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
