function EoM.animate_modes(
    system::mbd_system,
    result::EoM.analysis,
    verbose::Bool=false;
    folder="output",
    filename::String = system.name,
    overwrite::Bool=true,
    scale=1,
    num=size(result.modes, 2)
)
    ## Copyright (C) 2017, Bruce Minaker
    ## animate_modes.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## animate_modes.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    ## This function computes the time history of the system from the mode vector, and passes it to the animator

    # check if we are asking to animate more than all the modes
    m = size(result.modes, 2)
    num = min(m, num)

    verbose && println("Animating mode shapes...")

    dir_date = EoM.setup(; folder)

    dir = joinpath(dir_date, filename)
    !isdir(dir) && (mkdir(dir))

    # remove and recreate x3d folder (default), or not
    if overwrite
        dir = joinpath(dir_date, filename, "x3d")
        rm(dir, recursive=true, force=true)
        mkdir(dir)
    else
        tmstr = Dates.format(now(), "HH-MM-SS-s")
        dir = joinpath(dir_date, filename, "x3d_" * tmstr)
        mkdir(dir)
    end

    val = result.mode_vals
    modes = result.modes

    x3d_body!(system)  ## Fill in the default graphics data
    x3d_connections!(system)  ## Fill in the connection data

    tout = 0:5/200:5 ## n point interpolation

    if length(scale) == num
        verbose && println("Using individual mode scaling...")
    else
        scale *= ones(length(tout))
    end

    for i in 1:num  ## For each mode
        tau = abs(1 / real(val[i]))  ## Find the time constant (abs in case of unstable)
        lam = abs(2pi / imag(val[i]))  ## Find the wavelength
        tt = min(3 * tau, lam)
        tt == Inf && (tt = 1)

        if abs(val[i]) > 1e-4  ## Check for rigid body modes
            pout = scale[i] * 0.5 * real(modes[:, i] * exp.(val[i] / 5.0 * tt * tout'))  ## Find the time history
        else
            pout = scale[i] * 0.5 * real(modes[:, i] * ones(1, length(tout)))
        end

        for j in 1:length(system.bodys)-1  ## For each body
            pout[6*j-5:6*j-3, :] += system.bodys[j].location * ones(1, size(pout, 2))  ## Add the static location to the displacement
        end

        pout = item_locations(system, pout)  ## Compute locations of the connecting items
        pout = pout'

        x3d_animate(system, tout, pout, joinpath(dir, "mode_$(i)_s=$(round(val[i], digits=3)).html"))
    end

    verbose && println("Animations complete.")

    nothing

end

###########################################3

#	rc(rad,w,v,bodys)  ## Calculate roll centres
## *** MODIFIED TO DRAW GROUND PLANE AT -152.6mm FOR VEHICLE MODEL ***
##st=[st vrml_surf([0;4],[-1.5,1.5],[-.1526 -.1526;-.1526 -.1526])]

#  rad(:,j)=pinv(skew(rots))*trans ## Radius to the instantaneous center of rotation of the body (rad=omega\v)
#  rad(:,j)=1e-6*round(rad(:,j)*1e6)  ## Round off to allow checks
#  if(norm(imag(rad(:,j)))>1e-4)
#  	flag=1
#  end
#  rad(:,j)=real(rad(:,j))  ## This should be a real anyway, but drop the complex parts
# 
#  if(norm(real(rots))>1e-4)  ## Draw the instant axis of rotation (in phase)
#  	w=real(rots)
#  	s1=[s1 x3d_cyl([mbd.system.data.bodys(j).location-rad(:,j)-w,mbd.system.data.bodys(j).location-rad(:,j)+w],"rad",0.005,"tran",0.5)]
#  end
#  if(norm(imag(rots))>1e-4)  ## Draw the instant axis of rotation (out of phase)
#  	w=imag(rots)
#  	s1=[s1 x3d_cyl([mbd.system.data.bodys(j).location-rad(:,j)-w,mbd.system.data.bodys(j).location-rad(:,j)+w],"rad",0.005,"tran",0.5)]
#  end



#  if(flag)
#  	disp("Warning: discarding imaginary centre of rotation - likely pure translation.")
#  end
