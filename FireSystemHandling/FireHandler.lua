--[[
Author: Vitorio Bimbato - VintoKrieg
Date: 12/07/2023
Description: This script is the end handler utilising the Fire Event module and Fire Object module
]]--

local FireHandlingSystem = script.Parent
local FireEvents = require(FireHandlingSystem.FireEventObject)

function FilterRandomPoint(RP)
	local nRP = RP
	for i,v in pairs(nRP) do
		if v:IsA("Folder") then
			table.remove(nRP,i)
		end
	end
	return nRP
end


function Init()
	local FireFolder = game.Workspace:FindFirstChild("FireFolder")
	if not FireFolder then
		local FireFolder = Instance.new("Folder")
		FireFolder.Name = "FireFolder"
		FireFolder.Parent = game.Workspace
	end
end

function RandomPoint()
	local points = FilterRandomPoint(game.Workspace.TestBuilding.Room1.FirePoints:GetChildren())
	return points[math.random(1,#points)]
	
end

function TestFire()
	
	local FE = FireEvents.new(game.Workspace.TestBuilding,game.Workspace.TestBuilding.Room1,RandomPoint())
	FE:Action()
end




Init()

TestFire()



