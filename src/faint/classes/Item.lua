Game.Item = {
    New = function(self, config)
        if self ~= Game.Item then
            error("Game.Item.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            id = nil,
            model = nil,
            name = "item.name",
            stackSize = 1,
            count = 1,
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
            error(f"Missing shape for item '{cfg.id}'.", 2)
        end

        Debug.log(f"Registering '{cfg.id}' item...")
        if self[cfg.id] ~= nil then
            Debug.log(f"Error registering '{cfg.id}' item [Already registered]...")
            error(f"Item {cfg.id} already exists.", 2)
        end

        local constructor = function(...)
            local item = {}

            item.id = cfg.id
            item.shape = Shape(shapes[cfg.model], {includeChildren = true})
            item.name = cfg.name
            item.count = cfg.count
            item.stackSize = cfg.stackSize

            return item
        end

        self[cfg.id] = constructor
        return constructor
    end
}