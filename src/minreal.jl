function minreal(ss_eqns::EoM.ss_data, args...)
    ## Copyright (C) © 2021, Bruce Minaker
    ## minreal.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## minreal.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    # Based on the algorithm in "An Elementary Derivation of Rosenbrock's Minimal Realization Algorithm", D.Q. Mayne
    # IEEE Transactions on Automatic Control, June 1973

    verbose = any(args .== :verbose)
    ss_1 = cont_part(ss_eqns)
    ss_2 = cont_part(ss_data(ss_1.A', ss_1.C', ss_1.B', ss_eqns.D'))
    ss_2 = ss_data(ss_2.A', ss_2.C', ss_2.B', ss_eqns.D)
    verbose && println("Minimal system is of dimension ", size(ss_2.A,2), ".")
    ss_2
end

function cont_part(ss_eqns::EoM.ss_data)

    A = ss_eqns.A
    B = ss_eqns.B
    C = ss_eqns.C
    D = ss_eqns.D

    H = [A B; C zeros(size(D))]
    #display(H)

    # step 1
    i, j = size([A B])
    n = i
    while i != j && i > 1
        # step 2
        if any(abs.(H[1:i, j]) .> 1e-8)
            # step 3
            if abs(H[i, j]) < 1e-8
                # step 4
                r = argmax(abs.(H[1:i-1, j]))
                swap!(H, i, r)
            end
            # step 5
            for r = 1:i-1
                zero_out!(H, r, i, j)
            end
            # step 6
            i -= 1
        end
        # step 7
        j -= 1
    end
    #display(H)

    j = 0
    for i in 1:n-1
        if !any(abs.(H[1:i, i+1:end]) .> 1e-8)
            j = i
        end
    end
    if  j == 0
        return ss_eqns
    else
        return ss_data(H[j+1:n, j+1:n], H[j+1:n, n+1:end], H[n+1:end, j+1:n], D)
    end
end

function zero_out!(H, r, i, j)
    a = -H[r, j] / H[i, j]
    H[r, :] .+= a * H[i, :]
    H[:, i] .-= a * H[:, r]
end

function swap!(x::Array{Float64,2}, i::Int64, j::Int64)
    for k in axes(x, 2)
        x[i, k], x[j, k] = x[j, k], x[i, k]
    end
    for k in axes(x, 1)
        x[k, i], x[k, j] = x[k, j], x[k, i]
    end
end

# function diagonalize(ss_eqns::EoM.ss_data)
#     A = ss_eqns.A
#     B = ss_eqns.B
#     C = ss_eqns.C
#     D = ss_eqns.D

#     H = [A B; C zeros(size(D))]

#     i = 0
#     j = 1
#     n = size(A, 1)

#     while j < n
#         t = abs.(H[1:n, j]) .> 1e-8
#         u = findall(t)
#         u = u[u .> i]
#         if length(u) > 1
#             i = u[1]
#             for r in u[2:end]
#                 zero_out!(H, r, i, j)
#             end
#         end
#         j += 1
#     end
#     ss_data(H[1:n, 1:n], H[1:n, n+1:end], H[n+1:end, 1:n], D)
# end
