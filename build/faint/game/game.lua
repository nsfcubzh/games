
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

    worldgen.Build(world, map, 8, function()
        game.play()
    end)
end

function game.play()
    Debug.log("game() - joined world.")

    Player:SetParent(World)
    Camera.Tick = function(self, dt)
        Camera.Position = Player.Position + Number3(0, 50, -50)
        Camera.Forward = Player.Position - Camera.Position
    end
end

return game