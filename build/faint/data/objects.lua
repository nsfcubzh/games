
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\data\\objects.lua'] = {}
NSFLua['faint\\data\\objects.lua'].LAST_SECTION = ""
NSFLua['faint\\data\\objects.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Object:New({id = "Tree", model = "tree", type = "Shape"})
Game.Object:New({id = "Grass", model = "grass", type = "Shape"})
Game.Object:New({id = "Rock", model = "rock", type = "Shape"})