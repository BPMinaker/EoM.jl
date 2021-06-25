function run_eom(sysin::Function, args...; vpts = [])

    ## Copyright (C) 2017, Bruce Minaker
    ## run_eom.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## run_eom.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verbose = any(args .== :verbose)
    diagnose = any(args .== :diagnose)

    verbose && println("\nCalling system function: $sysin ...")

    vpts isa Number && (vpts = [vpts])
    n = length(vpts)

    if n > 0
        the_system = sysin.(vpts) # build all the input structs
        setfield!.(the_system, :vpt, vpts)
    else
        the_system = [sysin()]
        n = 1
    end

    verbose && println("Running analysis of system: $(the_system[1].name) ...")
    verbose && println("Found $(length(the_system[1].item)) items...")

    verb = Bool.(zeros(n))
    verb[1] = verbose

    sort_system!.(the_system, verb) # sort all the input structs
    out = generate_eom.(the_system, verb)
  
    the_eqns = first.(out)
    the_data = last.(out)

     if !diagnose
        return the_system, the_eqns
    else
        return the_system, the_eqns, the_data
    end

end
