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
            local datacell = game.data[originalX+1][originalY+1]

            if cell.object == "tree" then
                datacell = Game.Object.Tree()
                datacell.shape.Position = Number3(originalX, 1, originalY)*map.Scale.X
            elseif cell.object == "rock" then
                datacell = Game.Object.Rock()
                datacell.shape.Position = Number3(originalX, 1, originalY)*map.Scale.X
            elseif cell.object == "grass" then
                datacell = Game.Object.Grass()
                datacell.shape.Position = Number3(originalX, 1, originalY)*map.Scale.X
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

            if cell.object ~= nil then
                game.data[originalX][originalY]:Destroy()
                game.data[originalX][originalY] = nil
            end
        end
    end
end

return game