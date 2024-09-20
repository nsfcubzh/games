
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
    self.disabledCollider = true
end})
Game.Object:New({id = "Rock", model = "rock", type = "Shape", Init = function(self)
    self.shape.Rotation.Y = math.random(-314, 314)*0.01
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
    self.shape.CollisionBox = Box(
        {self.shape.CollisionBox.Min.X+2, self.shape.CollisionBox.Min.Y, self.shape.CollisionBox.Min.Z+2},
        {self.shape.CollisionBox.Max.X-2, self.shape.CollisionBox.Max.Y, self.shape.CollisionBox.Max.Z-2}
    )
end})
Game.Object:New({id = "Wall", model = "wall_wood", type = "Shape", Init = function(self)
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
end})
Game.Object:New({id = "Test", model = "test", type = "Shape", Init = function(self)
    self.shape.Pivot = Number3(self.shape.Width/2, 0, self.shape.Depth/2)
    self.shape.Shadow = true
end})