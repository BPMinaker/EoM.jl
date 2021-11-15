function generate_eom(the_system::mbd_system, verbose::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## generate_eom.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## generate_eom.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Generate the linearized equations of motion for a multibody system

    ## Begin construction of equations of motion
    verbose && println("Okay, got the system info, building equations of motion...")

    data = eom_data()

    ## Build the mass matrix
    data.mass = mass(the_system, verbose)

    ## Sum external forces and cast into vector
    ## Determine stiffness matrix for angular motion resulting from applied forces
    force!(the_system, data, verbose)

    ## Build the stiffness matrix due to deflections of elastic elements
    elastic_connections!(the_system, data, verbose)

    ## Build the matrices describing the rigid constraints
    rigid_constraints!(the_system, data, verbose)

    ## Solve for the internal and reaction forces and distribute
    preload!(data, verbose)
    const_frc_deal!(the_system, data.lambda, verbose)
    defln_deal!(the_system, data.static, verbose)

    ## Build the tangent stiffness matrix from the computed preloads
    tangent!(the_system, data, verbose)

    ## Build the input matrix
    inputs!(the_system, data, verbose)

    ## Build the output matrix
    outputs!(the_system, data, verbose)

    data
end

    #t1 = @elapsed 
    #t2 = @elapsed
    #t3 = @elapsed K=phi(the_system, verbose)
    #ee =  norm(K - (data.stiffness + data.tangent_stiffness))
    #println("The norm matrix error is $ee.")
    #println("The algebraic calc took $(round((t1+t2)*1000,digits=3)) milliseconds.")
    #println("The automatic diff took $(round(t3*1000,digits=2)) milliseconds and $(round(t3/(t1+t2),digits=3)) times longer.")
    #println("The matrix sparsity is $(100 * count(iszero.(K)) / size(K,1) / size(K,2))%.")
    #if ee > 1e-4
        #display(round.(K,digits=2))
        #display(round.(data.stiffness + data.tangent_stiffness,digits=2))
        #display(round.(K - data.stiffness - data.tangent_stiffness,digits=3))
    #end
