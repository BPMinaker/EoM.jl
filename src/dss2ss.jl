function dss2ss(dss_eqns::EoM.dss_data, verb::Bool=false)

    # Copyright (C) 2020, Bruce Minaker

    verb && println("System is of dimension ", size(dss_eqns.A, 1), ".")
    verb && println("Converting from descriptor form to standard state space...")

    Q, S, P = svd(dss_eqns.E)  ##Q'*E*P should = S

    S = S[S.>(maximum(size(dss_eqns.E))*eps(maximum(S)))]
    n = length(S)
    Sinv = diagm(0 => 1.0 ./ S)

    Atilde = Q' * dss_eqns.A * P
    Btilde = Q' * dss_eqns.B
    Ctilde = dss_eqns.C * P

    A11 = Atilde[1:n, 1:n]
    A12 = Atilde[1:n, n+1:end]
    A21 = Atilde[n+1:end, 1:n]
    A22 = Atilde[n+1:end, n+1:end]

    B1 = Btilde[1:n, :]
    B2 = Btilde[n+1:end, :]

    C1 = Ctilde[:, 1:n]
    C2 = Ctilde[:, n+1:end]

    A221 = A22 \ A21
    A22B = A22 \ B2

    A = Sinv * (A11 - A12 * A221)
    B = Sinv * (B1 - A12 * A22B)
    C = C1 - C2 * A221
    D = dss_eqns.D - C2 * A22B

    n = size(A, 1)
    verb && println("System is now of dimension ", n, ".")

    ss_data(; A, B, C, D)

end
