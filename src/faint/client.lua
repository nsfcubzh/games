-SECTION("START")

Debug.enabled = true
Debug.log(f"server() - Loaded from: '{repo}' repo. Commit: '{githash}'. Modules commit: '{nsfwhash}'")
Debug.log(f"server() - Starting '{game}' server...")

randomEasterLogs = {
	"Once upon a time...",
	"NOT SAFE TO PLAY",
	"It starts with...",
	"Who coded this??",
	"Hello world!",
	"Good luck debugging this",
	"Who also hates bugs?",
	"SYSTEMS: ONLINE | STATUS: WORKING (or not)",
	"im totally not just adding garbage logs into this",
	":3",
	"pew pew",
	"Do not touch anything",
	"please, forgive me",
	"Hello    anyone??",
	"Im watching you <0>",
	"TOP SECRET",
	"If it breaks, im not guilty"
}

Player.Position = Number3(-1000, -1000, -1000)

Camera:SetParent(nil)
Fog.On = false
Clouds.On = false

Debug.log("client() - loading cubzh modules...")
multi = require("multi")
ui = require("uikit")
toast = require("ui_toast")
Debug.log("client() - loaded cubzh modules")

function copyClientLogs()
	Debug.log("client() - copying client logs")

	Dev:CopyToClipboard(Debug:export())
	toast:create({message = "Logs are copied to clipboard."})

	Debug.log("client() - client logs are copied")
end
function copyServerLogs()
	Debug.log("client() - copying server logs")
	
	local e = Network.Event("get_logs", {})
	e:SendTo(Server)

	if serverLogListener ~= nil then
		serverLogListener:Remove()
		serverLogListener = nil
	end
	serverLogListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
		Dev:CopyToClipboard(e.data)
		toast:create({message = "Server logs are copied to clipboard."})
		serverLogListener:Remove()
		serverLogListener = nil

		Debug.log("client() - server logs are copied")
	end)
end
function copyLogs()
	Debug.log("client() - copying client and server logs")
	
	copyLogsLogs = {}
	copyLogsLogs.client = JSON:Decode(Debug:export())

	local e = Network.Event("get_logs", {})
	e:SendTo(Server)

	if serverLogListener ~= nil then
		serverLogListener:Remove()
		serverLogListener = nil
	end
	serverLogListener = LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
		copyLogsLogs.server = JSON:Decode(e.data)
		serverLogListener:Remove()
		serverLogListener = nil

		toast:create({message = "Logs are copied."})

		Dev:CopyToClipboard(JSON:Encode(copyLogsLogs))
		Debug.log("client() - clint and server logs are copied")
	end)
end


LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
	if e.action == "server_crash" and e.Sender == Server then
		Debug.log("GOT SERVER CRASH")
		CRASH(e.data.error)
	end
end)
LocalEvent:Listen(LocalEvent.Name.OnChat, function(payload)
    message = payload.message
    if message == "?logs" then
        copyLogs()
    end
end)

function set(key, value)
	rawset(_ENV, key, value)
end

-- CRASH DEFINITION
set("CRASH", function(message)
	message = tostring(message)
	pcall(function()
		if menu.created then menu:remove() end
	end)

	local ui = require("uikit")
	local crash_bg = ui:createFrame(Color(89, 157, 220, 255))
	crash_bg.parentDidResize = function()
		crash_bg.Width = Screen.Width
		crash_bg.Height = Screen.Height
	end
	crash_bg:parentDidResize()

	local crash_text = ui:createText("CRASH\nFaint cannot continue running because of unexpected error:\n  "..message.."\n\nTo copy logs type '?logs' in the chat\nWays to send us logs:\n  * On Cubzh Discord Server (#worlds -> Cubic Dungeons)\n  * @sysfab (discord)\n  * @nanskip (discord)", Color(255, 255, 255, 255))
	crash_text.parentDidResize = function()
		crash_text.pos = Number2(4, Screen.Height/2-crash_text.Height/2)
	end
	crash_text:parentDidResize()

	Debug.log("")
	Debug.log("CRASH WAS CALLED:")
	Debug.log(message)
	Debug.log("")
	Debug.error("CRASH() - crash was called", 2)
	error("CRASH() - crash was called", 2)
end)

-- GAME OBJECT SETTING
set("Game", {})

-- CONFIG
set("VERSION", "v0.0")
set("ADMINS", {"nsfworks", "fab3kleuuu", "nanskip"})

Debug.log(f"client() - version: {VERSION}")

Client.DirectionalPad = nil
Client.AnalogPad = nil
Client.OnPlayerJoin = function(p)
	if p == Player and not playerJoined then
		playerJoined = true
		checkLoading()
	end
