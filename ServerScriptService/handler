-- ServerScriptService/handler.lua

local rep = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local runCode = rep:WaitForChild("Kakanie")

local main = require(ServerScriptService["Лёха"].main)

runCode.OnServerInvoke = function(player, code)
	local success, result = pcall(function()
		return main.run(code)
	end)

	if success then
		return result
	else
		return "Error: " .. tostring(result)
	end
end
