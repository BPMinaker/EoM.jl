function x3d_animate(
    syst::mbd_system,
    tout::StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},
    pout,
    file_name::String
)
    ## Copyright (C) 2010, Bruce Minaker, Rob Rieveley
    ## This file is intended for use with Octave.
    ## x3d_animate.m is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## x3d_animate.m is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## This function draws the animated x3d file of the system

    tscale = tout[end]
    tout /= tscale
    n = size(pout, 1)

    l_pout = copy(pout)
    s1 = ""

    for j in eachindex(syst.bodys)
        item = syst.bodys[j]
        if item.name != "ground" ## If we have a body that's not ground, cause the ground doesn't move

            trans = l_pout[:, 1:3] 
            rots = hcat(l_pout[:, 4:6], zeros(n))
            l_pout = l_pout[:,7:end]

            temp1 = trans'
            temp2 = rots'

            for k in 1:n
                temp2[4, k] = norm(temp2[1:3, k]) # need to check the rotations plot
            end

            s1 *= x3d_motion(tout, temp1, temp2, "$(j)_body", item.x3d) ## Add the x3d string for the motion indicated by the mode shape
        else
            s1 *= item.x3d ## Ground doesn't move
        end
    end

    for j in eachindex(syst.rigid_points)
        item = syst.rigid_points[j]

        lcn = l_pout[:, 1:3]'
        l_pout = l_pout[:,4:end]
        rot = vcat(zeros(2, n), ones(1, n), zeros(1, n))

        if (item.forces == 3 || item.forces == 0) && (item.moments == 3 || item.moments == 0)
            x3d = x3d_pnt([0, 0, 0], rad=0.025, col=[0, 0, 0.5])
        else
            x3d = x3d_cyl([-0.025 * (item.axis) / norm(item.axis) 0.025 * (item.axis) / norm(item.axis)], rad=0.02, col=[0, 0, 0.5])
        end
        s1 *= x3d_motion(tout, lcn, rot, "$(j)_rigid_point", x3d) ## Add the x3d string for the motion indicated by the mode shape
    end

    for j in eachindex(syst.flex_points)
        item = syst.flex_points[j]

        lcn = l_pout[:, 1:3]'
        l_pout = l_pout[:,4:end]
        rot = vcat(zeros(2, n), ones(1, n), zeros(1, n))

        if (item.forces == 3 || item.forces == 0) && (item.moments == 3 || item.moments == 0)
            x3d = x3d_pnt([0, 0, 0], rad=0.025, col=[0.5, 0.5, 0])
        else
            x3d = x3d_cyl([-0.025 * (item.axis) / norm(item.axis) 0.025 * (item.axis) / norm(item.axis)], rad=0.021, col=[0.5, 0.5, 0])
        end
        s1 *= x3d_motion(tout, lcn, rot, "$(j)_flex_point", x3d) ## Add the x3d string for the motion indicated by the mode shape
    end

    l_pout = l_pout[:, 3 * length(syst.loads) + 1:end]

    s2 = ""
    link_rad = 0.01

    for j in eachindex(syst.links)
        item = syst.links[j]

        len = norm(item.location[2] - item.location[1])  ## build x3d link
        x3d_link = x3d_cyl([[0, 0, 0] [0, len, 0]], rad=link_rad, col=[0, 0.5, 0])

        lcn1 = l_pout[:, 1:3]'
        lcn2 = l_pout[:, 4:6]'
        l_pout = l_pout[:,7:end]

        aa = zeros(4, size(pout, 1))
        for i in 1:size(pout, 1)
            aa[1:4, i] = axisang(lcn2[:, i], lcn1[:, i])' # change each column from end points to axis and angle form for x3d standard
        end
        s2 *= x3d_motion(tout, lcn1, aa, "$(j)_link", x3d_link) # insert the picture of the arm into the animation data
    end

    s3 = ""
    s4 = ""
    link_rad = 0.015

    for j in eachindex(syst.springs)
        item = syst.springs[j]
        
        len = 0.65 * item.length

        if item.twist == 0
            x3d_spring = x3d_cyl([[0, 2 * link_rad, 0] [0, len, 0]], rad=2.5 * link_rad, col=[0.5, 0.5, 0], tran=0.3)
            x3d_spring *= x3d_pnt([0, 0, 0], rad=2 * link_rad, col=[0.5, 0.5, 0])

            x3d_spring_out = x3d_cyl([[0, 2 * link_rad, 0] [0, len, 0]], rad=3 * link_rad, col=[0.5, 0.5, 0], tran=0.3)
            x3d_spring_out *= x3d_cyl([[0, 0, 0] [0, len + link_rad, 0]], rad=link_rad, col=[0.5, 0.5, 0.5])
            x3d_spring_out *= x3d_cyl([[0, len - link_rad, 0] [0, len + link_rad, 0]], rad=2.3 * link_rad, col=[0.5, 0.5, 0.5])
            x3d_spring_out *= x3d_pnt([0, 0, 0], rad=2 * link_rad, col=[0.5, 0.5, 0])
        else
            x3d_spring = x3d_cyl([[0, 2 * link_rad, 0] [0, 0.77 * len, 0]], rad=1.5 * link_rad, col=[0.5, 0.5, 0], tran=0.3)
            x3d_spring *= x3d_pnt([0, 0, 0], rad=2 * link_rad, col=[0.5, 0.5, 0])
            x3d_spring_out = x3d_cyl([[0, 2 * link_rad, 0] [0, 0.77 * len, 0]], rad=1.5 * link_rad, col=[0.5, 0.5, 0], tran=0.3)
            x3d_spring_out *= x3d_pnt([0, 0, 0], rad=2 * link_rad, col=[0.5, 0.5, 0])
        end

        lcn1 = l_pout[:, 1:3]'
        lcn2 = l_pout[:, 4:6]'
        l_pout = l_pout[:,7:end]

        aa1 = zeros(4, n)
        aa2 = zeros(4, n)

        for i in 1:n
            aa1[1:4, i] = axisang(lcn2[:, i], lcn1[:, i])' # change each column from end points to axis and angle form for x3d standard
            aa2[1:4, i] = axisang(lcn1[:, i], lcn2[:, i])'
        end
        s3 *= x3d_motion(tout, lcn1, aa1, "$(j)_spring", x3d_spring) # insert the picture of the arm into the animation data
        s4 *= x3d_motion(tout, lcn2, aa2, "$(j)_spring_out", x3d_spring_out)
    end

    s = s1 * s2 * s3 * s4
    x3d_save(s, file_name, tscale)
end  ## Leave

#			str=['x3d=''' syst.bodys(j).x3d ''';']  ## and this body has an x3d description
#			eval(str);
