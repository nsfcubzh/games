
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\modules\\world_generator.lua'] = {}
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION = ""
NSFLua['faint\\modules\\world_generator.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local worldgen = {}

function worldgen.Generate(config)
    if config == nil then
        error("worldgen.Generate(config) - 1st argument must be a table.")
    end

    local defaultConfig = {
        scale = 32,
        zoom = 0.1
        seed = 0,
        octaves = 2,
        waterLevel = 0.2,
        sandLevel = 0.3,
        grassLevel = 0.7,
        gravelLevel = 0.8,
        graniteLevel = 1,

        plants = {
            tree = {
                scale = 0.2,
                seed = 1,
                octaves = 1,
                chance = 0.5
            },
            grass = {
                scale = 0.3,
                seed = 2,
                octaves = 2,
                chance = 0.6
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
    for x, cfg.scale do
        world[x] = {}
        for y, cfg.scale do
            world[x][y] = {}
            local cell = world[x][y]

            perlin.seed(cfg.seed)
            local height = (perlin.get(x*cfg.zoom, y*cfg.zoom) + 1)/2 -- getting height value from 0 to 1

            cell.block = "debug"
            if height < cfg.waterLevel then
                cell.block = "water"
            elseif height < cfg.sandLevel then
                cell.block = "sand"
            elseif height < cfg.grassLevel then
                cell.block = "grass"
            elseif height < cfg.gravelLevel then
                cell.block = "gravel"
            elseif height <= cfg.graniteLevel then
                cell.block = "granite"
            end
        end
    end

    for x, cfg.scale do
        local text = ""
        for y, cfg.scale do
            if world[x][y].block == "water" then
                text = text .. " "
            elseif world[x][y].block == "sand" then
                text = text .. "."
            elseif world[x][y].block == "grass" then
                text = text .. "I"
            elseif world[x][y].block == "gravel" then
                text = text .. "0"
            elseif world[x][y].block == "granite" then
                text = text .. "#"
            end
        end
        print(text)
    end
end

return worldgen