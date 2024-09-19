
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\classes\\Covering.lua'] = {}
NSFLua['faint\\classes\\Covering.lua'].LAST_SECTION = ""
NSFLua['faint\\classes\\Covering.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

Game.Covering = {
    New = function(self, config)
        if self ~= Game.Covering then
            error("Game.Covering.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            id = nil,
            image = nil,
            color = Color.White,
            type = "Color",
            Init = function(s)
                return
            end,
            Destroy = function(s)
                s.quad:SetParent(nil)
                s.quad = nil
                s = nil
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
            error("Covering must have 'id' field.", 2)
        end
        if cfg.model == nil then 
            error("Covering must have 'model' field.", 2)
        end
        if images[cfg.model] == nil then
            error("Missing image for covering '"..cfg.id.."'.", 2)
        end

        Debug.log("Registering '"..cfg.id.."' covering...")
        if self[cfg.id] ~= nil then
            Debug.log("Error registering '"..cfg.id.."' covering [Already registered]...")
            error("Covering "..cfg.id.." already exists.", 2)
        end

        local constructor = function(...)
            local obj = {}

            obj.quad = Quad()
            if cfg.type == "Color" then
                obj.quad.Color = cfg.color
            elseif cfg.type == "Image" then
                obj.quad.Image = cfg.image
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