using EoM
using Test

verbose = true

include("input_ex_smd.jl")
include("input_ex_pendulum.jl")
include("input_ex_disk.jl")
include("input_ex_top.jl")

systems=[
input_ex_smd,
input_ex_pendulum,
input_ex_disk,
input_ex_top
]

for system in systems
    output = run_eom!(system(), verbose)
    result = analyze(output, verbose)
    println(@test typeof(result) == EoM.analysis)
end
