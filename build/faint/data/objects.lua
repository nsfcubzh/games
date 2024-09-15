
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\data\\objects.lua'] = {}
NSFLua['faint\\data\\objects.lua'].LAST_SECTION = ""
NSFLua['faint\\data\\objects.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Object:New({id = "Tree", model = shapes["tree"], type = "Shape"})
Game.Object:New({id = "Grass", model = shapes["grass"], type = "Shape"})
Game.Object:New({id = "Rock", model = shapes["rock"], type = "Shape"})