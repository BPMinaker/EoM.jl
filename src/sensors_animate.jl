function sensors_animate!(the_system::mbd_system)

    deleteat!(the_system.item, findall(typeof.(the_system.item) .== sensor))

    for i in the_system.item[typeof.(the_system.item) .== body]
        for j in 1:6
            idx = j
            twist = false
            if idx > 3
                twist = true
                idx -=3
            end
            offset = zeros(3)
            offset[idx] = -1
            item = sensor(i.name * "_$j")
            item.body[1] = i.name
            item.body[2] = "ground"
            item.location[1] = i.location
            item.location[2] = i.location + offset
            item.twist = twist
            add_item!(item, the_system)
        end
    end

    nothing
end