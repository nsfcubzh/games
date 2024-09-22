
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\modules\\world_types.lua'] = {}
NSFLua['faint\\modules\\world_types.lua'].LAST_SECTION = ""
NSFLua['faint\\modules\\world_types.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local world_types = {}

world_types.block_codes = {
    water = 1,
    sand = 2,
    grass = 3,
    podzole = 4,
    gravel = 5,
    granite = 6,
    mountain = 7,
}

world_types.block_codes_reverse = {}
for key, value in pairs(world_types.block_codes) do
    world_types.block_codes_reverse[value] = key
end

world_types.object_codes = {
    none = 0,
    tree = 1,
    grass = 2,
    rock = 3,
    wall = 4,
    test = 5,
}

world_types.object_codes_reverse = {}
for key, value in pairs(world_types.object_codes) do
    world_types.object_codes_reverse[value] = key
end

world_types.covering_codes = {
    none = 0,
    floor = 1,
}

world_types.covering_codes_reverse = {}
for key, value in pairs(world_types.covering_codes) do
    world_types.covering_codes_reverse[value] = key
end

return world_types