module EoM_ext_plt

using EoM
using Plots
using Plots.Measures
using Unitful
using PrettyTables
using Dates

include("summarize.jl")
include("ltiplot.jl")

function __init__()
    Plots.default(fontfamily="Calibri", titlefontsize=7, titlelocation=:left, size=(800, 400), lw=2, ms=3, title="EoM " * Dates.format(now(), "yyyy-mm-dd"))
end

function treat(vec_in::Vector{Vector{Float64}}, lim::Number)
    vect = unique.(vec_in)
    nf = maximum(length.(vect))
    len = length(vect)
    for i in vect
        if length(i) < nf
            pushfirst!(i, NaN * zeros(nf - length(i))...)
        end
    end
    vect = hcat(vect...)'
    any(vect .!= 0 .&& .!(isnan.(vect))) && (vect[vect.==0] .= NaN)
    vect[abs.(vect).>lim] .= Inf
    rcol = []
    for i in eachcol(vect)
        if sum(isnan.(i)) < len && sum(isinf.(i)) < len
            push!(rcol, i)
        end
    end
    hcat(rcol...)
end

end
