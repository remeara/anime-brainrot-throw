--!strict
-- Centralized RemoteEvent / RemoteFunction creation and lookup.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

Remotes.EventNames = {
	ThrowFood = "ThrowFood",
	ThrowResult = "ThrowResult",
	StateSync = "StateSync",
	BuyFood = "BuyFood",
	EquipFood = "EquipFood",
	BuyPotion = "BuyPotion",
	ToggleLockPet = "ToggleLockPet",
	TrainPower = "TrainPower",
	UpgradeSlots = "UpgradeSlots",
	ToggleShield = "ToggleShield",
	CollectCash = "CollectCash",
	SellPet = "SellPet",
	Rebirth = "Rebirth",
	StealPet = "StealPet",
	EventBanner = "EventBanner",
	TeleportBase = "TeleportBase",
}

function Remotes.EnsureAll(): Folder
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		local newFolder = Instance.new("Folder")
		newFolder.Name = "Remotes"
		newFolder.Parent = ReplicatedStorage
		folder = newFolder
	end

	for _, name in pairs(Remotes.EventNames) do
		if not folder:FindFirstChild(name) then
			local re = Instance.new("RemoteEvent")
			re.Name = name
			re.Parent = folder
		end
	end

	return folder :: Folder
end

function Remotes.Get(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild("Remotes")
	return folder:WaitForChild(name) :: RemoteEvent
end

return Remotes
