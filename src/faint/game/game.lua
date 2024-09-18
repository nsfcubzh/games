local game = {}

function game.load()
    Debug.log("game() - game loaded.")
    game.chunkScale = 8

    world = worldgen.Generate({width=128, height = 128})
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

            if cell.object ~= nil then
                local b = map:GetBlock(Number3(originalX, 0, originalY))
                b:remove()

                map:AddBlock(Color(255, 255, 255), originalX, 0, originalY)
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
                local b = map:GetBlock(Number3(originalX, 0, originalY))
                b:remove()
                
                local color = Color(255, 255, 255)

                if cell.block == "water" then
                    color = Color(114, 140, 176)
                elseif cell.block == "sand" then
                    color = Color(181, 175, 114)
                elseif cell.block == "grass" then
                    color = Color(98, 115, 69)
                elseif cell.block == "podzole" then
                    color = Color(91, 107, 63)
                elseif cell.block == "gravel" then
                    color = Color(87, 83, 81)
                elseif cell.block == "granite" then
                    color = Color(56, 55, 54)
                elseif cell.block == "mountain" then
                    color = Color(44, 45, 46)
                elseif cell.block == "floor" then
                    color = Color(101, 68, 40)
                end

                map:AddBlock(color, originalX, 0, originalY)
            end
        end
    end
end

return game