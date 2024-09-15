
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\classes\\Item.lua'] = {}
NSFLua['faint\\classes\\Item.lua'].LAST_SECTION = ""
NSFLua['faint\\classes\\Item.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Item = {
    New = function(self, config)
        if self ~= Game.Item then
            error("Game.Item.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            id = nil,
            model = nil,
        }

        local cfg = {}
        for key, value in pairs(defaultConfig) do
            cfg[key] = value
        end
        for key, value in pairs(config) do
            cfg[key] = value
        end

        if cfg.id == nil then 
            error("Item must have 'id' field.", 2)
        end
        if cfg.model == nil then 
            error("Item must have 'model' field.", 2)
        end
        if shapes[cfg.model] == nil then
            error("Missing shape for item '"..cfg.id.."'.", 2)
        end

        Debug.log("Registering '"..cfg.id.."' item...")
        if self[cfg.id] ~= nil then
            Debug.log("Error registering '"..cfg.id.."' item [Already registered]...")
            error("Item "..cfg.id.." already exists.", 2)
        end

        local constructor = function(...)
            local item = {}

            item.id = cfg.id
            item.shape = Shape(shapes[cfg.model], {includeChildren = true})

            return item
        end

        self[cfg.id] = constructor
        return constructor
    end
}