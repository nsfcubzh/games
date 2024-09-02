
-- NSFLua Code

if NSFLua == nil then rawset(_ENV, "NSFLua", {}) end

NSFLua['cubic-dungeons\\server.lua'] = {}
NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION = ""
NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION_LINE = 0

-- End of NSFLua code

NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION = "START" NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION_LINE = 1 Debug.log("cubic-dungeons\\server.lua > New section: '".."START".."' [Line: 1]")

Debug.enabled = false
Debug.log("server() - Loaded from: '"..repo.."' repo. Commit: '"..githash.."'")
Debug.log("server() - Starting '"..game.."' server...")

function set(key, value)
	rawset(_ENV, key, value)
end

set("CRASH", function(message)
	message = tostring(message)
	pcall(function()
		NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION = "CRASHED" NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION_LINE = 14 Debug.log("cubic-dungeons\\server.lua > New section: '".."CRASHED".."' [Line: 14]")
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

Debug.log("server() - version: "..VERSION.."")

Server.OnPlayerJoin = function(player)
	Debug.log("server() - player joined ["..player.Username.."]")
end

Server.OnPlayerLeave = function(player)
	Debug.log("server() - player leaved ["..player.Username.."]")
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

	["_"] = function(event)
		Debug.log("server() - got unknown event: "..tostring(event.action).."")
	end

	})
end, function(err) CRASH("Server.DidReceiveEvent - "..err.."") end)


tick = Object()
tick.Tick = errorHandler(function(self, dt)

end, function(err) CRASH("Server.tick.Tick - "..err.."") end)

Debug.log("server() - created tick object with Tick function.")

NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION = "STARTED" NSFLua['cubic-dungeons\\server.lua'].LAST_SECTION_LINE = 80 Debug.log("cubic-dungeons\\server.lua > New section: '".."STARTED".."' [Line: 80]")