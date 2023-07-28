--[[
Author: Vitorio Bimbato - VintoKrieg
Date: 12/07/2023
Description: This script is the object constructor module for an individual fire instance 
]]--
local FireInstance = {} 
FireInstance.__index = FireInstance
local FireHandlingService = script.Parent
--Function checks if an item is in a list
local function isItemInList(list,target)
	for _,v in pairs(list) do
		if v == target then
			return true
		end
	end
	return false
end
-- Calculates and generates the vectors for the fire spread
local function GenerateExpansion(FirePoints,FirePart)
	local ExpandXLow,ExpandZLow,ExpandZHigh,ExpandXHigh = true,true,true,true
	-- Assigns the X and Z reference parts
	local XMaxPart = FirePoints:FindFirstChild("XMax")
	local XMinPart = FirePoints:FindFirstChild("XMin")
	local ZMaxPart = FirePoints:FindFirstChild("ZMax")
	local ZMinPart = FirePoints:FindFirstChild("ZMin")
	local XMax = XMaxPart.Position.X
	local XMin = XMinPart.Position.X
	local ZMax = ZMaxPart.Position.Z
	local ZMin = ZMinPart.Position.Z
	-- Corrects the Min and max points if they are assigned in reverse
	if XMax < XMin then
		XMax,XMin = XMin,XMax
	end
	if ZMax < ZMin then
		ZMax,ZMin = ZMin,ZMax
	end
	-- Compares values to see if a part is beyond the room boarders
	if XMax*10 <= math.floor((FirePart.Position.X + (FirePart.Size.X/2))*10) then
		ExpandXHigh = false
	end
	if XMin*10 >= math.floor((FirePart.Position.X - (FirePart.Size.X/2))*10) then
		ExpandXLow = false
	end
	if ZMax*10 <= math.floor((FirePart.Position.Z + (FirePart.Size.Z/2))*10) then
		ExpandZHigh = false
	end
	if ZMin*10 >= math.floor((FirePart.Position.Z - (FirePart.Size.Z/2))*10) then
		ExpandZLow = false
	end
	-- defines the offset and expansion amount
	local xExpand = 0
	local xOffset = 0
	local zExpand = 0
	local zOffset = 0
	-- sets the correct expansion and offset for the x values
	if ExpandXLow == true and ExpandXHigh == true then
		xExpand = 0.1
	elseif ExpandXLow == false and ExpandXHigh == true then
		xExpand = -0.05
		xOffset = 0.025
	elseif ExpandXLow == true and ExpandXHigh == false then
		xExpand = 0.05
		xOffset = -0.025
	else
		xOffset = 0
		xExpand = 0
	end
	-- sets the correct expansion and offset for the y values
	if ExpandZLow == true and ExpandZHigh == true then
		zExpand = 0.1
	elseif ExpandZLow == false and ExpandZHigh == true then
		zExpand = -0.05
		zOffset = 0.025
	elseif ExpandZLow == true and ExpandZHigh == false then
		zExpand = 0.05
		zOffset = -0.025
	else
		zOffset = 0
		zExpand = 0
	end
	local filled = false
	-- checks if all boundries are met
	if ExpandZLow == false and ExpandZHigh == false and ExpandXHigh == false and ExpandXLow == false then
		filled = true
	end
	-- returns the expansion, offset and the filled value
	return Vector3.new(xExpand,0,zExpand),Vector3.new(xOffset,0,zOffset),filled
end
-- This function will check if fire can spread to another room
function IgniteOtherRooms(MasterObject,FirePoints,FirePart)
	local RoomConnections = {}
	for _,v in pairs(FirePoints:GetChildren()) do
		if v.Name == "RoomConnection" then
			if v.Ignited.value == false then
				table.insert(RoomConnections,v)
			end
		end
	end
	if RoomConnections ~= nil then
		for i,v in pairs(RoomConnections) do
			local DP = v:FindFirstChild("DoorwayPoint")
			--Checks if the Doorway threshhold has been met
			local List = workspace:GetPartsInPart(FirePart)
			if isItemInList(List,DP) then
				return DP.Parent -- returns the fire connection room folder
			end
		end
	end
	
end

-- instantiates a new Fire Instance - Fire constructor
function FireInstance.new(Intensity,Pos,FireEvent,EventFolder,Room)
	local NewFireInstance = {}
	setmetatable(NewFireInstance,FireInstance)
	-- New Part
	NewFireInstance.FirePart = Instance.new("Part")
	NewFireInstance.FirePart.Size = Vector3.new(0.1,0.1,0.1)
	NewFireInstance.FirePart.Position = Pos
	NewFireInstance.FirePart.Anchored = true
	NewFireInstance.FirePart.Transparency = 0.95
	NewFireInstance.FirePart.Name = "FireInstance"
	NewFireInstance.FirePart.Parent = EventFolder
	NewFireInstance.RoomLink = Room
	NewFireInstance.FireEvent = FireEvent
	NewFireInstance.Spreading = false
	-- coppies the fire effects to the new fire part
	local fireEffects = FireHandlingService.FireParticles
	for _,v in pairs(fireEffects:GetChildren()) do
		v:Clone().Parent = NewFireInstance.FirePart
	end
	print("New Fire")
	return NewFireInstance
end

function FireInstance:Spread() -- Spread trigger
	spawn(function()
		if self.Spreading == false then
			self.Spreading = true
			self.RoomLink.FirePoints.RoomConnection.Room.Value.FirePoints.RoomConnection.Ignited.Value = true
			while self.Spreading == true do
				print("Spreading")
				local expand,offset,filled = GenerateExpansion(self.RoomLink.FirePoints,self.FirePart)
				local newSize = self.FirePart.Size + expand
				local newPos = self.FirePart.Position + offset
				self.FirePart.Size = newSize
				self.FirePart.Position = newPos
				local res = IgniteOtherRooms(self,self.RoomLink.FirePoints,self.FirePart)
				if res ~= nil then
					self.FireEvent:NewRoomFire(res.IgnitionSpot,res.Room.Value)
					res.Ignited.Value = true
				end
				if filled == true then
					break
				end
				wait(0.01)
			end
			print("End Spreading")
		end
	end)
end
function FireInstance:StopSpread() -- halt spread trigger
	self.Spreading = false
end

function FireInstance:Destroy() -- Destroy fire trigger
	
	self.FirePart:Destroy()
end

return FireInstance
