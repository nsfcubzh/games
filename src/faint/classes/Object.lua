
local object = {
    New = function(self, config)
        if self ~= object then
            error("Game.Object.New() should be called with ':'!", 2)
        end
        local defaultConfig = {
            id = "Debug",
            type = "Shape",
            shape = "nanskip.v",
            Init = function(s)
                return
            end,
            Destroy = function(s)
                s:SetParent(nil)
                s = nil
            end,
            Tick = nil, -- tick function
        }
        local cfg = {}
        for key, value in pairs(default) do
            cfg[key] = value
        end
        for key, value in pairs(custom) do
            cfg[key] = value
        end

        if self[cfg.id] ~= nil then
            error(f"Object {cfg.id} already exists.", 2)
        end

        local constructor = function()
            local obj = {}
            
            if cfg.type == "Shape" then
                obj = Shape(cfg.shape)
            elseif cfg.type == "MutableShape" then
                obj = MutableShape(cfg.shape)
            end

            obj.id = cfg.id
            obj.Destroy = cfg.Destroy
            obj.Init = cfg.Init
            obj:Init()
            obj.Tick = cfg.Tick

            return obj
        end

        self[cfg.id] = constructor
    end,
}

Game.Object = object
