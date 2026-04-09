--[[
	RebirthService - Handles player rebirth/ascension system
	Resets progress but provides permanent multiplier
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RebirthService = {}
RebirthService.__index = RebirthService

-- Minimum coins required for first rebirth
local REBIRTH_MIN_COINS = 500

-- Remote for rebirth request
local rebirthRemote

function RebirthService:Init(services)
	self.DataService = services.DataService

	rebirthRemote = ReplicatedStorage.Remotes:FindFirstChild("RebirthRequest")
	if not rebirthRemote then
		rebirthRemote = Instance.new("RemoteEvent")
		rebirthRemote.Name = "RebirthRequest"
		rebirthRemote.Parent = ReplicatedStorage.Remotes
	end

	rebirthRemote.OnServerEvent:Connect(function(player)
		self:HandleRebirthRequest(player)
	end)
end

function RebirthService:HandleRebirthRequest(player)
	local data = self.DataService:Get(player)
	if not data then
		return
	end

	-- Check minimum coins
	if data.Economy.Coins < REBIRTH_MIN_COINS then
		print("Not enough coins to rebirth. Need:", REBIRTH_MIN_COINS, "Have:", data.Economy.Coins)
		return
	end

	-- Perform rebirth
	self.DataService:Rebirth(player)

	print(player.Name, "rebirthed! New multiplier:", data.Economy.RebirthMultiplier)
end

return RebirthService
