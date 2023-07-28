--[[
Author: Vitorio Bimbato - VintoKrieg
Date: 12/07/2023
Description: This script is the object constructor module for an individual fire Event Instance 
]]--
local FireEvent = {}
FireEvent.__index = FireEvent
local FireHandlingSystem = script.Parent

local FireObjects = require(FireHandlingSystem.FireObject)


--Function checks if an item is in a list
local function isItemInList(list,target)
	for _,v in pairs(list) do
		if v == target then
			return true
		end
	end
	return false
end

-- instantiates a new Fire Event Instance - Fire Event constructor
function FireEvent.new(Building,Room,StartLocation)
	local newFireEvent = {}
	setmetatable(newFireEvent,FireEvent)
	local FireFolder = game:GetService("Workspace"):FindFirstChild("FireFolder")
	
	-- Creates the fire event folder
	newFireEvent.EventFolder = Instance.new("Folder")
	newFireEvent.EventFolder.Name = Building.Name.." Fire"
	newFireEvent.EventFolder.Parent = FireFolder
	
	
	
	newFireEvent.FirePoints = Room:FindFirstChild("FirePoints")
	
	newFireEvent.StartLocal = StartLocation
	
	newFireEvent.Rooms = Building:GetChildren()
	newFireEvent.StartingRoom = Room
	
	newFireEvent.Fires = {}
	
	-- Initiates the first fire in the event
	local NF = FireObjects.new(5,StartLocation.Position,newFireEvent,newFireEvent.EventFolder,Room)
	table.insert(newFireEvent.Fires,NF)
	return newFireEvent
end

-- New Room Fire - Event Trigger
function FireEvent:NewRoomFire(IgnitionPoint,room)
	
	--if IgnitionPoint.Parent.Ignited.Value == false then
		local newRoomFire = FireObjects.new(5,IgnitionPoint.Position,self,self.EventFolder,room)
		newRoomFire:Spread()
		table.insert(self.Fires,newRoomFire)
	--end
end
-- Initiates fire spread - Event Trigger
function FireEvent:Action()
	for i,v in pairs(self.Fires) do
		v:Spread()
	end
end
-- Initiates Destroy - Event Trigger
function FireEvent:Destroy()
	self.EventFolder:Destroy()
end







return FireEvent
