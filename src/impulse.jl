function impulse(
    ss::EoM.ss_data,
    t::StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}};
    flag::Bool = false
)

    # Copyright (C) 2023, Bruce Minaker

    y = fill(zeros(size(ss.C, 1), size(ss.B, 2)), length(t))
    for i in eachindex(t)
        y[i] = ss.C * exp(ss.A * t[i]) * ss.B
    end
    y
 
end
