--!strict
-- Catalog of throwable anime foods that boost lure radius, throw distance, and rarity/mutation luck.

export type FoodDef = {
	Id: string,
	DisplayName: string,
	Cost: number,
	PowerMult: number,
	LureRadius: number,
	LuckMult: number,
	Color: Color3,
	AccentColor: Color3,
	Description: string,
}

local FoodCatalog = {}

FoodCatalog.Foods = {
	{
		Id = "onigiri",
		DisplayName = "Moldy Onigiri",
		Cost = 0,
		PowerMult = 1.0,
		LureRadius = 16,
		LuckMult = 1.0,
		Color = Color3.fromRGB(245, 245, 240),
		AccentColor = Color3.fromRGB(38, 46, 38),
		Description = "Starter rice ball. Slightly cursed.",
	},
	{
		Id = "ramen",
		DisplayName = "Ichiraku Ramen",
		Cost = 150,
		PowerMult = 1.35,
		LureRadius = 21,
		LuckMult = 1.4,
		Color = Color3.fromRGB(255, 206, 92),
		AccentColor = Color3.fromRGB(214, 52, 48),
		Description = "Hot miso broth attracts ninja & pirate MCs.",
	},
	{
		Id = "devilfruit",
		DisplayName = "Gomu Devil Fruit",
		Cost = 1200,
		PowerMult = 1.75,
		LureRadius = 26,
		LuckMult = 2.0,
		Color = Color3.fromRGB(168, 72, 245),
		AccentColor = Color3.fromRGB(80, 220, 120),
		Description = "Swirly purple fruit. Terrible taste, huge range.",
	},
	{
		Id = "senzu",
		DisplayName = "Senzu Bean",
		Cost = 8500,
		PowerMult = 2.25,
		LureRadius = 32,
		LuckMult = 2.8,
		Color = Color3.fromRGB(92, 236, 118),
		AccentColor = Color3.fromRGB(242, 248, 225),
		Description = "Restores 100% brainrot stamina. Reaches Saiyan Zone.",
	},
	{
		Id = "finger",
		DisplayName = "Cursed Finger",
		Cost = 48000,
		PowerMult = 2.85,
		LureRadius = 38,
		LuckMult = 4.0,
		Color = Color3.fromRGB(186, 48, 78),
		AccentColor = Color3.fromRGB(64, 24, 42),
		Description = "Warning: attracts Gojini & Sukunini.",
	},
	{
		Id = "takoyaki",
		DisplayName = "Cosmic Takoyaki",
		Cost = 260000,
		PowerMult = 3.6,
		LureRadius = 46,
		LuckMult = 6.0,
		Color = Color3.fromRGB(255, 198, 64),
		AccentColor = Color3.fromRGB(110, 220, 255),
		Description = "Galaxy-glazed octopus balls. Maximum luck!",
	},
} :: { FoodDef }

export type PotionDef = {
	Id: string,
	DisplayName: string,
	Cost: number,
	Duration: number,
	Description: string,
	Color: Color3,
}

FoodCatalog.Potions = {
	{
		Id = "super_luck",
		DisplayName = "Super Luck Potion",
		Cost = 600,
		Duration = 180,
		Description = "+100% Rarity & Mutation Luck for 3m",
		Color = Color3.fromHex("#22C55E"),
	},
	{
		Id = "throw_haste",
		DisplayName = "Throw Haste Potion",
		Cost = 450,
		Duration = 180,
		Description = "Cuts throw cooldown in half (0.3s) for 3m",
		Color = Color3.fromHex("#0EA5E9"),
	},
	{
		Id = "fortune_elixir",
		DisplayName = "Fortune Elixir",
		Cost = 2200,
		Duration = 120,
		Description = "+250% Mutation Odds for 2m",
		Color = Color3.fromHex("#A855F7"),
	},
} :: { PotionDef }

local ById: { [string]: FoodDef } = {}
for _, food in ipairs(FoodCatalog.Foods) do
	ById[food.Id] = food
end

local PotionById: { [string]: PotionDef } = {}
for _, pot in ipairs(FoodCatalog.Potions) do
	PotionById[pot.Id] = pot
end

function FoodCatalog.GetById(id: string): FoodDef
	return ById[id] or FoodCatalog.Foods[1]
end

function FoodCatalog.GetPotionById(id: string): PotionDef?
	return PotionById[id]
end

return FoodCatalog
