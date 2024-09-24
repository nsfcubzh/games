
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\modules\\world_serializer.lua'] = {}
NSFLua['faint\\modules\\world_serializer.lua'].LAST_SECTION = ""
NSFLua['faint\\modules\\world_serializer.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local serializer = {}

function serializer.serialize(world, width, height)
    local world_data = {blocks = Data(), objects = Data(), coverings = Data()}

    world_data.blocks.Cursor = 0
    world_data.objects.Cursor = 0
    world_data.coverings.Cursor = 0
    
    for x = 1, width do
        local block_row = world.blocks[x]
        local object_row = world.objects[x]
        local covering_row = world.coverings[x]
        for y = 1, height do
            world_data.blocks:WriteUInt8(block_row[y])
            world_data.objects:WriteUInt8(object_row[y])
            world_data.coverings:WriteUInt8(covering_row[y])
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
    world_data.objects.Cursor = 0
    world_data.coverings.Cursor = 0

    for x = 1, width do
        local block_row = {}
        local object_row = {}
        local covering_row = {}

        for y = 1, height do
            object_row[y] = world_data.objects:ReadUInt8()
            covering_row[y] = world_data.coverings:ReadUInt8()
            block_row[y] = world_data.blocks:ReadUInt8()
        end

        world.blocks[x] = block_row
        world.objects[x] = object_row
        world.coverings[x] = covering_row
    end
    return world
end

return serializer