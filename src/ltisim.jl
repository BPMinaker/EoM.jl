function ltisim(result::analysis, u::Function, tspan::Tuple{Number,Number}, x0=zeros(size(result.ss_eqns.A, 1)); flag::Bool=false)

    if typeof(u(x0, 0.0)) != Vector{Float64} && typeof(u(x0, 0.0)) != Vector{Int64}
        error("Input function must be a vector.")
    end

    (; A, B, C, D), _, _, _ = c2d(result.ss_eqns, 0.001)
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

    lti_soln(y, uu, t, result.sys_data)
end

#    LTI = SplitFunction(MatrixOperator(A), (dx, x, p, t) -> dx .= B * u(x, t))
#    prob = SplitODEProblem(LTI, x0, (tspan[1], tspan[end]))
#    x = solve(prob, ETDRK4(); dt=tspan[2]-tspan[1])

# function eomtr(dx, x, p, t)
#     dx .= A * x + B * u(x, t)
#     nothing
# end
# prob = ODEProblem(eomtr, x0, tspan)
# x = solve(prob, Tsit5())
