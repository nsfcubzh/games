
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\classes\\Object.lua'] = {}
NSFLua['faint\\classes\\Object.lua'].LAST_SECTION = ""
NSFLua['faint\\classes\\Object.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Object = {
    New = function(self, config)
        if self ~= Game.Object then
            error("Game.Object.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            id = nil,
            model = nil,
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
            error("Missing shape for object '"..cfg.id.."'.", 2)
        end

        Debug.log("Registering '"..cfg.id.."' object...")
        if self[cfg.id] ~= nil then
            Debug.log("Error registering '"..cfg.id.."' object [Already registered]...")
            error("Object "..cfg.id.." already exists.", 2)
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