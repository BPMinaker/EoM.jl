function EoM.eom_draw(
    system::mbd_system,
    verbose::Bool=false;
    folder::String="output",
    filename::String = system.name,
    overwrite::Bool=true
    )
    ## Copyright (C) 2017, Bruce Minaker
    ## eom_draw.jl is free software you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation either version 2, or (at your option)
    ## any later version.
    ##
    ## eom_draw.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## This function draws the X3D file of the system
    verbose && println("Drawing x3d...")

    dir_date = EoM.setup(; folder)

    dir = joinpath(dir_date, filename)
    !isdir(dir) && (mkdir(dir))

    dir = joinpath(dir_date, system.name, "x3d")
    !isdir(dir) && (mkdir(dir))

    x3d_body!(system)  ## Fill in the default graphics data
    x3d_connections!(system; trans=true)  ## Fill in the connection data

    s = ""
    for item in system.bodys

        #  	## Add a viewpoint for each body, except ground
        #  	lcns=[item.location(:,1)]+[0; 0; 2]
        #  	pstn=sprintf('%f %f %f',lcns)
        #  	s=[s  '<Viewpoint position="' pstn '"/>\n' ]
        ils = join(string.(item.location), " ")
        s *= "<Transform translation='$(ils)' >\n" * item.x3d * "</Transform>\n"
    end

    for item in system.rigid_points
        lcn = item.location

        if (item.forces == 3 || item.forces == 0) && (item.moments == 3 || item.moments == 0)
            s *= x3d_pnt(lcn, rad=0.025, col=[0, 0, 0.5])
        else
            s *= x3d_cyl([lcn - 0.025 * (item.axis) / norm(item.axis) lcn + 0.025 * (item.axis) / norm(item.axis)], rad=0.02, col=[0, 0, 0.5])
        end
    end

    for item in system.flex_points
        lcn = item.location

        if (item.forces == 3 || item.forces == 0) && (item.moments == 3 || item.moments == 0)
            s *= x3d_pnt(lcn, rad=0.025, col=[0.5, 0.5, 0])
        else
            s *= x3d_cyl([lcn - 0.025 * (item.axis) / norm(item.axis) lcn + 0.025 * (item.axis) / norm(item.axis)], rad=0.021, col=[0.5, 0.5, 0])
        end
    end

    link_rad = 0.01
    for item in system.links
        s *= x3d_cyl([item.location[1] item.location[2]], rad=link_rad, col=[0, 0.5, 0])
    end

    link_rad = 0.015
    for item in system.springs
        len = item.length
        frac = 2 * link_rad / len
        temp1 = (1 - frac) * item.location[1] + frac * item.location[2]
        temp2 = 0.35 * item.location[1] + 0.65 * item.location[2]
        x3d_spring = x3d_cyl([temp1 temp2], rad=2.5 * link_rad, tran=0.3, col=[1, 1, 0])  ## shell inner
        x3d_spring *= x3d_pnt(item.location[1], rad=2 * link_rad, col=[1, 1, 0]) ## ball inner

        temp1 = 0.65 * item.location[1] + 0.35 * item.location[2]
        temp2 = frac * item.location[1] + (1 - frac) * item.location[2]
        x3d_spring_out = x3d_cyl([temp1 temp2], rad=3 * link_rad, tran=0.3, col=[1, 1, 0])  ## shell outer

        frac = 0.65 - link_rad / len
        temp1 = frac * item.location[1] + (1 - frac) * item.location[2]
        x3d_spring_out *= x3d_cyl([item.location[2] temp1], rad=link_rad, col=[1, 1, 1]) ## shaft

        frac = 0.65 + link_rad / len
        temp2 = frac * item.location[1] + (1 - frac) * item.location[2]
        x3d_spring_out *= x3d_cyl([temp1 temp2], rad=2.3 * link_rad, col=[1, 1, 1]) ##piston
        x3d_spring_out *= x3d_pnt(item.location[2], rad=2 * link_rad, col=[1, 1, 0]) ## ball outer

        s *= x3d_spring * x3d_spring_out
    end

    for item in system.actuators
        s *= x3d_cyl([item.location[1] item.location[2]], rad=0.01, col=[0, 1, 0.5])
    end

    for item in system.sensors
        s *= x3d_cyl([item.location[1] item.location[2]], rad=0.01, col=[0, 0.5, 1])
    end

    for item in system.loads
        lcn = item.location
        if norm(item.force) > 0
            dirn = 0.2 * item.force / norm(item.force)
        else
            dirn = [0, 0, 0]
        end

        s *= x3d_cyl([lcn lcn + dirn], rad=0.01, col=[0.5, 0, 0.5])
        s *= x3d_cyl([lcn + dirn lcn + 1.5 * dirn], rad=0.015, cone=true, col=[0.5, 0, 0.5])

        if norm(item.moment) > 0
            dirn = 0.2 * item.moment / norm(item.moment)
        else
            dirn = [0; 0; 0]
        end
        s *= x3d_cyl([lcn lcn + dirn], rad=0.01, col=[0.5, 0, 0.5])
        s *= x3d_cyl([lcn + dirn lcn + 1.5 * dirn], rad=0.015, cone=true, col=[0.5, 0, 0.5])
        s *= x3d_cyl([lcn + 1.3 * dirn lcn + 1.8 * dirn], rad=0.015, cone=true, col=[0.5, 0, 0.5])
    end


    # for i=1:syst.data.nbeams
    # 	item=syst.data.beams(i)
    # 	lcns=[item.location[:,1] item.location[:,2]]
    # 	s*= x3d_cyl(lcns,"rad",0.02,"col",[1 0.5 0])
    # end


    # for i=1:syst.data.nnh_points
    # 	item=syst.data.nh_points(i)
    # 	lcns=item.location[:,1]
    # 	if((item.forces==3||item.forces==0)&&(item.moments==3||item.moments==0))
    # 		s*= x3d_pnt(lcns,"rad",0.025,"col",[1 1 0.5])
    # 	else
    # 		s*= x3d_cyl([lcns-0.03*(item.axis)/norm(item.axis),lcns+0.03*(item.axis)/norm(item.axis)],"rad",0.015,"col",[1 1 0.5])
    # 	end
    # end
    #

    x3d_save(s, joinpath(dir, "system.html"))
    verbose && println("Drawing x3d done.")

    ## *** MODIFIED TO DRAW GROUND PLANE AT -152.6mm FOR VEHICLE MODEL ***
    ##st=[st vrml_surf([0;4],[-1.5,1.5],[-.1526 -.1526;-.1526 -.1526])]

    s

end
