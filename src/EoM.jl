#__precompile__()

module EoM

using LinearAlgebra
using Dates
using DelimitedFiles

export build_examples
export setup
export run_eom
export analyze
export full_ss
export write_output
export weave_output
export write_html
export lsim
export splsim
export random_road

export skew
export mbd_system
export thin_rod
export mirror!

export e_val
export omega_n
export zeta
export tau
export lambda
export vpt

macro def(name,definition)
	return quote
		macro $(esc(name))()
			esc($(Expr(:quote,definition)))
		end
	end
end

@def add_generic_fields begin
	name::String
	group::String
	body::Vector{String}
	body_number::Vector{Int}
	forces::Int
	moments::Int
	radius::Vector{Vector{Float64}}
end

fldr=joinpath(dirname(pathof(EoM)),"types")
types=readdir(fldr)
for i in types
	include(joinpath(fldr,i))
end

#export run_eom_nl
#include("rotate.jl")
#include("run_eom_nl.jl")
#include("xdot.jl")
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
include("decompose.jl")
include("write_output.jl")
include("weave_output.jl")
include("write_html.jl")
include("load_defln.jl")
include("syst_props.jl")
include("mirror.jl")
include("thin_rod.jl")
include("lsim.jl")
include("splsim.jl")
include("random_road.jl")

end  # end module
