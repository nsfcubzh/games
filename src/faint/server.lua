-SECTION("START")

Debug.enabled = false
Debug.log(f"server() - Loaded from: '{repo}' repo. Commit: '{githash}'")
Debug.log(f"server() - Starting '{game}' server...")

function set(key, value)
	rawset(_ENV, key, value)
end

set("CRASH", function(message)
	message = tostring(message)
	pcall(function()
		-SECTION("CRASHED")
		Server.DidReceiveEvent = nil
		Server.OnPlayerJoin = nil
		Server.OnPlayerLeave = nil
		Server.Tick = nil
	end)

	print(Network, Network.Event)
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

Debug.log(f"server() - version: {VERSION}")

Server.OnPlayerJoin = function(player)
	Debug.log(f"server() - player joined [{player.Username}]")
end

Server.OnPlayerLeave = function(player)
	Debug.log(f"server() - player leaved [{player.Username}]")

	local new_queue = {}
	for i, p in ipairs(queue) do
		if p.Username ~= player.Username then
			table.insert(new_queue, p)
		end
	end
	queue = new_queue
end

Server.DidReceiveEvent = errorHandler(function(e) 
	Network:ParseEvent(e, {

	get_logs = function(event)
		Debug.log(f"server() - sending server logs to {event.Sender.Username}")

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
	end

	["_"] = function(event)
		Debug.log(f"server() - got unknown event: {tostring(event.action)}")
	end

	})
end, function(err) CRASH(f"Server.DidReceiveEvent - {err}") end)


tick = Object()
tick.Tick = errorHandler(function(self, dt)

end, function(err) CRASH(f"Server.tick.Tick - {err}") end)

Debug.log("server() - created tick object with Tick function.")

-SECTION("STARTED")