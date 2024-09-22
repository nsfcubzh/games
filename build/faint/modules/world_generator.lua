
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\modules\\world_generator.lua'] = {}
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION = ""
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local worldgen = {}

function worldgen.Generate(config)
    -- SECTION("WORLD GENERATION")

    if config == nil then
        error("worldgen.Generate(config) - 1st argument must be a table.")
    end

    local defaultConfig = {
        width = 320,
        height = 320,
        zoom = 0.02,
        seed = 1,
        octaves = 5,
        contrast = 1.3,
        erosion = 1.2,
        waterLevel = 0.3,
        sandLevel = 0.35,
        grassLevel = 0.55,
        podzoleLevel = 0.75,
        gravelLevel = 0.8,
        graniteLevel = 0.9,
        mountainLevel = 1,

        items = {
            tree = {
                zoom = 0.02,
                seed = 2,
                octaves = 1,
                chances = {
                    grass = 0.3,
                    podzole = 1.2
                }
            },
            grass = {
                zoom = 0.03,
                seed = 3,
                octaves = 1,
                chances = {
                    grass = 2,
                    podzole = 1
                }
            },
            rock = {
                zoom = 0.025,
                seed = 4,
                octaves = 2,
                chances = {
                    grass = 0.3,
                    podzole = 0.5,
                    gravel = 2,
                }
            },
        },
        structures = {
            abandoned_room = {
                chance = 0.0003,
                min_scale = {5, 5},
                max_scale = {9, 9},
                floor = true,
                removed_walls = 0.1,
                removed_floors = 0.05,
                wall_type = "wood",
                floor_type = "wood",
                items = {
                    test = {
                        chance = 0.03
                    },
                },
                allowed_materials = {
                    sand = true,
                    grass = true,
                    podzole = true,
                    gravel = true,
                    floor = true,
                }
            }
        }
    }
    local cfg = {}
    for key, value in pairs(defaultConfig) do
        cfg[key] = value
    end
    for key, value in pairs(config) do
        cfg[key] = value
    end
    local cfgtext = tostring(cfg)

    Debug.log("world_generator - config saved in ["..cfgtext.."].")

    local world = {
        blocks = {},
        objects = {},
        coverings = {},
        -- Add more types here if needed
    }
    perlin.seed(cfg.seed)

    Debug.log("world_generator - generating landscape...")
    for x = 1, cfg.width do
        world.blocks[x] = {}
        world.objects[x] = {}
        world.coverings[x] = {}
        for y = 1, cfg.height do
            local height = 0
            local amplitude = 1
            local frequency = 1
            local max_amp = 0

            for i = 1, cfg.octaves do
                local result = perlin.get(x * cfg.zoom * frequency, y * cfg.zoom * frequency)

                height = height + result * amplitude

                max_amp = max_amp + amplitude
                amplitude = amplitude / 2
                frequency = frequency * 2
            end

            height = (((height + 1) / 2)^cfg.erosion) * cfg.contrast

            height = math.min(math.max(height, 0), 1)

            local blockType = ""
            if height < 0 then
                blockType = "debug"
            elseif height < cfg.waterLevel then
                blockType = "water"
            elseif height < cfg.sandLevel then
                blockType = "sand"
            elseif height < cfg.grassLevel then
                blockType = "grass"
            elseif height < cfg.podzoleLevel then
                blockType = "podzole"
            elseif height < cfg.gravelLevel then
                blockType = "gravel"
            elseif height <= cfg.graniteLevel then
                blockType = "granite"
            elseif height <= cfg.mountainLevel then
                blockType = "mountain"
            else
                blockType = "error"
            end

            world.blocks[x][y] = blockType
            -- Initialize other types as nil
            world.objects[x][y] = nil
            world.coverings[x][y] = nil
        end
    end

    Debug.log("world_generator - placing structures...")
    local num_objects = 0
    local num_structures = 0
    for name, structure in pairs(cfg.structures) do
        for x = 1, cfg.width do
            for y = 1, cfg.height do
                if math.random(0, worldgen.round(1/structure.chance)) == 0 then
                    local directions = {
                        x = {1, -1},
                        y = {1, -1},
                    }

                    local direction = {directions["x"][math.random(1, 2)], directions["y"][math.random(1, 2)]}
                    local scale = {math.random(structure.min_scale[1], structure.max_scale[1]), math.random(structure.min_scale[2], structure.max_scale[2])}

                    for i = 1, scale[1] do 
                        for j = 1, scale[2] do
                            local cordX = x + (i * direction[1])
                            local cordY = y + (j * direction[2])

                            if world.blocks[cordX] ~= nil and world.blocks[cordX][cordY] ~= nil then
                                local block = world.blocks[cordX][cordY]
                                local object = world.objects[cordX][cordY]
                                local covering = world.coverings[cordX][cordY]

                                local coveringType = nil
                                if math.random() > structure.removed_floors then
                                    coveringType = "floor"
                                end

                                if structure.allowed_materials[block] and coveringType ~= nil then
                                    world.coverings[cordX][cordY] = coveringType
                                else
                                    world.coverings[cordX][cordY] = "none"
                                end

                                for itemName, item in pairs(structure.items) do
                                    if math.random(0, worldgen.round(1/(item.chance))) == 0 then
                                        if world.objects[cordX][cordY] == nil and world.coverings[cordX][cordY] == "floor" then
                                            world.objects[cordX][cordY] = itemName
                                            num_objects = num_objects + 1
                                        end
                                    end
                                end
                            end
                        end
                    end

                    -- Place walls
                    local function placeWall(cordX, cordY)
                        if world.blocks[cordX] ~= nil and world.blocks[cordX][cordY] ~= nil then
                            local block = world.blocks[cordX][cordY]
                            if structure.allowed_materials[block] and math.random() > structure.removed_walls then
                                world.objects[cordX][cordY] = "wall"
                            end
                        end
                    end

                    for i = 0, scale[1] do
                        local cordX = x + (i * direction[1])
                        local cordY = y
                        placeWall(cordX, cordY)
                    end

                    for j = 1, scale[2] do
                        local cordX = x
                        local cordY = y + (j * direction[2])
                        placeWall(cordX, cordY)
                    end

                    for i = 1, scale[1] do
                        local cordX = x + (i * direction[1])
                        local cordY = y + (direction[2] * scale[2])
                        placeWall(cordX, cordY)
                    end

                    for j = 1, scale[2] do
                        local cordX = x + (direction[1] * scale[1])
                        local cordY = y + (j * direction[2])
                        placeWall(cordX, cordY)
                    end

                    num_structures = num_structures + 1
                end
            end
        end
    end
    Debug.log("world_generator - placed "..num_structures.." structures with "..num_objects.." objects inside.")

    Debug.log("world_generator - placing objects...")
    num_objects = 0
    for name, item in pairs(cfg.items) do
        perlin.seed(item.seed)

        for x = 1, cfg.width do
            for y = 1, cfg.height do
                local block = world.blocks[x][y]
                local object = world.objects[x][y]
                local covering = world.coverings[x][y]

                local chance = 0
                local amplitude = 1
                local frequency = 1
                local max_amp = 0

                for i = 1, item.octaves do
                    local result = perlin.get(x * item.zoom * frequency, y * item.zoom * frequency)

                    chance = chance + result * amplitude

                    max_amp = max_amp + amplitude
                    amplitude = amplitude / 2
                    frequency = frequency * 2
                end

                chance = ((chance + 1) / 2)^4

                if item.chances[block] ~= nil then
                    chance = chance * item.chances[block]
                else
                    chance = 0
                end

                if chance > 0 and math.random() < chance and object == nil and covering == nil then
                    world.objects[x][y] = name
                    num_objects = num_objects + 1
                else
                    world.objects[x][y] = "none"
                end
            end
        end
    end
    Debug.log("world_generator - placed "..num_objects.." objects.")
    Debug.log("world_generator - World generation completed.")

    return world
