--!strict
-- Single source of truth for player progression, base pets, passive income, and leaderstats.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FoodCatalog = require(ReplicatedStorage.Shared.FoodCatalog)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PetVisuals = require(script.Parent.PetVisuals)
local WorldBuilder = require(script.Parent.WorldBuilder)

export type OwnedPet = {
	Uid: string,
	PetId: string,
	Mutation: string,
	CashPerSec: number,
	SlotIndex: number,
	Locked: boolean,
	Model: Model?,
}

export type PlayerData = {
	Player: Player,
	Cash: number,
	PendingCash: number,
	ThrowPower: number,
	EquippedFoodId: string,
	OwnedFoods: { [string]: boolean },
	BaseSlots: number,
	Rebirths: number,
	Pets: { OwnedPet },
	Discovered: { [string]: boolean },
	Plot: WorldBuilder.BasePlot?,
	ShieldUntil: number,
	ShieldCooldownUntil: number,
	LuckUntil: number,
	HasteUntil: number,
	FortuneUntil: number,
	CashStat: IntValue,
	CpsStat: IntValue,
	PowerStat: IntValue,
	RebirthStat: IntValue,
}

local PlayerState = {}
local ByPlayer: { [Player]: PlayerData } = {}
local nextUid = 0

local function makeUid(): string
	nextUid += 1
	return "pet_" .. tostring(nextUid)
end

function PlayerState.InitPlayer(player: Player, plots: { WorldBuilder.BasePlot }): PlayerData
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = player

	local cashStat = Instance.new("IntValue")
	cashStat.Name = "Cash"
	cashStat.Value = 100
	cashStat.Parent = ls

	local cpsStat = Instance.new("IntValue")
	cpsStat.Name = "$/sec"
	cpsStat.Value = 0
	cpsStat.Parent = ls

	local powerStat = Instance.new("IntValue")
	powerStat.Name = "Power"
	powerStat.Value = 60
	powerStat.Parent = ls

	local rebirthStat = Instance.new("IntValue")
	rebirthStat.Name = "Rebirths"
	rebirthStat.Value = 0
	rebirthStat.Parent = ls

	-- Assign first free base plot
	local assignedPlot: WorldBuilder.BasePlot? = nil
	for _, plot in ipairs(plots) do
		if plot.OwnerUserId == nil then
			plot.OwnerUserId = player.UserId
			plot.OwnerLabel.Text = player.DisplayName .. "'s BASE"
			assignedPlot = plot
			break
		end
	end

	local data: PlayerData = {
		Player = player,
		Cash = 100,
		PendingCash = 0,
		ThrowPower = 60,
		EquippedFoodId = "onigiri",
		OwnedFoods = { onigiri = true },
		BaseSlots = GameConfig.StartBaseSlots,
		Rebirths = 0,
		Pets = {},
		Discovered = {},
		Plot = assignedPlot,
		ShieldUntil = 0,
		ShieldCooldownUntil = 0,
		LuckUntil = 0,
		HasteUntil = 0,
		FortuneUntil = 0,
		CashStat = cashStat,
		CpsStat = cpsStat,
		PowerStat = powerStat,
		RebirthStat = rebirthStat,
	}

	ByPlayer[player] = data

	-- Give 1 starter Narutini Ramenini so the base immediately ticks $/sec!
	PlayerState.AddPet(data, "narutini", "Normal")
	PlayerState.RefreshPlotVisuals(data)
	PlayerState.Sync(data)

	return data
end

function PlayerState.Get(player: Player): PlayerData?
	return ByPlayer[player]
end

function PlayerState.GetAll(): { [Player]: PlayerData }
	return ByPlayer
end

function PlayerState.GetTotalCps(data: PlayerData): number
	local sum = 0
	for _, p in ipairs(data.Pets) do
		sum += p.CashPerSec
	end
	return math.floor(sum * GameConfig.GetRebirthMultiplier(data.Rebirths))
end

function PlayerState.RefreshPlotVisuals(data: PlayerData)
	local plot = data.Plot
	if not plot then
		return
	end

	for i, ped in ipairs(plot.Pedestals) do
		if i <= data.BaseSlots then
			ped.Color = Color3.fromRGB(72, 86, 122)
		else
			ped.Color = Color3.fromRGB(44, 44, 52)
		end
	end

	plot.CollectLabel.Text = "$" .. tostring(math.floor(data.PendingCash))
	local now = os.clock()
	if now < data.ShieldUntil then
		plot.ShieldLabel.Text = "LOCKED (" .. tostring(math.ceil(data.ShieldUntil - now)) .. "s)"
		plot.ShieldDome.Transparency = 0.72
		plot.ShieldPad.Color = Color3.fromRGB(72, 255, 168)
	elseif now < data.ShieldCooldownUntil then
		plot.ShieldLabel.Text = "CD (" .. tostring(math.ceil(data.ShieldCooldownUntil - now)) .. "s)"
		plot.ShieldDome.Transparency = 1
		plot.ShieldPad.Color = Color3.fromRGB(255, 108, 92)
	else
		plot.ShieldLabel.Text = "SHIELD READY"
		plot.ShieldDome.Transparency = 1
		plot.ShieldPad.Color = Color3.fromRGB(72, 188, 255)
	end
