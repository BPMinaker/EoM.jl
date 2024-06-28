function splsim(
    ss::EoM.ss_data,
    u::Function,
    t::StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},
    x0 = zeros(size(ss.A, 2), 1);
    flag::Bool = false
)

    # Copyright (C) 2020, Bruce Minaker

    n = length(t)
    T = t[2] - t[1]
    val, vec = eigen(ss.A)

    h = minimum(0.4 ./ abs.(val .+ eps(1.0)))
    T > h && println("Warning: step size may be too large")

    ##Ad=exp(ss.A*T)
    ##Bd=ss.A\(Ad-I)*ss.B
    # find the discrete time equivalent A and B matrices
    # use a sum to avoid problems in cases where A is singular
    AT = ss.A * T

    sz = size(ss.A)
    term1 = zeros(sz) + I
    term2 = zeros(sz) + I
    Ad = zeros(sz) + I
    Bd = zeros(sz) + I

    AToveri = [AT] ./ collect(2:11)
    pushfirst!(AToveri, AT)

    for i in 1:10
        term1 *= AToveri[i]
        term2 *= AToveri[i+1]
        Ad += term1
        Bd += term2
    end
    Bd *= ss.B * T

    Z = sparse([Ad Bd])
    ZZ = sparse([ss.C ss.D])

    ns = size(ss.A, 2)
    ni = size(ss.B, 2)
    no = size(ss.C, 1)
    xu = zeros(ns + ni, n)
    y = fill(zeros(no), n)
    
    xu[1:ns, 1] = x0
    xu[ns+1:ns+ni, 1] .= u(x0, t[1])
    y[1] = ZZ * xu[:,1]

    for i in 2:n
        xu[1:ns, i] .= Z * xu[:, i-1]
        xu[ns+1:ns+ni, i] .= u(xu[1:ns, i], t[i])
        y[i] = ZZ * xu[:,i]
    end

    if flag
        return StateSpaceSet(y), xu
    else
        return StateSpaceSet(y)
    end
end