end
Pointer.Drag = nil


loadingBG = ui:createFrame(Color(0, 0, 0, 255))
loadingBG.parentDidResize = function(_)
	loadingBG.Width = Screen.Width
	loadingBG.Height = Screen.Height
end
loadingBG.parentDidResize()


loadModules = {
	loading_screen = "build/faint/loading_screen.lua",
	menu = "build/faint/menu/menu.lua",
	settings = "build/faint/settings.lua",
	worldgen = "build/faint/modules/world_generator.lua",
	game = "build/faint/game/game.lua",
	worldser = "build/faint/modules/world_serializer.lua",
	world_types = "build/faint/modules/world_types.lua",
}

loadClasses = {
	"build/faint/classes/Object.lua",
	"build/faint/classes/Entity.lua",
	"build/faint/classes/Item.lua",
	"build/faint/classes/Covering.lua"
}

animations = {}
loadAnimations = {

}

shapes = {}
loadShapes = {
	tree = "nanskip.faint_tree1",
	grass = "nanskip.faint_grass",
	rock = "nanskip.faint_rock",
	wall_wood = "nanskip.faint_wall_wood",
	test = "voxels.chestnut",
}

loadLua = {
	"build/faint/data/objects.lua",
	"build/faint/data/coverings.lua",
	"build/faint/data/items.lua",
}
loadedLua = {}

audio = {}
loadAudios = {

}

images = {}
loadImages = {
	floor = "build/faint/data/floor_wood.png",
	menu_background = "build/faint/data/menu_background.png",
}

json = {}
loadJsons = {

}


loaded = 0
need_to_load = 0

need_to_load_animations = 0
need_to_load_audios = 0
need_to_load_images = 0
need_to_load_modules = 0
need_to_load_shapes = 0
need_to_load_jsons = 0

isLoaded = false

LocalEvent:Listen(LocalEvent.Name.DidReceiveEvent, function(e)
	if e.action == "ready" and e.Sender == Server then
		Debug.log("Got start event from server")
		gotStartEvent = true

		if isLoaded ~= true and loaded >= need_to_load then
			doneLoading()
		end
	end
end)

