local game = {}

function game.load()
    Debug.log("game() - game loaded.")

    local world = worldgen.Generate({width=128, height = 128})
    map = MutableShape()
    map:SetParent(World)
    map.Physics = PhysicsMode.StaticPerBlock
    map.Scale = 10

    worldgen.Build(world, map, 8, function()
        game.play()
    end)
end

function game.play()
    Debug.log("game() - joined world.")

    Player:SetParent(World)
    Player.Position = Number3(0, 0, 0)
    Camera.FOV = 50
    Camera.Tick = function(self, dt)
        Camera.Position = Player.Position + Number3(0, 250, -250)
        Camera.Forward = Player.Position - Camera.Position
    end
end

return game