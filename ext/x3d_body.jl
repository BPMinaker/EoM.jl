function x3d_body!(syst::mbd_system)

    ## GPL here
    # This function builds an x3d model

    f1(_) = x3d_pnt([0, 0, 0], rad=0.03, col=[0.5, 0, 0])
    f2(_) = x3d_pnt([0, 0, 0], rad=0.02, col=[0.5, 0, 0])
    f3(_) = x3d_pnt([0, 0, 0], rad=0.015, col=[0.5, 0, 0])
    f4(_) = x3d_pnt([0, 0, 0], cubes=true, rad=[0.8, 0.3, 0.4], col=[0, 0, 0.5], tran=0.3)
    f5(_) = x3d_cyl([[0, -0.1, 0] [0, 0.1, 0]], rad=0.05, col=rand(3, 1))

    function ground(_)
        x3d_cyl([[0, 0, 0] [0, 0, -0.01]], rad=3, col=[0, 0.4, 0], tran=0.5) * 
        x3d_pnt([0, 0, 0], cubes=true, rad=[3, 1.5, 0.01], col=[0.25, 0.25, 0.25], tran=0.5)
    end

    function wheel(i::EoM.body)
        lcn = i.location
        rr = abs(lcn[3])
        rr == 0 && (rr = 0.3)
        x3d_cyl([[0, rr / 4, 0] [0, -rr / 4, 0]], rad=rr, col=[0.05, 0.05, 0.05], tran=0.4, shin=1.0) *
        x3d_cyl([[0, rr / 3.9, 0] [0, -rr / 3.9, 0]], rad=0.8 * rr, col=[0.25, 0.25, 0.25], tran=0.8)
    end

    tag_actions = Dict(
        "ground"  => ground,
        "wheel"   => wheel,
        "upright" => f1,
        "strut"   => f1,
        "arm"     => f1,
        "crank"   => f2,
        "rod"     => f3,
        "bar"     => f3,
        "chassis" => f4,
        "rack"    => f5
    )
    for i in syst.bodys
        name_lc = lowercase(i.name)
        x3d = x3d_pnt([0, 0, 0], cubes=true, rad=[0.045, 0.045, 0.045], col=[0.5, 0, 0], tran=0.3)
        for tag in eachindex(tag_actions)
            if occursin(tag, name_lc)
                x3d = tag_actions[tag](i)
                break
            end
        end
        i.x3d *= x3d
    end
end  ## Leave