function doneLoading()
	-SECTION("STARTED")
	isLoaded = true

	Camera:SetParent(World)
	Debug.log("")
	Debug.log("GAME LOADED")
	Debug.log("")

	Debug.log("#"..randomEasterLogs[math.random(1, #randomEasterLogs)])

	if Debug.enabled == true then
		toast:create({message = "Game launched with Debug enabled."})
	end

	for key, value in pairs(loadedLua) do
		value()
	end

	if loading_screen.created then loading_screen:remove() end
	hideServerLoadingScreen()
	settings:load()
	menu:create()
end

function showServerLoadingScreen()
	if loading_screen.created then loading_screen:remove() end
	server_loading_screen = ui:createFrame(Color(255, 255, 255, 255))
	server_loading_screen:setImage(images.menu_background)

	server_loading_screen.parentDidResize = function()
		local scale_factor = Screen.Height / 949
		server_loading_screen.Width = Screen.Width * scale_factor
		server_loading_screen.Height = Screen.Height
		server_loading_screen.pos = Number2((Screen.Width - server_loading_screen.Width)/2, 0)
	end
	server_loading_screen.parentDidResize()
end

function hideServerLoadingScreen()
	if server_loading_screen ~= nil then
		server_loading_screen:remove()
		server_loading_screen = nil
	end
end

function checkLoading()
	if isLoaded ~= true and loaded >= need_to_load then
		if gotStartEvent == true then
			doneLoading()
		else
			local e = Network.Event("start", {})
			e:SendTo(Server)
			Debug.log("Sended start event to server")

			showServerLoadingScreen()
		end
	end
end

for key, value in pairs(loadModules) do
	if need_to_load_modules == nil then need_to_load_modules = 0 end
	need_to_load_modules = need_to_load_modules + 1
	need_to_load = need_to_load + 1

	Loader:LoadFunction(value, function(module)
		Debug.log("client() - Loaded '".. value .."'")

		errorHandler(
			function() _ENV[key] = module() end, 
			function(err) CRASH("Failed to load module '"..key.."' - "..err) end
		)()

		if loaded_modules == nil then loaded_modules = 0 end
		loaded_modules = loaded_modules + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_modules >= need_to_load_modules then
			Debug.log("client() - Loaded all modules.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_modules.. " modules..")

for key, value in pairs(loadClasses) do
	if need_to_load_classes == nil then need_to_load_classes = 0 end
	need_to_load_classes = need_to_load_classes + 1
	need_to_load = need_to_load + 1

	Loader:LoadFunction(value, function(class)
		Debug.log("client() - Loaded '".. value .."'")

		errorHandler(
			function() class() end, 
			function(err) CRASH("Failed to load class '"..value.."' - "..err) end
		)()

		if loaded_classes == nil then loaded_classes = 0 end
		loaded_classes = loaded_classes + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_classes >= need_to_load_classes then
			Debug.log("client() - Loaded all classes.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_classes.. " classes..")


for key, value in pairs(loadLua) do
	if need_to_load_lua == nil then need_to_load_lua = 0 end
	need_to_load_lua = need_to_load_lua + 1
	need_to_load = need_to_load + 1

	Loader:LoadFunction(value, function(file)
		Debug.log("client() - Loaded '".. value .."'")

		errorHandler(
			function() loadedLua[value] = file end, 
			function(err) CRASH("Failed to load lua file '"..value.."' - "..err) end
		)()

		if loaded_lua == nil then loaded_lua = 0 end
		loaded_lua = loaded_lua + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_lua >= need_to_load_lua then
			Debug.log("client() - Loaded all lua files.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_lua.. " lua files..")

for key, value in pairs(loadAnimations) do
	if need_to_load_animations == nil then need_to_load_animations = 0 end
	need_to_load_animations = need_to_load_animations + 1
	need_to_load = need_to_load + 1

	Loader:LoadText(value, function(text)
		Debug.log("client() - Loaded '".. value .."'")

		animations[key] = text

		if loaded_animations == nil then loaded_animations = 0 end
		loaded_animations = loaded_animations + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_animations >= need_to_load_animations then
			Debug.log("client() - Loaded all animations.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_animations .. " animations..")

for key, value in pairs(loadShapes) do
	if need_to_load_shapes == nil then need_to_load_shapes = 0 end
	need_to_load_shapes = need_to_load_shapes + 1
	need_to_load = need_to_load + 1

	Object:Load(value, function(shape)
		Debug.log("client() - Loaded '".. value .."'")

		shapes[key] = shape

		if loaded_shapes == nil then loaded_shapes = 0 end
		loaded_shapes = loaded_shapes + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_shapes >= need_to_load_shapes then
			Debug.log("client() - Loaded all shapes.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_shapes .. " shapes..")

for key, value in pairs(loadAudios) do
	if need_to_load_audios == nil then need_to_load_audios = 0 end
	need_to_load_audios = need_to_load_audios + 1
	need_to_load = need_to_load + 1

	Loader:LoadData(value, function(audioData)
		Debug.log("client() - Loaded '".. value .."'")

		audio[key] = audioData

		if loaded_audios == nil then loaded_audios = 0 end
		loaded_audios = loaded_audios + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_audios >= need_to_load_audios then
			Debug.log("client() - Loaded all audios.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_audios .. " audios..")

for key, value in pairs(loadImages) do
	if need_to_load_images == nil then need_to_load_images = 0 end
	need_to_load_images = need_to_load_images + 1
	need_to_load = need_to_load + 1

	Loader:LoadData(value, function(data)
		Debug.log("client() - Loaded '".. value .."'")

		images[key] = data

		if loaded_images == nil then loaded_images = 0 end
		loaded_images = loaded_images + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_images >= need_to_load_images then
			Debug.log("client() - Loaded all images.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_images .. " images..")

for key, value in pairs(loadJsons) do
	if need_to_load_jsons == nil then need_to_load_jsons = 0 end
	need_to_load_jsons = need_to_load_jsons + 1
	need_to_load = need_to_load + 1

	Loader:LoadText(value, function(data)
		Debug.log("client() - Loaded '".. value .."'")

		json[key] = JSON:Decode(data)

		if loaded_jsons == nil then loaded_jsons = 0 end
		loaded_jsons = loaded_jsons + 1
		loaded = loaded + 1

		if loading_screen.created then
			loading_screen:setText("Loading... (" .. loaded .. "/" .. need_to_load .. ")")
		elseif loading_screen ~= nil then
			loading_screen:create()
			
			loadingBG:remove()
			loadingBG = nil
		end

		if loaded_jsons >= need_to_load_jsons then
			Debug.log("client() - Loaded all jsons.")
		end
		if loaded >= need_to_load then
			checkLoading()
		end
	end)
end
Debug.log("client() - Loading " .. need_to_load_jsons .. " jsons..")


Debug.log("client() - Total: " .. need_to_load .. " assets")
-SECTION("LOADING")