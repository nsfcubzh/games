
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\game\\game.lua'] = {}
NSFLua['faint\\game\\game.lua'].LAST_SECTION = ""
NSFLua['faint\\game\\game.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local game = {}

function game.load()
    Debug.log("game() - game loaded.")
    game.chunkScale = 8

    world = worldgen.Generate({width=128, height = 128})
    game.data = {}
    for x = 1, 128 do
        game.data[x] = {}
    end

    map = MutableShape()
    map:SetParent(World)
    map.Physics = PhysicsMode.StaticPerBlock
    map.Scale = 10

    worldgen.Build(world, map, game.chunkScale, function()
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

function game.loadChunk(map, posX, posY)
    for x = 1, game.chunkScale do
        for y = 1, game.chunkScale do
            local originalX = x+(posX*game.chunkScale)-1
            local originalY = y+(posY*game.chunkScale)-1

            local cell = world[originalX+1][originalY+1]

            if cell.object == "tree" then
                game.data[originalX+1][originalY+1] = Game.Object.Tree()
            elseif cell.object == "rock" then
                game.data[originalX+1][originalY+1] = Game.Object.Rock()
            elseif cell.object == "grass" then
                game.data[originalX+1][originalY+1] = Game.Object.Grass()
            end

            if game.data[originalX+1][originalY+1] ~= nil then
                game.data[originalX+1][originalY+1].shape:SetParent(map)
                game.data[originalX+1][originalY+1].shape.Scale = 0.07
                game.data[originalX+1][originalY+1].shape.Position = Number3(originalX+0.5, 1, originalY+0.5)*map.Scale.X
            end
        end
    end
end

function game.unloadChunk(map, posX, posY)
    for x = 1, game.chunkScale do
        for y = 1, game.chunkScale do
            local originalX = x+(posX*game.chunkScale)-1
            local originalY = y+(posY*game.chunkScale)-1

            local cell = world[originalX+1][originalY+1]

            if game.data[originalX+1][originalY+1] ~= nil then
                game.data[originalX+1][originalY+1]:Destroy()
                game.data[originalX+1][originalY+1] = nil
            end
        end
    end
end

return game