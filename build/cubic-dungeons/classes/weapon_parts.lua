
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['cubic-dungeons\\classes\\weapon_parts.lua'] = {}
NSFLua['cubic-dungeons\\classes\\weapon_parts.lua'].LAST_SECTION = ""
NSFLua['cubic-dungeons\\classes\\weapon_parts.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

local weapon_parts = {}

weapon_parts.new = function(self, config)
    if type(config) ~= "table" then error("weapon_parts:new(config) - config must be a table", 2) end
    
    local w = {}

    w.Type = config.type
    w.Name = config.name
    w.Description = config.description
    w.Rarity = config.rarity
    w.StatsEffects = config.stat_effects or {}
    w.TextureName = config.texture

    w.Texture = images["wp_"..w.TextureName]
    if w.Texture == nil then
        error("weapon_parts:new(config) - config.texture_name, texture '"..tostring(w.TextureName).."' not found in images table", 2)
    end

    setmetatable(w, {type="weapon_part"})
    return w
end

rawset(_ENV, "weapon_part", function(...) return weapon_parts:new(...) end)

return weapon_parts