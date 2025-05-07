function discrete(result::EoM.analysis, T::Float64; flag::Bool = false)

    h = minimum(0.4 ./ abs.(result.e_val .+ eps(1.0)))
    T > h && println("Warning: step size may be too large")

    (; A, B, C, D) = result.ss_eqns

    ##Ad=exp(ss.A*T)
    ##Bd=ss.A\(Ad-I)*ss.B
    # find the discrete time equivalent A and B matrices
    # use a sum to avoid problems in cases where A is singular

    phi = zeros(size(A)) + I
    k = 10:-1:2

    for i in k
        phi *= A * (T / i)
        phi += I
    end
    phi *= T

    Ad = A * phi + I
    Bd = phi * B

    ss_data(Ad, Bd, C, D)
 
end

#=
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
=#


