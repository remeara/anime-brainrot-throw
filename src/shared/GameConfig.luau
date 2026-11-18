--!strict
-- Shared world coordinates, zones, upgrade formulas, and event timings.

export type ZoneDef = {
	Name: string,
	StartZ: number, -- distance along -Z from throw line
	EndZ: number,
	Color: Color3,
	AccentColor: Color3,
	MinRarity: string,
}

local GameConfig = {}

-- World layout along Z axis:
-- Hub Plaza: Z = +40 to -10 (Throw line is at Z = -10)
-- Zones extend along -Z from Z = -10 to Z = -460
GameConfig.ThrowLineZ = -10
GameConfig.HubCenter = Vector3.new(0, 3, 25)
GameConfig.TrainStandPos = Vector3.new(-34, 1, 18)
GameConfig.FoodShopPos = Vector3.new(34, 1, 18)

GameConfig.Zones = {
	{
		Name = "Starter Meadow",
		StartZ = 0,
		EndZ = 75,
		Color = Color3.fromRGB(96, 196, 98),
		AccentColor = Color3.fromRGB(142, 232, 128),
		MinRarity = "Common",
	},
	{
		Name = "Pirate & Bamboo Valley",
		StartZ = 75,
		EndZ = 155,
		Color = Color3.fromRGB(78, 172, 214),
		AccentColor = Color3.fromRGB(240, 214, 132),
		MinRarity = "Uncommon",
	},
	{
		Name = "Soul & Chainsaw District",
		StartZ = 155,
		EndZ = 240,
		Color = Color3.fromRGB(122, 92, 196),
		AccentColor = Color3.fromRGB(255, 138, 72),
		MinRarity = "Rare",
	},
	{
		Name = "Saiyan & Titan Canyon",
		StartZ = 240,
		EndZ = 330,
		Color = Color3.fromRGB(214, 108, 64),
		AccentColor = Color3.fromRGB(255, 224, 78),
		MinRarity = "Epic",
	},
	{
		Name = "Domain & Void Shrine",
		StartZ = 330,
		EndZ = 440,
		Color = Color3.fromRGB(64, 28, 72),
		AccentColor = Color3.fromRGB(255, 64, 128),
		MinRarity = "Legendary",
	},
} :: { ZoneDef }

GameConfig.MaxBaseSlots = 12
GameConfig.StartBaseSlots = 4
GameConfig.ShieldDuration = 25 -- seconds
GameConfig.ShieldCooldown = 35 -- seconds
GameConfig.WaveInterval = 50 -- seconds between Brainrot Storm / Rival Raid events
GameConfig.WaveDuration = 12 -- seconds

function GameConfig.GetSlotUpgradeCost(currentSlots: number): number
	return math.floor(250 * (2.2 ^ (currentSlots - GameConfig.StartBaseSlots)))
end

function GameConfig.GetRebirthCost(rebirths: number): number
	return math.floor(15000 * (4 ^ rebirths))
end

function GameConfig.GetRebirthMultiplier(rebirths: number): number
	return 2 ^ rebirths
end

return GameConfig
