
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
            print("Error downloading music: "..data.StatusCode.."")
        end
        game.music = AudioSource()
        game.music:SetParent(Camera)
        game.music.Sound = data.Body
        game.music.Loop = true
        game.music.Volume = 0.4
        game.music:Play()
    end)

    local get = Network.Event("getWorld", {})
    get:SendTo(Server)

    game.event = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
        Network:ParseEvent(e, {
            loadWorld = function(event)
                Debug.log("game() - received world with "..event.data.blocks.Length.." blocks, "..event.data.objects.Length.." objects and "..event.data.coverings.Length.." coverings.")
                print(event.data.blocks.Length, event.data.objects.Length, event.data.coverings.Length)

                world = worldser.deserialize({blocks = event.data.blocks, objects = event.data.objects, coverings = event.data.coverings}, event.data.scale, event.data.scale)
                for i=1, event.data.blocks.Length do
                    print(event.data.blocks[i])
                end
                worldgen.Build(world, game.map, game.chunkScale, function()
                    game.play()
                end)
            end,

            ["_"] = function(event)
                local name = ""
                if event.Sender.Username ~= nil then
                    name = event.Sender.Username
                else
                    name = "Server"
                end
                local data = ""
                if event.data ~= nil then
                    data = JSON:Encode(event.data)
                end
                Debug.log("game() - got unknown event: "..tostring(event.action).." from "..name.." with data: "..data.."")
            end,
        })
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
    Client.AnalogPad = function() end
    Pointer.Drag = function() end

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

                local objectType = world_types.object_codes_reverse[world.objects[originalX][originalY]] or "none"
                local coveringType = world_types.covering_codes_reverse[world.coverings[originalX][originalY]] or "none"

                if objectType == "tree" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Tree()
                elseif objectType == "rock" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Rock()
                elseif objectType == "grass" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Grass()
                elseif objectType == "wall" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Wall()
                    game.data[originalX + 1][originalY + 1].update = function(self)
                        self.shape.Scale = 1/7
                        self.collider.Scale = 10/7
                        self.collider.Position = self.collider.Position - Number3(1.4, 0, 1.4)
                    end
                elseif objectType == "test" then
                    game.data[originalX + 1][originalY + 1] = Game.Object.Test()
                end

                if coveringType == "floor" then
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

    game.backUi = ui:createFrame(Color(0, 0, 0, 0))
    game.backUi.Width = Screen.Width
    game.backUi.Height = Screen.Height

    game.inventory.background = ui:createFrame(Color(85, 81, 54))
    game.inventory.background.Width = 5 + (#game.inventory.data * 105) * imageScale
    game.inventory.background.Height = 10 + 100 * imageScale
    game.inventory.background.pos = Number2(Screen.Width/2 - game.inventory.background.Width/2, 10)

    game.inventory.buttons = {}
    for i = 1, #game.inventory.data do
        game.inventory.buttons[i] = ui:createFrame(Color(92, 88, 61))
        game.inventory.buttons[i].Width = 100 * imageScale
        game.inventory.buttons[i].Height = 100 * imageScale
        game.inventory.buttons[i].pos = Number2(game.inventory.background.pos.X + 5 + i * 105 * imageScale-5-(100 * imageScale), 15)
    end
    -- listeners
    game.inventory.dragTimer = 0
    game.inventory.drag = LocalEvent:Listen(LocalEvent.Name.PointerDrag, function(pe)
        -- calls when pointer is down and moving
        local pe = Number2(pe.X*Screen.Width, pe.Y*Screen.Height)
        if game.inventory.clicked and game.inventory.dragTimer > 3 then
            if game.inventory.buttons[game.inventory.selected].content ~= nil then
                game.inventory.buttons[game.inventory.selected].content.pos = Number2(
                    pe.X - game.inventory.buttons[game.inventory.selected].content.Width/2,
                    pe.Y - game.inventory.buttons[game.inventory.selected].content.Height/2
                )
            end

            game.inventory.dragging = true

        end
    end, {topPriority = true})
    game.inventory.down = LocalEvent:Listen(LocalEvent.Name.PointerDown, function(pe)
        -- calls when pointer is down, clicking or touching screen
        local pe = Number2(pe.X*Screen.Width, pe.Y*Screen.Height)
        for i=1, #game.inventory.buttons do
            local buttonpos = game.inventory.buttons[i].pos
            local buttonscale = Number2(game.inventory.buttons[i].Width, game.inventory.buttons[i].Height)
            if pe.X >= buttonpos.X and pe.X <= buttonpos.X + buttonscale.X and pe.Y >= buttonpos.Y and pe.Y <= buttonpos.Y + buttonscale.Y then
                game.inventory.clicked = true
                game.inventory.dragTimer = 0
                game.inventory.selected = i
            end
        end

    end, {topPriority = true})
    game.inventory.up = LocalEvent:Listen(LocalEvent.Name.PointerUp, function(pe)
        -- calls when pointer is up, clicking end or untouching screen

        local pe = Number2(pe.X*Screen.Width, pe.Y*Screen.Height)
        for i=1, #game.inventory.buttons do
            local buttonpos = game.inventory.buttons[i].pos
            local buttonscale = Number2(game.inventory.buttons[i].Width, game.inventory.buttons[i].Height)
            if pe.X >= buttonpos.X and pe.X <= buttonpos.X + buttonscale.X and pe.Y >= buttonpos.Y and pe.Y <= buttonpos.Y + buttonscale.Y then
                if game.inventory.buttons[i].content.text ~= nil then
                    game.inventory.buttons[i].content.text:remove()
                    game.inventory.buttons[i].content.text = nil
                end
                if game.inventory.buttons[game.inventory.selected].content.text ~= nil then
                    game.inventory.buttons[game.inventory.selected].content.text:remove()
                    game.inventory.buttons[game.inventory.selected].content.text = nil
                end
                if game.inventory.clicked and game.inventory.dragging and game.inventory.buttons[game.inventory.selected].content ~= nil then
                    if game.inventory.selected ~= i then
                        game.inventory.data[i], game.inventory.data[game.inventory.selected] = game.inventory.data[game.inventory.selected], game.inventory.data[i]
                        game.inventory.buttons[i].content, game.inventory.buttons[game.inventory.selected].content = game.inventory.buttons[game.inventory.selected].content, game.inventory.buttons[i].content
                        game.inventory.buttons[i].content.pos = Number2(game.inventory.buttons[i].pos.X + 5, game.inventory.buttons[i].pos.Y + 5)

                        if game.inventory.buttons[game.inventory.selected].content ~= nil then
                            game.inventory.buttons[game.inventory.selected].content.pos = Number2(game.inventory.buttons[game.inventory.selected].pos.X + 5, game.inventory.buttons[game.inventory.selected].pos.Y + 5)
                        end
                    else
                        game.inventory.buttons[game.inventory.selected].content.pos = Number2(game.inventory.buttons[game.inventory.selected].pos.X + 5, game.inventory.buttons[game.inventory.selected].pos.Y + 5)
                    end
                end

                game.inventory.clicked = false
                game.inventory.dragging = false
                game.inventory.updateSlot(i)
                game.inventory.updateSlot(game.inventory.selected)
            end
        end
        if game.inventory.clicked then
            print("Removed cursor out of bounds.")

            if game.inventory.buttons[game.inventory.selected].content ~= nil then
                game.inventory.buttons[game.inventory.selected].content.pos = Number2(game.inventory.buttons[game.inventory.selected].pos.X + 5, game.inventory.buttons[game.inventory.selected].pos.Y + 5)
            end
            game.inventory.clicked = false
            game.inventory.dragging = false
        end
    end, {topPriority = true})

    game.inventory.tick = LocalEvent:Listen(LocalEvent.Name.Tick, function(dt)
        if game.inventory.clicked then
            game.inventory.dragTimer = game.inventory.dragTimer + dt*60
        end
    end, {topPriority = true})

    -- functions
        
    function game.inventory.insertItem(item, slot)
        if not game.inventory.data[slot] then
            game.inventory.data[slot] = item
            game.inventory.buttons[slot].content = ui:createShape(item.shape)
            game.inventory.buttons[slot].content.pos = Number2(game.inventory.buttons[slot].pos.X + 5, game.inventory.buttons[slot].pos.Y + 5)
            game.inventory.buttons[slot].content.Width = game.inventory.buttons[slot].Width - 10
            game.inventory.buttons[slot].content.Height = game.inventory.buttons[slot].Height - 10
            game.inventory.updateSlot(slot)
        end
    end

    function game.inventory.removeItem(slot)
        if game.inventory.data[slot] then
            game.inventory.buttons[slot].content:remove()
            game.inventory.buttons[slot].content = nil
            game.inventory.data[slot] = false
        end
    end

    function game.inventory.updateSlot(slot)
        if game.inventory.data[slot] then
            if game.inventory.data[slot].count > 1 then
                if game.inventory.buttons[slot].content.text ~= nil then
                    game.inventory.buttons[slot].content.text:remove()
                    game.inventory.buttons[slot].content.text = nil
                end
                game.inventory.buttons[slot].content.text = ui:createText(game.inventory.data[slot].count, Color(255, 255, 255))
                game.inventory.buttons[slot].content.text.pos = Number2(
                    game.inventory.buttons[slot].pos.X + 100*imageScale - game.inventory.buttons[slot].content.text.Width,
                    game.inventory.buttons[slot].pos.Y + 5
                )
            else
                if game.inventory.buttons[slot].content.text ~= nil then
                    game.inventory.buttons[slot].content.text:remove()
                    game.inventory.buttons[slot].content.text = nil
                end
            end
        end
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