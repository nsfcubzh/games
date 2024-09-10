
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\classes\\Entity.lua'] = {}
NSFLua['faint\\classes\\Entity.lua'].LAST_SECTION = ""
NSFLua['faint\\classes\\Entity.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Entity = {
    New = function(self, config)
        if self ~= Game.Entity then
            error("Game.Entity.New() should be called with ':'!", 2)
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
            error("Entity must have 'id' field.", 2)
        end
        if cfg.model == nil then 
            error("Entity must have 'model' field.", 2)
        end
        if shapes[cfg.model] == nil then
            error("Missing shape ["..cfg.model.."] for entity '"..cfg.id.."'.", 2)
        end

        Debug.log("Registering '"..cfg.id.."' object...")
        if self[cfg.id] ~= nil then
            Debug.log("Error registering '"..cfg.id.."' entity [Already registered]...")
            error("Entity "..cfg.id.." already exists.", 2)
        end

        local constructor = function(...)
            local ent = {}

            if cfg.type == "Shape" then
                ent.shape = Shape(shapes[cfg.model], {includeChildren = true})
            elseif cfg.type == "MutableShape" then
                ent.shape = MutableShape(shapes[cfg.model], {includeChildren = true})
            end

            ent.id = cfg.id
            ent.Destroy = cfg.Destroy
            ent.Init = cfg.Init
            ent.Tick = cfg.Tick
            ent:Init(...)

            if ent.Tick ~= nil then 
                ent.TickListener = LocalEvent:Listen(LocalEvent.Name.Tick, function(...) 
                    ent:Tick(...)
                end)
            end

            return ent
        end

        self[cfg.id] = constructor
        return constructor
    end
}