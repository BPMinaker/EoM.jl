function random_road(;class::Int=3, L=100.0, B=0.05, dz=0)

# class is an integer from 3 - 9, where class=3 is an A-B road (smooth), class=9 is G-H road (rough)
# L is max wavelength [m], also equals road length
# B shortest wavelength, approx [m]
# dz gives variation bewteen two random roads, 0=same, 1=totally different

    if class < 3
        class = 3
        println("Warning: class out of range, resetting to minimum value (3)")
    end

    if class > 9
        class = 9
        println("Warning: class out of range, resetting to maximum value (9)")
    end

    deltan = 1 / L  # spatial frequency interval
    N = Int(round(L / B))  # number of frequencies

    n = deltan:deltan:N * deltan  # frequency span

    ϕ1 = rand(N) * 2π  # N random phase lag, 1 for each frequency, from 0 - 2π
    ϕ2 = ϕ1 + dz * rand(N) * 2π

    a = sqrt(deltan) * (2 ^ class) * 1e-4 ./ n  # amplitude of each frequency, based on psd content

    # sum for each frequency included
    z01 = a' * cos.(ϕ1)
    z02 = a' * cos.(ϕ2)

    z1(x) = a' * cos.(n * 2π * x + ϕ1) - z01
    z2(x) = a' * cos.(n * 2π * x + ϕ2) - z02

    if dz == 0
        return z1
    else
        return z1, z2
    end

end ## Leave
