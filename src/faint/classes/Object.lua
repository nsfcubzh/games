Game.Object = {
    New = function(self, config)
        if self ~= Game.Object then
            error("Game.Object.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            type = "Shape",
            Init = function(s)
                return
            end,
            Destroy = function(s)
                s.shape:SetParent(nil)
                s.shape = nil
            end,
            Tick = nil,
        }

        local cfg = {}
        for key, value in pairs(defaultConfig) do
            cfg[key] = value
        end
        for key, value in pairs(config) do
            cfg[key] = value
        end

        if cfg.id == nil then 
            error("Object must have 'id' field.", 2)
        end
        if cfg.model == nil then 
            error("Object must have 'model' field.", 2)
        end
        if shapes[cfg.model] == nil then
            error(f"Missing shape [{cfg.model}] for '{cfg.id}'.", 2)
        end

        Debug.log(f"Registering '{cfg.id}' object...")
        if self[cfg.id] ~= nil then
            Debug.log(f"Error registering '{cfg.id}' object [Already registered]...")
            error(f"Object {cfg.id} already exists.", 2)
        end

        local constructor = function(...)
            local obj = {}

            if cfg.type == "Shape" then
                obj.shape = Shape(shapes[cfg.model], {includeChildren = true})
            elseif cfg.type == "MutableShape" then
                obj.shape = MutableShape(shapes[cfg.model], {includeChildren = true})
            end

            obj.id = cfg.id
            obj.Destroy = cfg.Destroy
            obj.Init = cfg.Init
            obj.Tick = cfg.Tick
            obj:Init(...)

            if obj.Tick ~= nil then 
                obj.TickListener = LocalEvent:Listen(LocalEvent.Name.Tick, function(...) 
                    obj:Tick(...)
                end)
            end

            return obj
        end

        self[cfg.id] = constructor
        return constructor
    end
}