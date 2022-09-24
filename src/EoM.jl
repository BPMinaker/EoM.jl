# __precompile__()

module EoM

using LinearAlgebra
using Dates
using DelimitedFiles
#using ForwardDiff
using Plots
using PrettyTables

export setup
export run_eom!
export analyze
export full_ss
export write_output
export summarize
export lsim
export splsim
export random_road
export input_delay!

export skew
export mbd_system
export eom_output
export thin_rod
export mirror!
export add_item!

export e_val
export omega_n
export zeta
export tau
export lambda
export vpt

export my_round

fldr = joinpath(dirname(pathof(EoM)), "types")
types = readdir(fldr)
for i in types
    include(joinpath(fldr, i))
end


include("eom_structs.jl")

include("run_eom.jl")
include("setup.jl")
include("build_examples.jl")
include("mass.jl")
include("sort_system.jl")
include("find_bodynum.jl")
include("find_radius.jl")
include("item_init.jl")
include("generate_eom.jl")
include("force.jl")
include("skew.jl")
include("elastic_connections.jl")
include("rigid_constraints.jl")
include("preload.jl")
include("const_frc_deal.jl")
include("defln_deal.jl")
include("centngyro.jl")
include("point_line_jacobian.jl")
include("line_bend_jacobian.jl")
include("inputs.jl")
include("outputs.jl")
include("tangent.jl")
include("line_stretch_hessian.jl")
include("point_hessian.jl")
include("assemble_eom.jl")
include("analyze.jl")
include("full_ss.jl")
include("dss2ss.jl")
include("minreal.jl")
include("write_output.jl")
include("load_defln.jl")
include("syst_props.jl")
include("summarize.jl")

include("mirror.jl")
include("thin_rod.jl")
include("lsim.jl")
include("splsim.jl")
include("random_road.jl")
include("input_delay.jl")

#include("phi.jl")

function my_round(x; dig = 4, lim = 1e-7)
    x = round(x,sigdigits=dig)
    abs(real(x)) < lim  && (x = 0 + imag(x)im )
    abs(imag(x)) < lim  && (x = real(x))
    x
end

function treat(vec_in)
    vect = unique.(vec_in)
    nf = maximum(length.(vect))
    len = length(vect)
    for i in 1:len
        if length(vect[i]) < nf
            pushfirst!(vect[i], NaN * zeros(nf - length(vect[i]))...)
        end
    end
    vect = hcat(vect...)'
    vect[vect.==0] .= NaN
    rcol = []
    for i in 1:size(vect, 2)
        if sum(isnan.(vect[:, i])) < len && sum(isinf.(vect[:, i])) < len
            push!(rcol, i)
        end
    end
    vect[:, rcol]
end

# Let's define some helper functions to make piecewise functions easier to define
function step(t)
    0.5 * (sign(t) + 1)
 end

 function pulse(t, a, b)
    step(t-a) - step(t-b)
 end

end  # end module



# macro def(name, definition)
#     return quote
#         macro $(esc(name))()
#             esc($(Expr(:quote, definition)))
#         end
#     end
# end

# @def add_generic_fields begin
#     name::String
#     group::String
#     body::Vector{String}
#     body_number::Vector{Int}
#     forces::Int
#     moments::Int
#     radius::Vector{Vector{Float64}}
# end


