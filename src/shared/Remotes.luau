local RS, Run = game:GetService("ReplicatedStorage"), game:GetService("RunService")
local Remotes, cache = {}, nil
local NAMES = {
	"StateSync", "ToastFeed", "EventBanner", "BuyParadeBrainrot", "StealRivalBrainrot",
	"BankCarried", "CollectPadCash", "WhackThief", "LockPlatformGate", "BuyUpgrade",
	"PerformRebirth", "ClaimQuest", "TriggerTourScene",
}
function Remotes.Get()
	if cache then return cache end
	local f = RS:FindFirstChild("StationRemotes")
	if Run:IsServer() then
		if not f then f = Instance.new("Folder", RS) f.Name = "StationRemotes" end
		for _, n in ipairs(NAMES) do if not f:FindFirstChild(n) then local e = Instance.new("RemoteEvent", f) e.Name = n end end
	else
		f = RS:WaitForChild("StationRemotes")
	end
	local m = {}
	for _, n in ipairs(NAMES) do m[n] = f:WaitForChild(n) end
	cache = m
	return m
end
return Remotes
