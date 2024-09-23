local serializer = {}

function serializer.serialize(world, width, height)
    local world_data = {blocks = Data(), objects = Data(), coverings = Data()}

    for x = 1, width do
        for y = 1, height do
            local block = world.blocks[x][y]
            local object = world.objects[x][y]
            local covering = world.coverings[x][y]

            world_data.blocks:WriteUInt8(block)
            world_data.objects:WriteUInt8(object)
            world_data.coverings:WriteUInt8(covering)
        end
    end

    return world_data
end

function serializer.deserialize(world_data, width, height)
    local world = {
        blocks = {},
        objects = {},
        coverings = {},
    }

    world_data.blocks.Cursor = 0
    world_data.objects.Cursor = 1
    world_data.coverings.Cursor = 1

    for x = 1, width do
        world.blocks[x] = {}
        world.objects[x] = {}
        world.coverings[x] = {}
        for y = 1, height do
            local object = world_data.objects:ReadUInt8()
            local covering = world_data.coverings:ReadUInt8()
            local block = world_data.blocks:ReadUInt8()

            world.blocks[x][y] = block
            world.objects[x][y] = object
            world.coverings[x][y] = covering
        end
    end
    return world
end

return serializer