end

function worldgen.Build(world, object, chunkScale, callback)
    if world == nil then
        error("worldgen.Build(world, object, chunkScale, callback) - 1st argument should be a world data.", 3)
    elseif object == nil then
        error("worldgen.Build(world, object, chunkScale, callback) - 2nd argument should be an mutableshape object.", 3)
    elseif chunkScale == nil then
        chunkScale = 8
    elseif callback == nil then
        callback = function() end
    end

    Debug.log("world_generator - building world with "..chunkScale.." chunk scale...")
    local total_chunks = 0

    local object_scale = (object.Scale.X + object.Scale.Y + object.Scale.Z)/3

    local width = #world.blocks
    local height = #world.blocks[1]

    for chunkX = 0, width/chunkScale-1 do
        for chunkY = 0, height/chunkScale-1 do
            Timer(chunkX/20*((height/chunkScale)/32), false, function()
                total_chunks = total_chunks + 1
                for x = 1, chunkScale do
                    for y = 1, chunkScale do
                        local originalX = x+(chunkX*chunkScale)
                        local originalY = y+(chunkY*chunkScale)

                        local color = Color(255, 255, 255)
                        local blockType = world.blocks[originalX][originalY]
                        local objectType = world.objects[originalX][originalY]
                        local coveringType = world.coverings[originalX][originalY]

                        if blockType == "water" then
                            color = Color(114, 140, 176)
                        elseif blockType == "sand" then
                            color = Color(181, 175, 114)
                        elseif blockType == "grass" then
                            color = Color(98, 115, 69)
                        elseif blockType == "podzole" then
                            color = Color(91, 107, 63)
                        elseif blockType == "gravel" then
                            color = Color(87, 83, 81)
                        elseif blockType == "granite" then
                            color = Color(56, 55, 54)
                        elseif blockType == "mountain" then
                            color = Color(44, 45, 46)
                        end

                        if math.random(0, 1) == 0 then
                            color = Color(color.R+2, color.G+2, color.B+2)
                        end
                        if math.random(0, 1) == 0 then
                            color = Color(color.R-2, color.G-2, color.B-2)
                        end

                        object:AddBlock(color, originalX-1, 0, originalY-1)

                        if blockType == "granite" then
                            object:AddBlock(color, originalX-1, 1, originalY-1)
                        elseif blockType == "mountain" then
                            object:AddBlock(color, originalX-1, 1, originalY-1)
                            object:AddBlock(color, originalX-1, 2, originalY-1)
                        end

                        if chunkX == width/chunkScale-1 and chunkY == height/chunkScale-1 and x == chunkScale and y == chunkScale then
                            local total_blocks = total_chunks*chunkScale*chunkScale
                            Debug.log("world_generator - building world completed.")
                            Debug.log("world_generator - Total chunks: ["..total_chunks.."].")
                            Debug.log("world_generator - Total blocks: ["..total_blocks.."].")
                            callback()
                        end
                    end
                end
            end)
        end
    end
end

function worldgen.round(value)
    if value > 0.5 then
        return math.ceil(value)
    else
        return math.floor(value)
    end
end

return worldgen