function elastic_connections!(the_system::mbd_system, data::EoM.eom_data, verb::Bool = false)
    ## Copyright (C) 2017, Bruce Minaker
    ## elastic_connections.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## elastic_connections.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## Check condition of deflection matrix
    verb && println("Checking flexible items...")

    n = length(the_system.bodys)

    ## The form of the deflection matrix depends on the type of elastic item,
    defln_mtx = [
        point_line_jacobian(the_system.springs, n)
        point_line_jacobian(the_system.flex_points, n)
        line_bend_jacobian(the_system.beams, n)
    ]

    s = size(defln_mtx, 1)  ## s=the number of rows in the deflection matrix
    if s > 0  ## If the deflection matrix has more than zero rows (i.e. there are elastic items in the system)
        rk = rank(defln_mtx) ## rk=the rank (the number of linearly independent rows or columns) of the deflection matrix
        if rk == s ## If the rank equals the number of rows, the flexible connectors are statically determinate
            verb && println("Flexible connectors are statically determinate. Good.")  ## Give success message
        else
            verb && println("Warning: the flexible connectors are indeterminate.")  ## Give warning
        end

        ## Gather all stiffness and damping coefficients into a vector
        ns = length(the_system.springs)
        if ns > 0
            spring_stiff = getfield.(the_system.springs, :stiffness)
            spring_dmpng = getfield.(the_system.springs, :damping)
            spring_inertia = getfield.(the_system.springs, :inertance)
            preload_vec = getfield.(the_system.springs, :preload)
        else
            spring_stiff = zeros(0)
            spring_dmpng = zeros(0)
            spring_inertia = zeros(0)
            preload_vec = zeros(0)
        end

        ## Find the springs where the preload is given
        fnd = findall(.~ isnan.(preload_vec))

        ## Record their stiffnesses
        subset_spring_stiff = spring_stiff[fnd]
        preload_vec = preload_vec[fnd]  ## Throw away NaNs

        slct_mtx = zeros(length(the_system.springs), s)
        for i in fnd
            slct_mtx[i, i] = 1
        end
        slct_mtx = slct_mtx[fnd, :]  ## Throw away zero rows

        t = sum(num_fm.(the_system.flex_points))
        flex_point_stiff = zeros(t, t)
        flex_point_dmpng = zeros(t, t)
        flex_point_inertia = zeros(t, t)

        idx = 1
        for i in the_system.flex_points  ## For each elastic point item
            idxe = idx + num_fm(i) - 1
            flex_point_stiff[idx:idxe, idx:idxe] = i.s_mtx
            flex_point_dmpng[idx:idxe, idx:idxe] = i.d_mtx
            idx = idxe + 1
        end

        ## Relate the beam stiffness matrix to the deflection of the ends
        idx = 1
        nb = 8 * length(the_system.beams)
        beam_stiff = zeros(nb, nb)  ## Creates empty matrix for the beam stiffnesses
        beam_damping = zeros(nb, nb)
        beam_inertia = zeros(nb, nb)  ## Creates empty atrix for the beam inertia
        for i in the_system.beams
            l = i.length
            D = [
                0 0 0 -1 0 0 0 1
                2/l 0 0 1 -2/l 0 0 1
                0 0 -1 0 0 0 1 0
                0 2/l -1 0 0 -2/l -1 0
            ]
            beam_stiff[8*idx.+(-7:0), 8*idx.+(-7:0)] =
                1 / l * (D' * diagm(0 => [i.stiffness[1], 3 * i.stiffness[1], i.stiffness[2], 3 * i.stiffness[2]]) * D)
            E = [
                6 0 0 l 6 0 0 -l
                8 0 0 l -8 0 0 l
                0 6 -l 0 0 6 l 0
                0 8 -l 0 0 -8 -l 0
            ]
            beam_inertia[8*idx.+(-7:0), 8*idx.+(-7:0)] =
                i.mpul * l / 432 * (E' * diagm(0 => [111 / 37, 1, 111 / 37, 1]) * E)
            idx += 1
        end

        ## Converts stiffness row vector into diagonal matrix -> a column for each elastic item
        stiff = cat(diagm(0 => spring_stiff), flex_point_stiff, beam_stiff, dims = (1, 2))

        ## Convert damping row vector into diagonal matrix  -> a column for each elastic item
        dmpng = cat(diagm(0 => spring_dmpng), flex_point_dmpng, beam_damping, dims = (1, 2))
        #zeros(1,3*the_system.ntriangle_3s) zeros(1,5*the_system.ntriangle_5s) ])

        ## Compute the diagonal inertia values
        inertia =
            cat(diagm(0 => spring_inertia), flex_point_inertia, beam_inertia, dims = (1, 2))
        #	zeros(1,3*the_system.ntriangle_3s) zeros(1,5*the_system.ntriangle_5s)]), ...

        ## Use the deflection matrices to determine the stiffness matrix that results from the deflection of the elastic items -> Combines delfn_mtx (row for each elastic item, six columns for each body) with 'stiff' (row, column for each elastic constraint) to give proper stiffness matrix
        stiff_mtx = defln_mtx' * stiff * defln_mtx
        dmpng_mtx = defln_mtx' * dmpng * defln_mtx
        inertia_mtx = defln_mtx' * inertia * defln_mtx

    else
        verb && println("No flexible connectors.")  ## If there are no springs or flex point items, define empty matrices

        stiff_mtx = zeros(6 * (n - 1), 6 * (n - 1))
        dmpng_mtx = zeros(6 * (n - 1), 6 * (n - 1))
        inertia_mtx = zeros(6 * (n - 1), 6 * (n - 1))

        slct_mtx = zeros(0, 0)
        preload_vec = zeros(0)
        stiff = zeros(0, 0)
        subset_spring_stiff = zeros(0)

    end

    data.stiffness = stiff_mtx
    data.damping = dmpng_mtx
    data.inertia = inertia_mtx
    data.deflection = defln_mtx
    data.selection = slct_mtx
    data.preload = preload_vec
    data.spring_stiffness = stiff
    data.subset_spring_stiffness = subset_spring_stiff

end  ## Leave


# #	if(the_system.ntriangle_3s>0)
# #        stiff=blkdiag(stiff,the_system.triangle_3s.mod_mtx);
# #	end
#
# # 	T=0.5*eye(3)+(1/6)*ones(3);  ## Using a 3 point (2/3,1/6,1/6) integration, find integration points
# # 	for i=1:the_system.ntriangle_5s
# # 		gp=the_system.triangle_5s(i).local*T;
# # 		D=zeros(5);
# # 		B=zeros(3,5,3);
# # 		for j=1:3
# # 			## Evaluate B at each integration point
# # 			B(:,:,j)=[1 gp(2,j) 0 0 0; 0 0 1 gp(1,j) 0; 0 -gp(1,j) 0 -gp(2,j) 1];
# # 			D=D+B(:,:,j)'*the_system.triangle_5s(i).mod_mtx*B(:,:,j);
# # 		end
# # 		D=D/3;
# # 		stiff=blkdiag(stiff,D);
# # 	end
