function item_init!(items, verb=false)
    ## Copyright (C) 2017, Bruce Minaker
    ## item_init.jl is free software; you can redistribute it and/or modify it
    ## under the terms of the GNU General Public License as published by
    ## the Free Software Foundation; either version 2, or (at your option)
    ## any later version.
    ##
    ## item_init.jl is distributed in the hope that it will be useful, but
    ## WITHOUT ANY WARRANTY; without even the implied warranty of
    ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    ## General Public License for more details at www.gnu.org/copyleft/gpl.html.
    ##
    ##--------------------------------------------------------------------

    verb && println("Initializing...")

    function build_b(item, field)
        n = getfield(item, field)
        if n == 3 ## For 3 forces, i.e. ball joint
            return I + zeros(3, 3)
        elseif n == 2 ## For 2 forces, i.e. cylindrical or pin joint
            return item.nu'
        elseif n == 1 ## For 1 force, i.e. planar
            return item.unit'
        elseif n == 0 ## For 0 forces
            return zeros(0, 3)
        else
            error("Error.  Item is defined incorrectly.")
        end
    end

    for i in items

        ## If the item has one node
        if i isa rigid_point || i isa flex_point || i isa nh_point
            temp = norm(i.axis)
            if temp > 0
                i.unit = i.axis / temp  ## Normalize any non-unit axis vectors
            end
            temp = norm(i.rolling_axis)
            if temp > 0
                i.rolling_unit = i.rolling_axis / temp
            end
            if isa(i, flex_point)
                if size(i.d_mtx) == (0, 0)
                    i.d_mtx = diagm(
                        0 => [
                            i.damping[1] * ones(i.forces)
                            i.damping[2] * ones(i.moments)
                        ],
                    )
                end
                if size(i.s_mtx) == (0, 0)
                    i.s_mtx = diagm(
                        0 => [
                            i.stiffness[1] * ones(i.forces)
                            i.stiffness[2] * ones(i.moments)
                        ],
                    )
                end
            end

        ## If the item has two nodes
        elseif i isa link || i isa spring || i isa beam || i isa sensor || i isa actuator
            temp = i.location[2] - i.location[1]  ## Tempvec = vector from location1 to location2
            i.length = norm(temp)  ## New entry 'length' is the magnitude of the vector from location1 to location2
            if i.length > 0
                i.unit = temp / i.length  ## New entry 'unit' is the unit vector from location1 to location2
            end
            if !(i isa beam)
                i.forces = Int(!i.twist)
                i.moments = Int(i.twist)
            end
         end

        if !(i isa body) && !(i isa load)
            i.nu = nullspace(reshape(i.unit, 1, 3))  ## Find directions perp to beam axis
            if round(i.unit' * cross(i.nu[:, 1], i.nu[:, 2])) != 1  ## Make sure it's right handed
                i.nu = circshift(i.nu, [0, 1])
            end
            i.b_mtx[1] = build_b(i, :forces)
            i.b_mtx[2] = build_b(i, :moments)
        end
        
    end
end ## Leave

    ## find the normal to the triangle, but use Newell method rather than null()
    # ux=det([1 1 1;in(i).location(2:3,:)]);
    # uy=det([in(i).location(1,:);1 1 1;in(i).location(3,:)]);
    # uz=det([in(i).location(1:2,:);1 1 1]);
    # in(i).unit=[ux;uy;uz]/norm([ux;uy;uz]);

    # if(ismember(type,{'triangle_3s','triangle_5s'}))
    # 	for i=1:length(in)
    # 		in(i).mod_mtx=in(i).modulus/(1-in(i).psn_ratio^2)*[1 in(i).psn_ratio 0; in(i).psn_ratio 1 0; 0 0 0.5-in(i).psn_ratio/2];
    # 	end
    # end

    ##i.r=[i.nu i.unit];  ## Build the rotation matrix
    ## Find the locations in the new coordinate system, z is the same for all points in planar element
    ##i.local=i.r'*i.location


