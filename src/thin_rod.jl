function thin_rod(name::String, ends::Vector{Vector{Float64}}, mass::Union{Float64, Int64}; draw::Bool = false)

    # Copyright (C) 2013, Bruce Minaker
    # thin_rod finds the mass matrix and mass centre of a thin rod, given end locations

    len_vec = ends[2] - ends[1]
    i_mtx = -skew(len_vec)^2 * mass / 12

    item = body(name)
    item.mass = mass
    item.location = 0.5 * (ends[1] + ends[2])
    item.moments_of_inertia = diag(i_mtx)
    item.products_of_inertia = -[i_mtx[1, 2], i_mtx[2, 3], i_mtx[3, 1]]  # Change sign; using defn of Ixy as +ve integral

    hgt = norm(len_vec)

    if draw && hgt > 0

        if hgt > 0
            d = len_vec / hgt  ## Find the unit vector along the two points
            ax = cross([0, 1, 0], d)  ## Find the vector in the xz plane that is normal to the unit vector
            an = norm(ax)  ## Find the length of that vector
            if an > 0
                ax /= an  ## Find that unit vector if possible
            else
                ax = -d' * [0, 1, 0] * [1, 0, 0]  ## Otherwise, the original vector must have been along y axis, so choose x axis, times +/- 1
            end
            aa = zeros(4)
            aa[1:3] = ax  ## This the vector we must rotate around
            aa[4] = acos(d[2])  ## This is the angle we must rotate
            (aa[4] < 0) && (aa = -aa)   ## To get positive rotations, we choose the negative axis

        else
            aa = [0, 0, 1, 0]
        end

        aas = join(aa, " ")
        item.x3d = """
<Transform translation='0, 0, 0' rotation='$(aas)'>
 <Shape>
  <Cylinder height=$(hgt) radius=0.018></Cylinder>
  <Appearance>
   <Material emissiveColor='0.25 0.25 0.25' diffuseColor='0.25 0.25 0.25' specularColor='1 1 1' shininess='0.5' transparency='0'></Material>
  </Appearance>
 </Shape>
</Transform>"""
    end

    item
end


# && any(string.(Base.loaded_modules_array()) .== "EoM_X3D")