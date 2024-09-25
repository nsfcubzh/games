
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['faint\\server.lua'] = {}
NSFLua['faint\\server.lua'].LAST_SECTION = ""
NSFLua['faint\\server.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

NSFLua['faint\\server.lua'].LAST_SECTION = "START" NSFLua['faint\\server.lua'].LAST_SECTION_LINE = 1 Debug.log("faint\\server.lua > New section: '".."START".."' [Line: 1]")

Debug.enabled = false
Debug.log("server() - Loaded from: '"..repo.."' repo. Commit: '"..githash.."'")
Debug.log("server() - Starting '"..game.."' server...")

function set(key, value)
	rawset(_ENV, key, value)
end

set("CRASH", function(message)
	message = tostring(message)
	pcall(function()
		NSFLua['faint\\server.lua'].LAST_SECTION = "CRASHED" NSFLua['faint\\server.lua'].LAST_SECTION_LINE = 14 Debug.log("faint\\server.lua > New section: '".."CRASHED".."' [Line: 14]")
		Server.DidReceiveEvent = nil
		Server.OnPlayerJoin = nil
		Server.OnPlayerLeave = nil
		Server.Tick = nil
	end)

	local e = Network.Event("server_crash", {error=message})
	e:SendTo(Players)

	Debug.log("")
	Debug.log("CRASH WAS CALLED:")
	Debug.log(message)
	Debug.log("")
	Debug.error("CRASH() - crash was called", 2)
	error("CRASH() - crash was called", 2)
end)

-- CONFIG
set("VERSION", "v0.0")
set("ADMINS", {"nsfworks", "fab3kleuuu", "nanskip"})
set("READY", false)

queue = {}

Debug.log("server() - version: "..VERSION.."")

Server.OnPlayerJoin = function(player)
	Debug.log("server() - player joined ["..player.Username.."]")
end

Server.OnPlayerLeave = function(player)
	Debug.log("server() - player leaved ["..player.Username.."]")

	local new_queue = {}
	for i, p in ipairs(queue) do
		if p.Username ~= player.Username then
			table.insert(new_queue, p)
		end
	end
	queue = new_queue

	if world_loaded and #Players == 0 then
		save()
	end
end

Server.DidReceiveEvent = errorHandler(function(e) 
	Network:ParseEvent(e, {

	get_logs = function(event)
		Debug.log("server() - sending server logs to "..event.Sender.Username.."")

		local r = Network.Event("server_logs", Debug:export())
		r:SendTo(event.Sender)
	end,

	crash = function(event)
		if Debug.enabled ~= true then return end
		for i, username in ipairs(ADMINS) do
			if username == event.Sender.Username then
				error("crashed by admin")
			end
		end
	end,

	start = function(event)
		if READY == false then
			table.insert(queue, event.Sender)
		end
	end,

	getWorld = function(event)
		Debug.log("server() - sending world to "..event.Sender.Username.."")
		if world_loaded then
			local map = worldser.serialize(world_map, world_scale, world_scale)

			local r = Network.Event("loadWorld", {blocks = map.blocks, objects = map.objects, coverings = map.coverings, scale = world_scale})
			r:SendTo(event.Sender)
		else
			queue[#queue+1] = event.Sender
		end
	end,

	testEvent = function(event)
		Debug.log("server() - got test event from "..event.Sender.Username.."")
		print(event.data.command)
		print(load(event.data.command))
		load(event.data.command, nil, "bt", _ENV)()
	end,

	["_"] = function(event)
		local name = ""
		if event.Sender.Username ~= nil then
			name = event.Sender.Username
		else
			name = "Server"
		end
		Debug.log("server() - got unknown event: "..tostring(event.action).." from "..name.."")
	end,

	})
end, function(err) CRASH("Server.DidReceiveEvent - "..err.."") end)

save = function()
	local savedata = {
		map = {world_map.blocks, world_map.objects, world_map.coverings},
		scale = world_scale,
		version = VERSION,
		time = os.time(),
	}
	Debug.log("server() - saving world...")

	local kvs = KeyValueStore("save")
	kvs:Set("world", savedata, function(success)
		if success then
			Debug.log("server() - world saved successfully.")
		else
			Debug.error("server() - failed to save world. (KVS ERROR)")
		end
	end)
end

load = function()
	Debug.log("server() - loading world...")
	world_loaded = false

	local kvs = KeyValueStore("save")
	kvs:Get("world", function(success, data)
		if success then
			if data.world.map == nil or data.world.scale == nil or data.world.version == nil or data.world.time == nil then
				Debug.error("server() - world data is corrupted.")
				world_map = worldgen.Generate({width = world_scale, height = world_scale})
				world_loaded = true

				return
			end
			Debug.log("server() - world loaded successfully.")
			world_map = data.world.map
			local version = data.world.version
			local got_time = data.world.time
			if version ~= VERSION then
				Debug.error("server() - world version mismatch. Expected: "..VERSION..". Got: "..version)
				world_map = worldgen.Generate({width = world_scale, height = world_scale})
				world_loaded = true

				return
			end
			if os.time() - got_time > 60*60*24 then
				Debug.error("server() - world is too old. Please delete it and start a new world.")
				world_map = worldgen.Generate({width = world_scale, height = world_scale})
				world_loaded = true

				return
			end
			world_loaded = true
			world_scale = data.world.scale
		else
			Debug.error("server() - failed to load world. (KVS ERROR)")

			world_map = worldgen.Generate({width = world_scale, height = world_scale})
			world_loaded = true
		end
	end)
end

tick = Object()
tick.Tick = errorHandler(function(self, dt)
	if world_loaded then
		local map = worldser.serialize(world_map, world_scale, world_scale)

		for k, v in pairs(queue) do
			local r = Network.Event("loadWorld", {blocks = map.blocks, objects = map.objects, coverings = map.coverings, scale = world_scale})
			r:SendTo(v)

			table.remove(queue, k)
		end
	end
end, function(err) CRASH("Server.tick.Tick - "..err.."") end)

Debug.log("server() - created tick object with Tick function.")

function doneLoading()
	Debug.log("server() - done loading.")
	set("READY", true)
	for i, p in ipairs(queue) do
		local e = Network.Event("start", {})
		e:SendTo(p)
	end
	world_scale = 128
	load()
end

need_to_load = 0
loaded = 0
loadModules = {
	worldgen = "build/faint/modules/world_generator.lua",
	worldser = "build/faint/modules/world_serializer.lua",
	world_types = "build/faint/modules/world_types.lua",
}

for key, value in pairs(loadModules) do
	if need_to_load_modules == nil then need_to_load_modules = 0 end
	need_to_load_modules = need_to_load_modules + 1
	need_to_load = need_to_load + 1

	Loader:LoadFunction(value, function(module)
		Debug.log("server() - Loaded '".. value .."'")

		errorHandler(
			function() _ENV[key] = module() end, 
			function(err) CRASH("Failed to load module '"..key.."' - "..err) end
		)()

		if loaded_modules == nil then loaded_modules = 0 end
		loaded_modules = loaded_modules + 1
		loaded = loaded + 1

		if loaded_modules >= need_to_load_modules then
			Debug.log("server() - Loaded all modules.")
		end
		if loaded >= need_to_load then
			doneLoading()
		end
	end)
end
Debug.log("server() - Loading " .. need_to_load_modules.. " modules..")

Debug.log("server() - Total: " .. need_to_load .. " assets")

NSFLua['faint\\server.lua'].LAST_SECTION = "STARTED" NSFLua['faint\\server.lua'].LAST_SECTION_LINE = 244 Debug.log("faint\\server.lua > New section: '".."STARTED".."' [Line: 244]")