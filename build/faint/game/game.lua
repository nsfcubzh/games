
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\game\\game.lua'] = {}
NSFLua['faint\\game\\game.lua'].LAST_SECTION = ""
NSFLua['faint\\game\\game.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

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
    Camera.FOV = 15
    Camera.Tick = function(self, dt)
        Camera.Position = Player.Position + Number3(0, 250, -250)
        Camera.Forward = (Player.Position + Number3(0, 5, 0)) - Camera.Position
    end
end

return game