Game.Object = {
    New = function(self, config)
        if self ~= Game.Object then
            error("Game.Object.New() should be called with ':'!", 2)
        end

        local defaultConfig = {
            id = "Debug",
            type = "Shape",
            model = "nanskip.v",
            Init = function(s)
                return
            end,
            Destroy = function(s)
                s:SetParent(nil)
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

        Debug.log(f"Registering '{cfg.id}' object...")


        if self[cfg.id] ~= nil then
            Debug.log(f"Error registering '{cfg.id}' object [Already registered]...")
            error(f"Object {cfg.id} already exists.", 2)
        end

        local constructor = function(...)
            local obj = {}

            local create = function(cfg)
                local obj = {}
                
                if cfg.type == "Shape" then
                    obj = Shape(Game.Object.Cache[cfg.id])
                elseif cfg.type == "MutableShape" then
                    obj = MutableShape(Game.Object.Cache[cfg.id])
                end

                obj.id = cfg.id
                obj.Destroy = cfg.Destroy
                obj.Init = cfg.Init
                obj.Tick = cfg.Tick
                obj:Init(...)

                return obj
            end

            if Game.Object.Cache[cfg.id] == nil then
                Object:Load(cfg.model, function(model)
                    Game.Object.Cache[cfg.id] = model
                    create(cfg)
                end)
            else
                create(cfg)
            end
        end

        self[cfg.id] = constructor
    end,

    Cache = {}
}