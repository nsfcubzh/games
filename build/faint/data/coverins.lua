
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\data\\coverins.lua'] = {}
NSFLua['faint\\data\\coverins.lua'].LAST_SECTION = ""
NSFLua['faint\\data\\coverins.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Covering:New({id = "Floor", image = "floor", type = "Image", Init = function(self)
    self.quad.Rotation.X = math.pi/2
end})