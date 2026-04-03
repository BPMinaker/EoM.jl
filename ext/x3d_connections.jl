function x3d_connections!(syst::mbd_system; trans::Bool=false)

# GPL here
# This function builds an x3d model

    link_rad = 0.018
    color = [0.25,0.25,0.25]
    tran = 0
    if trans
        tran = 0.3
    end

    for i in [syst.rigid_points; syst.flex_points]  ## For every point
        joint_lcn = i.location  ## Find the location
        for j = 1:2  ## For each body it attachs
            this_body_name = lowercase(syst.bodys[i.body_number[j]].name)
            if !(this_body_name == "ground") && !(this_body_name == "chassis") && !occursin("wheel", this_body_name)    ## If it's not the ground or the chassis
                body_lcn = syst.bodys[i.body_number[j]].location  ## Find the body location
                x3d = x3d_cyl([(joint_lcn - body_lcn) [0,0,0]]; rad=link_rad, col=color, tran)  ## Draw the connection
                syst.bodys[i.body_number[j]].x3d *= x3d  ## Add the x3d to the body
            end
        end
    end

    for i in [syst.links; syst.springs]  ## For every line
        for j = 1:2  ## For each body it attachs
            joint_lcn = i.location[j]  ## Find the location
            body_lcn = syst.bodys[i.body_number[j]].location  ## Find the body location
            if isa(i, EoM.link)
                x3d = x3d_pnt((joint_lcn - body_lcn), rad=link_rad + 0.002, col=[0,0,0.5])
            else
                x3d=""
            end
            this_body_name = lowercase(syst.bodys[i.body_number[j]].name)
            if !(this_body_name == "ground") && !(this_body_name == "chassis") ## If it's not the ground or the chassis
                x3d *= x3d_cyl([(joint_lcn - body_lcn) [0,0,0]]; rad=link_rad, col=color, tran)  ## Draw the link mount
            end
            syst.bodys[i.body_number[j]].x3d *= x3d  ## Add the x3d to the body
        end
    end
end  ## Leave
