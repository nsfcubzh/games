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
Game.Object:New({id = "Wall", model = "wall_wood", type = "Shape", Init = function(self)
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
end})
Game.Object:New({id = "Test", model = "test", type = "Shape", Init = function(self)
    self.shape.Pivot.Y = 0
    self.shape.Shadow = true
end})