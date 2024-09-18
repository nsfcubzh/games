
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

    game.mapScale = 256
    world = worldgen.Generate({width=game.mapScale, height = game.mapScale})
    game.data = {}
    game.chunks = {}

    game.chunkMap = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 1, 1, 1, 1, 1, 0},
        {0, 1, 1, 1, 1, 1, 0},
        {0, 1, 1, 1, 1, 1, 0},
        {0, 1, 1, 1, 1, 1, 0},
        {0, 1, 1, 1, 1, 1, 0},
        {0, 0, 0, 0, 0, 0, 0},
    }

    for i = 1, game.mapScale do
        game.data[i] = {}
    end

    for i = 0, (game.mapScale/game.chunkScale)-1 do
        game.chunks[i] = {}
    end

    game.map = MutableShape()
    game.map:SetParent(World)
    game.map.Physics = PhysicsMode.StaticPerBlock
    game.map.Scale = 10

    worldgen.Build(world, game.map, game.chunkScale, function()
        game.play()
    end)
end

function game.play()
    Debug.log("game() - joined world.")

    Player:SetParent(World)
    Player.Position = Number3(0, 0, 0)
    Camera.FOV = 15
    Player.cam = Object()

    Camera.Tick = function(self, dt)
        Camera.Position = Player.Position + Number3(0, 250, -250)
        Camera.Forward = (Player.Position + Number3(0, 5, 0)) - Camera.Position
        game.updateChunks(Player.Position)

        if Player.Motion ~= Number3(0, 0, 0) then
            Player.Rotation:Slerp(Player.Rotation, Player.cam.Rotation, 0.2)
        end
    end

    Client.DirectionalPad = function(x, y)
        Player.Motion = Number3(x, 0, y) * 50
        Player.cam.Forward = Number3(x+(math.random(-10, 10)*0.002), 0, y+(math.random(-10, 10)*0.002))
    end
    Client.AnalogPad = function(dx, dy)
        return
    end
    Player.CollisionBox = Box({-7.5, 0, -7.5}, {7.5, 29, 7.5})
    Player.Position = Number3(game.map.Width/2, 3, game.map.Depth/2) * game.map.Scale.X
end

function game.updateChunks(pos)
    local fixedpos = pos / game.map.Scale.X
    local chunkX = math.floor(fixedpos.X / game.chunkScale)
    local chunkY = math.floor(fixedpos.Z / game.chunkScale)

    for x = 1, #game.chunkMap do
        for y = 1, #game.chunkMap[x] do
            local fx = chunkX + (x - math.ceil(#game.chunkMap / 2))
            local fy = chunkY + (y - math.ceil(#game.chunkMap[x] / 2))

            if game.chunkMap[x][y] == 0 then
                if game.chunks[fx] and game.chunks[fx][fy] then
                    game.unloadChunk(game.map, fx, fy)
                end
            elseif game.chunkMap[x][y] == 1 then
                if not (game.chunks[fx] and game.chunks[fx][fy]) then
                    game.loadChunk(game.map, fx, fy)
                end
            end
        end
    end
end

function game.loadChunk(map, posX, posY)
    if not game.chunks[posX] then
        game.chunks[posX] = {}
    end

    for x = 1, game.chunkScale do
        for y = 1, game.chunkScale do
            local originalX = x + (posX * game.chunkScale) - 1
            local originalY = y + (posY * game.chunkScale) - 1

            local cell = world[originalX + 1][originalY + 1]

            if cell.object == "tree" then
                game.data[originalX + 1][originalY + 1] = Game.Object.Tree()
            elseif cell.object == "rock" then
                game.data[originalX + 1][originalY + 1] = Game.Object.Rock()
            elseif cell.object == "grass" then
                game.data[originalX + 1][originalY + 1] = Game.Object.Grass()
            end

            if game.data[originalX + 1][originalY + 1] ~= nil then
                game.data[originalX + 1][originalY + 1].shape:SetParent(map)
                game.data[originalX + 1][originalY + 1].shape.Scale = 0.07
                game.data[originalX + 1][originalY + 1].shape.Position = Number3(originalX + 0.5, 1, originalY + 0.5) * map.Scale.X
            end
        end
    end

    game.chunks[posX][posY] = true
end

function game.unloadChunk(map, posX, posY)
    if not game.chunks[posX] or not game.chunks[posX][posY] then
        return
    end

    for x = 1, game.chunkScale do
        for y = 1, game.chunkScale do
            local originalX = x + (posX * game.chunkScale) - 1
            local originalY = y + (posY * game.chunkScale) - 1

            if game.data[originalX + 1][originalY + 1] ~= nil then
                game.data[originalX + 1][originalY + 1]:Destroy()
                game.data[originalX + 1][originalY + 1] = nil
            end
        end
    end

    game.chunks[posX][posY] = false
end


return game