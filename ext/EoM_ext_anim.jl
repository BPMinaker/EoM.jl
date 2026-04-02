module EoM_ext_anim

using EoM
using EoM_X3D
using LinearAlgebra
using Dates

include("animate_modes_x3d.jl")
include("animate_history_x3d.jl")
include("eom_draw_x3d.jl")

include("item_locations.jl")
include("x3d_animate.jl")
include("x3d_body.jl")
include("x3d_connections.jl")

end