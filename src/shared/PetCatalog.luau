--!strict
-- Catalog of 12 Anime MC Brainrot Pets across 7 rarities + 4 mutations.

export type RarityInfo = {
	Name: string,
	Color: Color3,
	Order: number,
}

export type MutationInfo = {
	Name: string,
	Multiplier: number,
	Color: Color3,
}

export type PetDef = {
	Id: string,
	DisplayName: string,
	AnimeRef: string,
	Rarity: string,
	BaseCashPerSec: number,
	MinDistance: number,
	Weight: number,
	BodyColor: Color3,
	AccentColor: Color3,
	HairColor: Color3,
	StyleTag: string, -- "Ninja", "Deku", "Pirate", "Slayer", "Shinigami", "Chainsaw", "Saiyan", "Titan", "Baldy", "Jotaro", "Gojo", "Sukuna"
	Quote: string,
}

local PetCatalog = {}

PetCatalog.Rarities = {
	Common = { Name = "Common", Color = Color3.fromRGB(190, 198, 210), Order = 1 },
	Uncommon = { Name = "Uncommon", Color = Color3.fromRGB(92, 224, 128), Order = 2 },
	Rare = { Name = "Rare", Color = Color3.fromRGB(74, 165, 255), Order = 3 },
	Epic = { Name = "Epic", Color = Color3.fromRGB(185, 92, 255), Order = 4 },
	Legendary = { Name = "Legendary", Color = Color3.fromRGB(255, 186, 46), Order = 5 },
	Mythic = { Name = "Mythic", Color = Color3.fromRGB(255, 72, 118), Order = 6 },
	BrainrotGod = { Name = "Brainrot God", Color = Color3.fromRGB(255, 238, 88), Order = 7 },
} :: { [string]: RarityInfo }

PetCatalog.Mutations = {
	{ Name = "Normal", Multiplier = 1.0, Color = Color3.fromRGB(235, 235, 240) },
	{ Name = "Golden", Multiplier = 2.0, Color = Color3.fromRGB(255, 215, 64) },
	{ Name = "Diamond", Multiplier = 3.5, Color = Color3.fromRGB(90, 235, 255) },
	{ Name = "Rainbow", Multiplier = 6.0, Color = Color3.fromRGB(255, 110, 230) },
} :: { MutationInfo }

