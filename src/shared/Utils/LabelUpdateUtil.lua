-- LabelUpdateUtil is deprecated
-- All data synchronization is now handled by DataService with ProfileService
-- This file is kept for backward compatibility only

local LabelUpdateUtil = {}

function LabelUpdateUtil:Init(dataService)
	-- No-op
end

function LabelUpdateUtil:SyncCoins(player)
	-- No-op
end

function LabelUpdateUtil:SyncTires(player)
	-- No-op
end

function LabelUpdateUtil:SyncPower(player)
	-- No-op
end

function LabelUpdateUtil:SyncCarry(player)
	-- No-op
end

return LabelUpdateUtil
