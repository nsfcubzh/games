
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\modules\\world_generator.lua'] = {}
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION = ""
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local worldgen = {}

function worldgen.Generate(config)
    --NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION = "WORLD GENERATION" NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION_LINE = 4 Debug.log("faint\\modules\\world_generator.lua > New section: '".."WORLD GENERATION".."' [Line: 4]")

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
                    grass = 1,
                    podzole = 2
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
                    grass = 0.8,
                    podzole = 1,
                    gravel = 2,
                }
            },
        },
        structures = {
            abandoned_room = {
                chance = 0.00015,
                min_scale = {5, 5},
                max_scale = {9, 9},
                floor = true,
                removed_walls = 0.8,
                removed_floors = 0.8,
                wall_type = "wood",
                floor_type = "wood",
                items = {
                    blue = {
                        chance = 0.01,
                    },
                    red = {
                        chance = 0.02,
                    },
                    black = {
                        chance = 0.01,
                    }
                },
                allowed_materials = {
                    sand = true,
                    grass = true,
                    podzole = true,
                    gravel = true,
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

    --Debug.log("world_generator - config saved in ["..cfg.."].")

    local world = {}
    perlin.seed(cfg.seed)

    --Debug.log("world_generator - generating landscape...")
    for x = 1, cfg.width do
        world[x] = {}
        for y = 1, cfg.height do
            world[x][y] = {}
            local cell = world[x][y]

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

            if height < 0 then
                cell.block = "debug"
            elseif height < cfg.waterLevel then
                cell.block = "water"
            elseif height < cfg.sandLevel then
                cell.block = "sand"
            elseif height < cfg.grassLevel then
                cell.block = "grass"
            elseif height < cfg.podzoleLevel then
                cell.block = "podzole"
            elseif height < cfg.gravelLevel then
                cell.block = "gravel"
            elseif height <= cfg.graniteLevel then
                cell.block = "granite"
            elseif height <= cfg.mountainLevel then
                cell.block = "mountain"
            else
                cell.block = "error"
            end
        end
    end
    --Debug.log("world_generator - placing structures...")
    local num_objects = 0
    local num_structures = 0
    for name, structure in pairs(cfg.structures) do
        for x = 1, cfg.width do
            for y = 1, cfg.height do
                --local cell = world[x][y]
                if math.random(0, worldgen.round(1/structure.chance)) == 0 then
                    local directions = {
                        x = {1, -1},
                        y = {1, -1},
                    }

                    local direction = {directions["x"][math.random(1, 2)], directions["y"][math.random(1, 2)]}
                    local scale = {math.random(structure.min_scale[1], structure.max_scale[1]), math.random(structure.min_scale[2], structure.max_scale[2])}

                    for i = 1, scale[1] do 
                        for j = 1, scale[2] do
                            local cell = nil
                            local cordX = x + (i * direction[1])
                            local cordY = y + (j * direction[2])

                            if world[cordX] ~= nil then
                                if world[cordX][cordY] ~= nil then
                                    cell = world[cordX][cordY]
                                end
                            end

                            local block = nil
                            if math.random(0, worldgen.round(1/(structure.removed_floors))) == 0 then
                                block = "floor"
                            end
                            
                            if cell ~= nil then
                                if structure.allowed_materials[cell.block] and block ~= nil then
                                    cell.block = block
                                end

                                for name, item in pairs(structure.items) do
                                    if math.random(0, worldgen.round(1/(structure.items[name].chance))) == 0 then
                                        if cell.object == nil and cell.block == "floor" then
                                            cell.object = name
                                        end
                                    end
                                end
                            end
                        end
                    end


                    for i = 0, scale[1] do
                        local cell = nil
                        local cordX = x + (i * direction[1])

                        if world[cordX] ~= nil then
                            if world[cordX][y] ~= nil then
                                cell = world[cordX][y]
                            end
                        end

                        local object = nil
                        if math.random(0, worldgen.round(1/(structure.removed_walls))) == 0 then
                            object = "wall"
                        end

                        if cell ~= nil then
                            if structure.allowed_materials[cell.block] and object ~= nil then
                                cell.object = object
                            end
                        end
                    end

                    for j = 1, scale[2] do
                        local cell = nil
                        local cordY = y + (j * direction[2])

                        if world[x] ~= nil then
                            if world[x][cordY] ~= nil then
                                cell = world[x][cordY]
                            end
                        end

                        local object = nil
                        if math.random(0, worldgen.round(1/(structure.removed_walls))) == 0 then
                            object = "wall"
                        end

                        if cell ~= nil then
                            if structure.allowed_materials[cell.block] and object ~= nil then
                                cell.object = object
                            end
                        end
                    end

                    for i = 1, scale[1] do
                        local cell = nil
                        local cordX = x + (i * direction[1])

                        if world[cordX] ~= nil then
                            if world[cordX][y] ~= nil then
                                cell = world[cordX][y+(direction[2]*scale[2])]
                            end
                        end

                        local object = nil
                        if math.random(0, worldgen.round(1/(structure.removed_walls))) == 0 then
                            object = "wall"
                        end

                        if cell ~= nil then
                            if structure.allowed_materials[cell.block] and object ~= nil then
                                cell.object = object
                            end
                        end
                    end

                    for j = 1, scale[2] do
                        local cell = nil
                        local cordY = y + (j * direction[2])

                        if world[x+(direction[1]*scale[1])] ~= nil then
                            if world[x][cordY] ~= nil then
                                cell = world[x+(direction[1]*scale[1])][cordY]
                            end
                        end

                        local object = nil
                        if math.random(0, worldgen.round(1/(structure.removed_walls))) == 0 then
                            object = "wall"
                        end

                        if cell ~= nil then
                            if structure.allowed_materials[cell.block] and object ~= nil then
                                cell.object = object
                                num_objects = num_objects + 1
                            end
                        end
                    end
                    num_structures = num_structures + 1
                end
            end
        end
    end
    --Debug.log("world_generator - Placed "..num_structures.." with "..num_objects.." objects inside.")
    
    --Debug.log("world_generator - placing objects...")
    local num_objects = 0
    for name, item in pairs(cfg.items) do
        perlin.seed(item.seed)

        for x = 1, cfg.width do
            for y = 1, cfg.height do
                local cell = world[x][y]

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

                if item.chances[cell.block] ~= nil then
                    chance = chance * item.chances[cell.block]
                end
    
                local result = math.random(0, worldgen.round(1/chance))

                if result == 0 and cell.object == nil and item.chances[cell.block] ~= nil then
                    cell.object = name
                    num_objects = num_objects + 1
                end
            end
        end
    end
    --Debug.log("world_generator - Placed "..num_objects.." objects.")
    --Debug.log("world_generator - World generation completed.")

    return world
end

function worldgen.Build(world, object, chunkScale)
    if world == nil then
        error("worldgen.Build(world) - 1st argument should be a world data.", 2)
    end

    local object_scale = (object.Scale.X + object.Scale.Y + object.Scale.Z)/3

    for chunkX = 1, #world/chunkScale-1 do
        for chunkY = 1, #world[1]/chunkScale-1 do
            Timer(chunkX/20*((#world[1]/chunkScale)/32), false, function()
                for x = 1, chunkScale do
                    for y = 1, chunkScale do
                        local originalX = x+(chunkX*chunkScale)
                        local originalY = y+(chunkY*chunkScale)

                        local color = Color(255, 255, 255)
                        local cell = world[originalX][originalY]

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
                            
                            object:AddBlock(Color(56, 55, 54), originalX, 1, originalY)
                        elseif cell.block == "mountain" then
                            color = Color(44, 45, 46)

                            object:AddBlock(Color(44, 45, 46), originalX, 1, originalY)
                            object:AddBlock(Color(44, 45, 46), originalX, 2, originalY)
                        elseif cell.block == "floor" then
                            color = Color(101, 68, 40)
                        end

                        if cell.object == "wall" then
                            local block2 = Block(Color(101, 68, 40), Number3(originalX, 1, originalY))

                            object:AddBlock(block2)
                        end

                        object:AddBlock(color, originalX, 0, originalY)
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

function worldgen.serializeTable(tbl, data)
    -- Iterate over the table
    for key, value in pairs(tbl) do
        -- Serialize based on type
        if type(value) == "number" then
            if math.floor(value) == value then
                -- Write integers
                if value >= -128 and value <= 127 then
                    data:WriteInt8(value)
                elseif value >= -32768 and value <= 32767 then
                    data:WriteInt16(value)
                elseif value >= -2147483648 and value <= 2147483647 then
                    data:WriteInt32(value)
                else
                    data:WriteNumber(value) -- For larger numbers
                end
            else
                -- Write floats
                data:WriteFloat(value)
            end
        elseif type(value) == "string" then
            data:WriteString(value)
        elseif type(value) == "table" then
            -- Serialize nested tables
            serializeTable(value, data)
        end
    end
end

function worldgen.serialize(tbl)
    local data = Data()
    worldgen.serializeTable(tbl, data)
    return data
end

function worldgen.deserializeTable(data, tbl)
    -- Keep reading bytes from the data until exhausted
    while data.Cursor < data.Length do
        local value = nil
        local byte = data:ReadByte()
        
        if byte >= 0 and byte <= 255 then
            -- Assuming the next byte is the data type identifier (for custom design)
            -- Deserialize accordingly. Add custom logic for specific data structures here
            -- Example:
            if byte == 1 then -- assuming 1 represents Int32
                value = data:ReadInt32()
            elseif byte == 2 then -- assuming 2 represents Float
                value = data:ReadFloat()
            elseif byte == 3 then -- assuming 3 represents String
                value = data:ReadString()
            end
            
            -- Insert value into the table
            table.insert(tbl, value)
        end
    end
end

function worldgen.deserialize(data)
    local tbl = {}
    worldgen.deserializeTable(data, tbl)
    return tbl
end

return worldgen