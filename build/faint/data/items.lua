
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\data\\items.lua'] = {}
NSFLua['faint\\data\\items.lua'].LAST_SECTION = ""
NSFLua['faint\\data\\items.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Item:New({id = "Tree", model = "tree", name = "Tree"})
Game.Item:New({id = "Rock", model = "rock", name = "Rock"})