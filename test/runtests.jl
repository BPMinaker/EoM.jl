using EoM
using Test

verbose = true

fldr = joinpath("..", "examples")
exps = readdir(fldr)
for i in exps
    include(joinpath(fldr, i))
end

systems=[
input_ex_smd,
input_ex_drag_race,
input_ex_yaw_plane,
input_ex_truck_trailer,
input_ex_quarter_car,
input_ex_bounce_pitch,
input_ex_half_car,
input_ex_full_car
]

for system in systems
    output = run_eom!(system(), verbose)
    result = analyze(output, verbose)
    println(@test typeof(result) == EoM.analysis)
end