PetCatalog.Pets = {
	{
		Id = "narutini",
		DisplayName = "Narutini Ramenini",
		AnimeRef = "Ninja Hokage",
		Rarity = "Common",
		BaseCashPerSec = 5,
		MinDistance = 0,
		Weight = 45,
		BodyColor = Color3.fromRGB(255, 136, 36),
		AccentColor = Color3.fromRGB(36, 62, 130),
		HairColor = Color3.fromRGB(255, 220, 65),
		StyleTag = "Ninja",
		Quote = "BELIEVE IT BRO!",
	},
	{
		Id = "dekucry",
		DisplayName = "Deku Cryington",
		AnimeRef = "Plus Ultra Hero",
		Rarity = "Common",
		BaseCashPerSec = 8,
		MinDistance = 0,
		Weight = 40,
		BodyColor = Color3.fromRGB(48, 168, 112),
		AccentColor = Color3.fromRGB(220, 52, 52),
		HairColor = Color3.fromRGB(38, 128, 72),
		StyleTag = "Deku",
		Quote = "SMASH MY WALLET!",
	},
	{
		Id = "luffini",
		DisplayName = "Luffini GumGumini",
		AnimeRef = "Straw Hat Pirate",
		Rarity = "Uncommon",
		BaseCashPerSec = 18,
		MinDistance = 55,
		Weight = 32,
		BodyColor = Color3.fromRGB(230, 56, 56),
		AccentColor = Color3.fromRGB(245, 210, 88),
		HairColor = Color3.fromRGB(26, 26, 32),
		StyleTag = "Pirate",
		Quote = "KING OF BRAINROT!",
	},
	{
		Id = "tanjirini",
		DisplayName = "Tanjirini Bamboozle",
		AnimeRef = "Sun Breather",
		Rarity = "Uncommon",
		BaseCashPerSec = 26,
		MinDistance = 65,
		Weight = 28,
		BodyColor = Color3.fromRGB(46, 178, 126),
		AccentColor = Color3.fromRGB(24, 26, 30),
		HairColor = Color3.fromRGB(128, 34, 44),
		StyleTag = "Slayer",
		Quote = "WATER BREATHING TAX!",
	},
	{
		Id = "ichigini",
		DisplayName = "Ichigini Bankai-Bro",
		AnimeRef = "Soul Reaper",
		Rarity = "Rare",
		BaseCashPerSec = 55,
		MinDistance = 115,
		Weight = 22,
		BodyColor = Color3.fromRGB(28, 28, 36),
		AccentColor = Color3.fromRGB(245, 245, 250),
		HairColor = Color3.fromRGB(255, 134, 42),
		StyleTag = "Shinigami",
		Quote = "BAN-KAI... NO RENT!",
	},
	{
		Id = "denjini",
		DisplayName = "Denjini Chainsawini",
		AnimeRef = "Chainsaw Devil",
		Rarity = "Rare",
		BaseCashPerSec = 78,
		MinDistance = 125,
		Weight = 20,
		BodyColor = Color3.fromRGB(255, 118, 38),
		AccentColor = Color3.fromRGB(50, 54, 66),
		HairColor = Color3.fromRGB(250, 212, 85),
		StyleTag = "Chainsaw",
		Quote = "VROOM VROOM TOAST!",
	},
	{
		Id = "gokuni",
		DisplayName = "Gokuni Screamington",
		AnimeRef = "Super Saiyan",
		Rarity = "Epic",
		BaseCashPerSec = 165,
		MinDistance = 185,
		Weight = 15,
		BodyColor = Color3.fromRGB(255, 122, 26),
		AccentColor = Color3.fromRGB(42, 88, 210),
		HairColor = Color3.fromRGB(255, 232, 62),
		StyleTag = "Saiyan",
		Quote = "OVER 9000 IQ LOSS!",
	},
	{
		Id = "erenini",
		DisplayName = "Erenini Rumblingz",
		AnimeRef = "Survey Titan",
		Rarity = "Epic",
		BaseCashPerSec = 230,
		MinDistance = 195,
		Weight = 13,
		BodyColor = Color3.fromRGB(62, 124, 72),
		AccentColor = Color3.fromRGB(165, 118, 78),
		HairColor = Color3.fromRGB(68, 46, 34),
		StyleTag = "Titan",
		Quote = "TATAKAE FOR SNACKS!",
	},
	{
		Id = "saitamini",
		DisplayName = "Saitamini Baldy-One",
		AnimeRef = "One Punch Baldy",
		Rarity = "Legendary",
		BaseCashPerSec = 520,
		MinDistance = 255,
		Weight = 9,
		BodyColor = Color3.fromRGB(255, 222, 52),
		AccentColor = Color3.fromRGB(228, 44, 44),
		HairColor = Color3.fromRGB(255, 224, 189),
		StyleTag = "Baldy",
		Quote = "OK. 100 PUSHUPS.",
	},
	{
		Id = "jotarini",
		DisplayName = "Jotarini YareYare",
		AnimeRef = "Stardust Crusader",
		Rarity = "Legendary",
		BaseCashPerSec = 760,
		MinDistance = 265,
		Weight = 8,
		BodyColor = Color3.fromRGB(36, 36, 52),
		AccentColor = Color3.fromRGB(255, 206, 62),
		HairColor = Color3.fromRGB(22, 22, 30),
		StyleTag = "Jotaro",
		Quote = "ORA ORA ORA!",
	},
	{
		Id = "gojini",
		DisplayName = "Gojini Infinite-Brain",
		AnimeRef = "Limitless Sorcerer",
		Rarity = "Mythic",
		BaseCashPerSec = 1850,
		MinDistance = 320,
		Weight = 4.5,
		BodyColor = Color3.fromRGB(30, 34, 54),
		AccentColor = Color3.fromRGB(120, 220, 255),
		HairColor = Color3.fromRGB(245, 248, 255),
		StyleTag = "Gojo",
		Quote = "NAH, I'D BRAINROT.",
	},
	{
		Id = "sukunini",
		DisplayName = "Asta-Sukunini Chaos",
		AnimeRef = "Shrine King",
		Rarity = "BrainrotGod",
		BaseCashPerSec = 5200,
		MinDistance = 370,
		Weight = 2.0,
		BodyColor = Color3.fromRGB(48, 20, 38),
		AccentColor = Color3.fromRGB(255, 48, 92),
		HairColor = Color3.fromRGB(255, 138, 178),
		StyleTag = "Sukuna",
		Quote = "DOMAIN EXPANSION: OHIO!",
	},
} :: { PetDef }

local ById: { [string]: PetDef } = {}
for _, pet in ipairs(PetCatalog.Pets) do
	ById[pet.Id] = pet
end

function PetCatalog.GetById(id: string): PetDef?
	return ById[id]
end

function PetCatalog.GetMutation(name: string): MutationInfo
	for _, m in ipairs(PetCatalog.Mutations) do
		if m.Name == name then
			return m
		end
	end
	return PetCatalog.Mutations[1]
end

function PetCatalog.RollMutation(luckMult: number): MutationInfo
	local roll = math.random() * 100
	local rainbowChance = math.min(18, 1.5 * luckMult)
	local diamondChance = math.min(28, 5.0 * luckMult)
	local goldenChance = math.min(45, 14.0 * luckMult)

	if roll < rainbowChance then
		return PetCatalog.Mutations[4]
	elseif roll < rainbowChance + diamondChance then
		return PetCatalog.Mutations[3]
	elseif roll < rainbowChance + diamondChance + goldenChance then
		return PetCatalog.Mutations[2]
	end
	return PetCatalog.Mutations[1]
end

return PetCatalog
