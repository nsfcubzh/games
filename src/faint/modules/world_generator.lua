local worldgen = {}

function worldgen.Generate(config) 
    if config == nil then
        error("worldgen.Generate(config) - 1st argument must be a table.")
    end

    local defaultConfig = {
        width = 64,
        height = 200,
        zoom = 0.1,
        seed = 1,
        octaves = 3,
        contrast = 1.1,
        erosion = 1.1,
        waterLevel = 0.3,
        sandLevel = 0.35,
        grassLevel = 0.55,
        podzoleLevel = 0.75,
        gravelLevel = 0.8,
        graniteLevel = 1,

        plants = {
            tree = {
                zoom = 0.02,
                seed = 2,
                octaves = 1,
                chances = {
                    grass = 0.05,
                    podzole = 0.6
                }
            },
            grass = {
                zoom = 0.03,
                seed = 3,
                octaves = 1,
                chances = {
                    grass = 0.5,
                    podzole = 0.2
                }
            },
        }
    }
    local cfg = {}
    for key, value in pairs(defaultConfig) do
        cfg[key] = value
    end
    for key, value in pairs(config) do
        cfg[key] = value
    end

    local world = {}
    perlin.seed(cfg.seed)
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
            else
                cell.block = "error"
            end
        end
    end
    for name, plant in pairs(cfg.plants) do
        perlin.seed(plant.seed)

        for x = 1, cfg.width do
            for y = 1, cfg.height do
                local cell = world[x][y]

                local chance = 0
                local amplitude = 1
                local frequency = 1
                local max_amp = 0
                
                for i = 1, plant.octaves do
                    local result = perlin.get(x * plant.zoom * frequency, y * plant.zoom * frequency)
    
                    chance = chance + result * amplitude
                    
                    max_amp = max_amp + amplitude
                    amplitude = amplitude / 2
                    frequency = frequency * 2
                end
    
                chance = ((chance + 1) / 2)^4

                if plant.chances[cell.block] ~= nil then
                    chance = chance * plant.chances[cell.block]
                end
    
                local result = math.random(0, 1/chance)

                if result == 0 and cell.object == nil and plant.chances[cell.block] ~= nil then
                    cell.object = name
                end
            end
        end
    end

    return world
end

return worldgen