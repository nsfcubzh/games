
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\data\\objects.lua'] = {}
NSFLua['faint\\data\\objects.lua'].LAST_SECTION = ""
NSFLua['faint\\data\\objects.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Object:New({id = "Tree", model = "tree", type = "Shape", Init = function(self)
    self.shape.Rotation.Y = math.random(-314, 314)*0.01
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
end})
Game.Object:New({id = "Grass", model = "grass", type = "Shape", Init = function(self)
    self.shape.Rotation.Y = math.random(-314, 314)*0.01
    self.shape.Shadow = true
end})
Game.Object:New({id = "Rock", model = "rock", type = "Shape", Init = function(self)
    self.shape.Rotation.Y = math.random(-314, 314)*0.01
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
end})