end

function PlayerState.AddPet(data: PlayerData, petId: string, mutationName: string): (boolean, string)
	if #data.Pets >= data.BaseSlots then
		return false, "Base full! Upgrade slots or sell a pet."
	end

	local def = PetCatalog.GetById(petId)
	if not def then
		return false, "Unknown pet"
	end

	local mut = PetCatalog.GetMutation(mutationName)
	local cps = math.max(1, math.floor(def.BaseCashPerSec * mut.Multiplier))

	-- Find free slot
	local used: { [number]: boolean } = {}
	for _, p in ipairs(data.Pets) do
		used[p.SlotIndex] = true
	end
	local freeSlot = 1
	for i = 1, data.BaseSlots do
		if not used[i] then
			freeSlot = i
			break
		end
	end

	local model: Model? = nil
	if data.Plot then
		local ped = data.Plot.Pedestals[freeSlot]
		if ped then
			local cf = CFrame.new(ped.Position + Vector3.new(0, 0.35, 0)) * CFrame.Angles(0, math.rad(180), 0)
			model = PetVisuals.CreateModel(petId, mutationName, cf, cps)
			model.Parent = data.Plot.Model
		end
	end

	local entry: OwnedPet = {
		Uid = makeUid(),
		PetId = petId,
		Mutation = mutationName,
		CashPerSec = cps,
		SlotIndex = freeSlot,
		Locked = false,
		Model = model,
	}
	table.insert(data.Pets, entry)
	data.Discovered[petId] = true
	data.CpsStat.Value = PlayerState.GetTotalCps(data)

	return true, def.DisplayName
end

function PlayerState.RemovePetByUid(data: PlayerData, uid: string): OwnedPet?
	for i, p in ipairs(data.Pets) do
		if p.Uid == uid then
			if p.Model then
				p.Model:Destroy()
			end
			table.remove(data.Pets, i)
			data.CpsStat.Value = PlayerState.GetTotalCps(data)
			return p
		end
	end
	return nil
end

function PlayerState.ClearAllPets(data: PlayerData)
	for _, p in ipairs(data.Pets) do
		if p.Model then
			p.Model:Destroy()
		end
	end
	table.clear(data.Pets)
	data.CpsStat.Value = 0
end

function PlayerState.Sync(data: PlayerData)
	data.CashStat.Value = math.floor(data.Cash)
	data.CpsStat.Value = PlayerState.GetTotalCps(data)
	data.PowerStat.Value = math.floor(data.ThrowPower)
	data.RebirthStat.Value = data.Rebirths

	local serializedPets = {}
	for _, p in ipairs(data.Pets) do
		table.insert(serializedPets, {
			Uid = p.Uid,
			PetId = p.PetId,
			Mutation = p.Mutation,
			CashPerSec = p.CashPerSec,
			SlotIndex = p.SlotIndex,
			Locked = p.Locked,
		})
	end

	local discoveredCount = 0
	for _ in pairs(data.Discovered) do
		discoveredCount += 1
	end

	local now = os.clock()
	local food = FoodCatalog.GetById(data.EquippedFoodId)
	local payload = {
		Cash = math.floor(data.Cash),
		PendingCash = math.floor(data.PendingCash),
		CashPerSec = PlayerState.GetTotalCps(data),
		ThrowPower = math.floor(data.ThrowPower),
		EquippedFoodId = data.EquippedFoodId,
		EquippedFoodName = food.DisplayName,
		OwnedFoods = data.OwnedFoods,
		BaseSlots = data.BaseSlots,
		NextSlotCost = GameConfig.GetSlotUpgradeCost(data.BaseSlots),
		Rebirths = data.Rebirths,
		NextRebirthCost = GameConfig.GetRebirthCost(data.Rebirths),
		RebirthMult = GameConfig.GetRebirthMultiplier(data.Rebirths),
		LuckRemaining = math.max(0, math.ceil(data.LuckUntil - now)),
		HasteRemaining = math.max(0, math.ceil(data.HasteUntil - now)),
		FortuneRemaining = math.max(0, math.ceil(data.FortuneUntil - now)),
		Pets = serializedPets,
		Discovered = data.Discovered,
		DiscoveredCount = discoveredCount,
		TotalCatalog = #PetCatalog.Pets,
	}

	Remotes.Get(Remotes.EventNames.StateSync):FireClient(data.Player, payload)
end

function PlayerState.CleanupPlayer(player: Player)
	local data = ByPlayer[player]
	if not data then
		return
	end
	PlayerState.ClearAllPets(data)
	if data.Plot then
		data.Plot.OwnerUserId = nil
		data.Plot.OwnerLabel.Text = "OPEN BASE #" .. tostring(data.Plot.Index)
		data.Plot.CollectLabel.Text = "$0"
		data.Plot.ShieldDome.Transparency = 1
		data.Plot.ShieldLabel.Text = "SHIELD READY"
	end
	ByPlayer[player] = nil
end

return PlayerState
