local serializer = {}

serializer.block_codes = {
    water = 1,
    sand = 2,
    grass = 3,
    podzole = 4,
    gravel = 5,
    granite = 6,
    mountain = 7,
}

serializer.object_codes = {
    none = 0,
    tree = 1,
    grass = 2,
    rock = 3,
    wall = 4,
}

serializer.covering_codes = {
    none = 0,
    floor = 1,
}

-- Assuming we can create a new Data instance
function serializer.serialize(world)
    -- Create a new Data object
    local binary_data = Data()
    local width = #world.blocks
    local height = #world.blocks[1]
    for x = 1, width do
        for y = 1, height do
            local block = world.blocks[x][y]
            local object = world.objects[x][y] or "none"
            local covering = world.coverings[x][y] or "none"

            -- Write block and object codes
            local block_code = serializer.block_codes[block] or 0
            local object_code = serializer.object_codes[object] or 0
            local covering_code = serializer.covering_codes[covering] or 0
            binary_data:WriteUInt8(block_code)
            binary_data:WriteUInt8(object_code)
            binary_data:WriteUInt8(covering_code)
        end
    end
    binary_data:WriteUInt8(0) -- Optional end marker
    return binary_data
end

function serializer.deserialize(binary_data, width, height)
    local world = {
        blocks = {},
        objects = {},
        coverings = {},
        -- Initialize other types if needed
    }
    binary_data.Cursor = 1 -- Reset cursor to the beginning
    for x = 1, width do
        world.blocks[x] = {}
        world.objects[x] = {}
        world.coverings[x] = {}
        for y = 1, height do
            local object_code = binary_data:ReadUInt8()
            local covering_code = binary_data:ReadUInt8()
            local block_code = binary_data:ReadUInt8()

            -- Map codes back to names
            local block = "unknown"
            for name, code in pairs(serializer.block_codes) do
                if code == block_code then
                    block = name
                    break
                end
            end

            local object = "none"
            for name, code in pairs(serializer.object_codes) do
                if code == object_code then
                    object = name
                    break
                end
            end

            local covering = "none"
            for name, code in pairs(serializer.covering_codes) do
                if code == covering_code then
                    covering = name
                    break
                end
            end

            world.blocks[x][y] = block
            world.objects[x][y] = object
            world.coverings[x][y] = covering
        end
    end
    return world
end

return serializer