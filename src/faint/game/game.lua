local game = {}

function game.load()
    Debug.log("game() - game loaded.")
    game.chunkScale = 8

    game.mapScale = 256
    world = worldgen.Generate({width=game.mapScale, height = game.mapScale})
    game.data = {}
    game.coverings = {}
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
    for i = 1, game.mapScale do
        game.coverings[i] = {}
    end

    for i = 0, (game.mapScale/game.chunkScale)-1 do
        game.chunks[i] = {}
    end

    game.map = MutableShape()
    game.map:SetParent(World)
    game.map.Physics = PhysicsMode.StaticPerBlock
    game.map.Scale = 10
    game.map.Shadow = true

    HTTP:Get("https://raw.githubusercontent.com/nsfcubzh/games/main/build/faint/data/music.mp3", function(data)
        if data.StatusCode ~= 200 then
            print(f"Error downloading music: {data.StatusCode}")
        end
        game.music = AudioSource()
        game.music:SetParent(Camera)
        game.music.Sound = data.Body
        game.music.Loop = true
        game.music.Volume = 0.4
        game.music:Play()
    end)

    worldgen.Build(world, game.map, game.chunkScale, function()
        game.play()
    end)
end

function game.play()
    Debug.log("game() - joined world.")

    Player:SetParent(World)
    Player.Position = Number3(0, 0, 0)
    Camera.FOV = 25
    Player.cam = Object()

    Camera.Tick = function(self, dt)
        Camera.Position = Player.Position + Number3(0, 150, -150)
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
    Client.AnalogPad = nil
    Pointer.Drag = nil

    Player.CollisionBox = Box({-7.5, 0, -7.5}, {7.5, 29, 7.5})
    Player.Position = Number3(game.map.Width/2, 3, game.map.Depth/2) * game.map.Scale.X

    game.loadAmbience()
    game.initUI()
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

    local function fixedBox(box)
        return Box({0, 0, 0}, {box.Max.X-box.Min.X, box.Max.Y-box.Min.Y, box.Max.Z-box.Min.Z})
    end

    Timer(0.016*math.random(0, 3), false, function()
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
                elseif cell.object == "wall" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Wall()
                    game.data[originalX + 1][originalY + 1].update = function(self)
                        self.shape.Scale = 1/7
                        self.collider.Scale = 10/7
                        self.collider.Position = self.collider.Position - Number3(1.4, 0, 1.4)
                    end
                elseif cell.object == "test" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Test()
                end

                if cell.covering == "floor" then
                    game.coverings[originalX + 1][originalY + 1] = Game.Covering.Floor()
                    game.coverings[originalX + 1][originalY + 1].quad.Position = Number3(originalX, 1.01, originalY) * map.Scale.X
                    game.coverings[originalX + 1][originalY + 1].quad:SetParent(World)
                    game.coverings[originalX + 1][originalY + 1].quad.Color = Color(220, 220, 220)
                    game.coverings[originalX + 1][originalY + 1].quad.Scale = game.map.Scale.X
                end

                if game.data[originalX + 1][originalY + 1] ~= nil then
                    game.data[originalX + 1][originalY + 1].shape:SetParent(map)
                    game.data[originalX + 1][originalY + 1].shape.Scale = 0.07
                    game.data[originalX + 1][originalY + 1].shape.Position = Number3(originalX + 0.5, 1, originalY + 0.5) * map.Scale.X
                    game.data[originalX + 1][originalY + 1].shape.Physics = PhysicsMode.Disabled

                    if not game.data[originalX + 1][originalY + 1].disabledCollider then
                        game.data[originalX + 1][originalY + 1].collider = Object()
                        game.data[originalX + 1][originalY + 1].collider.CollisionBox = fixedBox(game.data[originalX + 1][originalY + 1].shape.CollisionBox)
                        local offsetx = (10 - game.data[originalX + 1][originalY + 1].collider.CollisionBox.Max.X)/2
                        local offsetz = (10 - game.data[originalX + 1][originalY + 1].collider.CollisionBox.Max.Z)/2
                        game.data[originalX + 1][originalY + 1].collider.Position = Number3(originalX, 1, originalY) * map.Scale.X + Number3(offsetx, 0, offsetz)
                        game.data[originalX + 1][originalY + 1].collider:SetParent(World)
                    end

                    if game.data[originalX + 1][originalY + 1].update ~= nil then
                        game.data[originalX + 1][originalY + 1]:update()
                    end
                end
            end
        end
    end)

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
                if not game.data[originalX + 1][originalY + 1].disabledCollider then
                    game.data[originalX + 1][originalY + 1].collider:SetParent(nil)
                    game.data[originalX + 1][originalY + 1].collider = nil
                end
                game.data[originalX + 1][originalY + 1]:Destroy()
                game.data[originalX + 1][originalY + 1] = nil
            end
        end
    end

    game.chunks[posX][posY] = false
end

function game.initUI()
    game.initInventory()
end

function game.initInventory()
    game.inventory = {
        data = {false, false, false, false, false},
    }

    local imageScale = Screen.Width/1920

    game.inventory.background = ui:createFrame(Color(85, 81, 54))
    game.inventory.background.Width = 10 + (#game.inventory.data * 100 + #game.inventory.data-1 * 5) * imageScale
    game.inventory.background.Height = 10 + 100 * imageScale
    game.inventory.background.pos = Number2(Screen.Width/2 - game.inventory.background.Width/2, 10)

    for i = 0, #game.inventory.data-1 do
        game.inventory.data[i] = ui:createFrame(Color(92, 88, 61))
        game.inventory.data[i].Width = 100 * imageScale
        game.inventory.data[i].Height = 100 * imageScale
        game.inventory.data[i].pos = Number2(game.inventory.background.pos.X + 10 + i * 105 * imageScale, 15)
    end
end

function game.loadAmbience()
    require("ambience"):set({
        sky = {
            skyColor = Color(0,168,255),
            horizonColor = Color(137,222,229),
            abyssColor = Color(76,144,255),
            lightColor = Color(153,179,182),
            lightIntensity = 0.580000,
        },
        fog = {
            color = Color(19,159,204),
            near = 300,
            far = 700,
            lightAbsorbtion = 0.400000,
        },
        sun = {
            color = Color(208,230,135),
            intensity = 0.890000,
            rotation = Number3(0.991350, 3.612823, 0.000000),
        },
        ambient = {
            skyLightFactor = 0.100000,
            dirLightFactor = 0.200000,
        }
    })
end

return game