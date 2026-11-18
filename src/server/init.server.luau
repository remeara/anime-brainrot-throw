--!strict
-- Main server orchestrator: world setup, food throwing, wild pet catching, rival raids, and economy.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local FoodCatalog = require(ReplicatedStorage.Shared.FoodCatalog)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local PetVisuals = require(script.PetVisuals)
local PlayerState = require(script.PlayerState)
local WorldBuilder = require(script.WorldBuilder)

Remotes.EnsureAll()
local worldInfo = WorldBuilder.Build()

local wildFolder = Instance.new("Folder")
wildFolder.Name = "WildBrainrots"
wildFolder.Parent = Workspace

local rivalFolder = Instance.new("Folder")
rivalFolder.Name = "RivalPets"
rivalFolder.Parent = Workspace

type WildPet = {
	PetId: string,
	Distance: number,
	Position: Vector3,
	Model: Model,
}

local wildPets: { WildPet } = {}

local function pickPetForDistance(dist: number, luckMult: number): PetCatalog.PetDef
	local candidates: { PetCatalog.PetDef } = {}
	local totalWeight = 0
	for _, pet in ipairs(PetCatalog.Pets) do
		if dist >= pet.MinDistance then
			-- Higher luck boosts rarer (lower weight) pets
			local adjWeight = pet.Weight
			if pet.MinDistance >= 180 then
				adjWeight = pet.Weight * (1 + (luckMult - 1) * 0.45)
			end
			table.insert(candidates, pet)
			totalWeight += adjWeight
		end
	end
	if #candidates == 0 then
		return PetCatalog.Pets[1]
	end
	local roll = math.random() * totalWeight
	local acc = 0
	for _, pet in ipairs(candidates) do
		local adjWeight = pet.Weight
		if pet.MinDistance >= 180 then
			adjWeight = pet.Weight * (1 + (luckMult - 1) * 0.45)
		end
		acc += adjWeight
		if roll <= acc then
			return pet
		end
	end
	return candidates[#candidates]
end

local function spawnWildPet(distMin: number, distMax: number)
	local dist = math.random(distMin, distMax)
	local def = pickPetForDistance(dist, 1.0)
	local x = math.random(-38, 38)
	local z = GameConfig.ThrowLineZ - dist
	local pos = Vector3.new(x, 1.1, z)
	local cf = CFrame.new(pos) * CFrame.Angles(0, math.rad(math.random(0, 359)), 0)
	local model = PetVisuals.CreateModel(def.Id, "Normal", cf, def.BaseCashPerSec, "WILD • Throw Food!")
	model.Parent = wildFolder

	table.insert(wildPets, {
		PetId = def.Id,
		Distance = dist,
		Position = pos,
		Model = model,
	})
end

-- Populate initial wild anime pets across all 5 zones
for _, zDef in ipairs(GameConfig.Zones) do
	for _ = 1, 4 do
		spawnWildPet(zDef.StartZ + 8, zDef.EndZ - 8)
	end
end

-- Populate Rival Base with 2 stealable pets
local function refreshRivalPets()
	rivalFolder:ClearAllChildren()
	local rivalChoices = { "luffini", "ichigini", "gokuni", "saitamini", "gojini" }
	for i = 1, 2 do
		local petId = rivalChoices[math.random(1, #rivalChoices)]
		local def = PetCatalog.GetById(petId) or PetCatalog.Pets[1]
		local mut = PetCatalog.RollMutation(1.5)
		local cps = math.floor(def.BaseCashPerSec * mut.Multiplier)
		local pos = worldInfo.RivalPad.Position + Vector3.new((i - 1.5) * 7, 0.7, 0)
		local model = PetVisuals.CreateModel(def.Id, mut.Name, CFrame.new(pos), cps, "STEAL ME! [E]")
		model.Parent = rivalFolder

		if model.PrimaryPart then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Steal " .. def.DisplayName
			prompt.ObjectText = "Rival Brainrot"
			prompt.HoldDuration = 0.4
			prompt.MaxActivationDistance = 10
			prompt.Parent = model.PrimaryPart

			prompt.Triggered:Connect(function(player: Player)
				local data = PlayerState.Get(player)
				if not data then
					return
				end
				local ok, msg = PlayerState.AddPet(data, def.Id, mut.Name)
				if ok then
					model:Destroy()
					PlayerState.Sync(data)
					Remotes.Get(Remotes.EventNames.EventBanner):FireClient(player, {
						Text = "STOLEN " .. def.DisplayName .. " (" .. mut.Name .. ")!",
						Color = Color3.fromRGB(255, 196, 62),
					})
				else
					Remotes.Get(Remotes.EventNames.EventBanner):FireClient(player, {
						Text = msg,
						Color = Color3.fromRGB(255, 92, 92),
					})
				end
			end)
		end
	end
end
refreshRivalPets()

-- Connect Base Plot interactions
for _, plot in ipairs(worldInfo.BasePlots) do
	plot.CollectPad.Touched:Connect(function(hit: BasePart)
		local char = hit.Parent
		local player = if char then Players:GetPlayerFromCharacter(char) else nil
		if not player then
			return
		end
		local data = PlayerState.Get(player)
		if data and data.Plot == plot and data.PendingCash >= 1 then
			local gained = math.floor(data.PendingCash)
			data.Cash += gained
			data.PendingCash = 0
			PlayerState.RefreshPlotVisuals(data)
			PlayerState.Sync(data)
		end
	end)

	local shieldPrompt = plot.ShieldPad:FindFirstChildOfClass("ProximityPrompt")
	if shieldPrompt then
		shieldPrompt.Triggered:Connect(function(player: Player)
			local data = PlayerState.Get(player)
			if not data or data.Plot ~= plot then
				return
			end
			local now = os.clock()
			if now < data.ShieldUntil or now < data.ShieldCooldownUntil then
				return
			end
			data.ShieldUntil = now + GameConfig.ShieldDuration
			data.ShieldCooldownUntil = data.ShieldUntil + GameConfig.ShieldCooldown
			PlayerState.RefreshPlotVisuals(data)
			Remotes.Get(Remotes.EventNames.EventBanner):FireClient(player, {
				Text = "BASE SHIELD LOCKED FOR " .. tostring(GameConfig.ShieldDuration) .. "s!",
				Color = Color3.fromRGB(72, 232, 168),
			})
		end)
	end
end

-- Aura Training Stand
worldInfo.TrainPrompt.Triggered:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	local gain = 4 + data.Rebirths * 2
	data.ThrowPower += gain
	PlayerState.Sync(data)
	Remotes.Get(Remotes.EventNames.EventBanner):FireClient(player, {
		Text = "+" .. tostring(gain) .. " THROW POWER!",
		Color = Color3.fromRGB(255, 168, 62),
	})
end)

-- Food Shop Prompt -> tells client to open Food Shop
worldInfo.ShopPrompt.Triggered:Connect(function(player: Player)
	Remotes.Get(Remotes.EventNames.BuyFood):FireClient(player, { OpenShop = true })
end)

-- Player Lifecycle
Players.PlayerAdded:Connect(function(player: Player)
	local data = PlayerState.InitPlayer(player, worldInfo.BasePlots)
	player.CharacterAdded:Connect(function(char: Model)
		task.wait(0.2)
		if data.Plot then
			local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				hrp.CFrame = CFrame.new(data.Plot.Origin + Vector3.new(0, 4, -14))
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerState.CleanupPlayer(player)
end)

-- Throw Food Remote
Remotes.Get(Remotes.EventNames.ThrowFood).OnServerEvent:Connect(function(player: Player, powerRatio: number, aimX: number)
	local data = PlayerState.Get(player)
	if not data then
		return
	end

	local ratio = math.clamp(tonumber(powerRatio) or 0.5, 0.15, 1.0)
	local isPerfect = ratio >= 0.86 and ratio <= 0.96
	local perfectMult = if isPerfect then 1.32 else 1.0
	local food = FoodCatalog.GetById(data.EquippedFoodId)

	-- Compute landing distance along -Z
	local baseDist = data.ThrowPower * food.PowerMult * (0.45 + 0.65 * ratio) * perfectMult
	local dist = math.clamp(baseDist, 18, 435)
	local targetX = math.clamp(tonumber(aimX) or 0, -40, 40)
	local landPos = Vector3.new(targetX, 1.2, GameConfig.ThrowLineZ - dist)

	-- Check if any wild pet is within food's lure radius
	local caughtWildIndex: number? = nil
	local bestDist = food.LureRadius
	for i, wp in ipairs(wildPets) do
		local d = (Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(landPos.X, 0, landPos.Z)).Magnitude
		if d <= bestDist then
			bestDist = d
			caughtWildIndex = i
		end
	end

	local now = os.clock()
	local luckBoost = if now < data.LuckUntil then 2.0 else 1.0
	local fortuneBoost = if now < data.FortuneUntil then 3.5 else 1.0
	local totalLuck = food.LuckMult * luckBoost

	local chosenDef: PetCatalog.PetDef
	if caughtWildIndex then
		local wp = wildPets[caughtWildIndex]
		chosenDef = PetCatalog.GetById(wp.PetId) or pickPetForDistance(dist, totalLuck)
		wp.Model:Destroy()
		table.remove(wildPets, caughtWildIndex)
		-- Respawn a new wild pet in the same zone
		spawnWildPet(math.max(10, math.floor(dist - 25)), math.min(430, math.floor(dist + 25)))
	else
		chosenDef = pickPetForDistance(dist, totalLuck)
	end

	local mut = PetCatalog.RollMutation(totalLuck * fortuneBoost * (if isPerfect then 1.35 else 1.0))
	local ok, msg = PlayerState.AddPet(data, chosenDef.Id, mut.Name)
	local bonusCash = math.floor(dist * 0.6)
	data.Cash += bonusCash
	if not ok then
		-- Base full -> convert catch to instant cash payout!
		data.Cash += chosenDef.BaseCashPerSec * 12
	end

	PlayerState.Sync(data)

	Remotes.Get(Remotes.EventNames.ThrowResult):FireAllClients({
		ThrowerUserId = player.UserId,
		StartPos = Vector3.new(targetX * 0.25, 4, GameConfig.ThrowLineZ),
		LandPos = landPos,
		FoodColor = food.Color,
		FoodAccent = food.AccentColor,
		Distance = math.floor(dist),
		IsPerfect = isPerfect,
		PetId = chosenDef.Id,
		PetName = chosenDef.DisplayName,
		Rarity = chosenDef.Rarity,
		Mutation = mut.Name,
		AddedToBase = ok,
		StatusMsg = if ok then ("Caught " .. chosenDef.DisplayName .. "!") else (msg .. " (+$" .. tostring(chosenDef.BaseCashPerSec * 12) .. ")"),
	})
end)

-- Shop, Train, Upgrade, Sell, Shield, Collect, Rebirth, Teleport Remotes
Remotes.Get(Remotes.EventNames.BuyFood).OnServerEvent:Connect(function(player: Player, foodId: string)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	local food = FoodCatalog.GetById(tostring(foodId))
	if data.OwnedFoods[food.Id] then
		data.EquippedFoodId = food.Id
		PlayerState.Sync(data)
		return
	end
	if data.Cash >= food.Cost then
		data.Cash -= food.Cost
		data.OwnedFoods[food.Id] = true
		data.EquippedFoodId = food.Id
		PlayerState.Sync(data)
	end
end)

Remotes.Get(Remotes.EventNames.EquipFood).OnServerEvent:Connect(function(player: Player, foodId: string)
	local data = PlayerState.Get(player)
	if data and data.OwnedFoods[tostring(foodId)] then
		data.EquippedFoodId = tostring(foodId)
		PlayerState.Sync(data)
	end
end)

Remotes.Get(Remotes.EventNames.TrainPower).OnServerEvent:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	local gain = 4 + data.Rebirths * 2
	data.ThrowPower += gain
	PlayerState.Sync(data)
end)

Remotes.Get(Remotes.EventNames.UpgradeSlots).OnServerEvent:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	if not data or data.BaseSlots >= GameConfig.MaxBaseSlots then
		return
	end
	local cost = GameConfig.GetSlotUpgradeCost(data.BaseSlots)
	if data.Cash >= cost then
		data.Cash -= cost
		data.BaseSlots += 1
		PlayerState.RefreshPlotVisuals(data)
		PlayerState.Sync(data)
	end
end)

Remotes.Get(Remotes.EventNames.CollectCash).OnServerEvent:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	if data and data.PendingCash >= 1 then
		data.Cash += math.floor(data.PendingCash)
		data.PendingCash = 0
		PlayerState.RefreshPlotVisuals(data)
		PlayerState.Sync(data)
	end
end)

Remotes.Get(Remotes.EventNames.BuyPotion).OnServerEvent:Connect(function(player: Player, potionId: string)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	local pot = FoodCatalog.GetPotionById(tostring(potionId))
	if not pot or data.Cash < pot.Cost then
		return
	end
	data.Cash -= pot.Cost
	local now = os.clock()
	if pot.Id == "super_luck" then
		data.LuckUntil = math.max(now, data.LuckUntil) + pot.Duration
	elseif pot.Id == "throw_haste" then
		data.HasteUntil = math.max(now, data.HasteUntil) + pot.Duration
	elseif pot.Id == "fortune_elixir" then
		data.FortuneUntil = math.max(now, data.FortuneUntil) + pot.Duration
	end
	PlayerState.Sync(data)
	Remotes.Get(Remotes.EventNames.EventBanner):FireClient(player, {
		Text = "ACTIVATED " .. pot.DisplayName:upper() .. "!",
		Color = pot.Color,
	})
end)

Remotes.Get(Remotes.EventNames.ToggleLockPet).OnServerEvent:Connect(function(player: Player, uid: string)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	for _, p in ipairs(data.Pets) do
		if p.Uid == tostring(uid) then
			p.Locked = not p.Locked
			PlayerState.Sync(data)
			return
		end
	end
end)

Remotes.Get(Remotes.EventNames.SellPet).OnServerEvent:Connect(function(player: Player, uid: string)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	for _, p in ipairs(data.Pets) do
		if p.Uid == tostring(uid) and p.Locked then
			return
		end
	end
	local removed = PlayerState.RemovePetByUid(data, tostring(uid))
	if removed then
		local refund = removed.CashPerSec * 15
		data.Cash += refund
		PlayerState.Sync(data)
	end
end)

Remotes.Get(Remotes.EventNames.Rebirth).OnServerEvent:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	if not data then
		return
	end
	local cost = GameConfig.GetRebirthCost(data.Rebirths)
	if data.Cash >= cost then
		data.Cash = 100
		data.PendingCash = 0
		data.Rebirths += 1
		data.ThrowPower = 60 + data.Rebirths * 25
		data.BaseSlots = GameConfig.StartBaseSlots
		PlayerState.ClearAllPets(data)
		PlayerState.AddPet(data, "narutini", "Normal")
		PlayerState.RefreshPlotVisuals(data)
		PlayerState.Sync(data)
		Remotes.Get(Remotes.EventNames.EventBanner):FireAllClients({
			Text = player.DisplayName .. " REBIRTHED! (" .. tostring(GameConfig.GetRebirthMultiplier(data.Rebirths)) .. "x CASH!)",
			Color = Color3.fromRGB(255, 224, 64),
		})
	end
end)

Remotes.Get(Remotes.EventNames.TeleportBase).OnServerEvent:Connect(function(player: Player)
	local data = PlayerState.Get(player)
	local char = player.Character
	if data and data.Plot and char then
		local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			hrp.CFrame = CFrame.new(data.Plot.Origin + Vector3.new(0, 4, -14))
		end
	end
end)

-- Passive Income Loop + Periodic Brainrot Storm / Rival Raid
task.spawn(function()
	local waveTimer = GameConfig.WaveInterval
	while true do
		task.wait(1)
		waveTimer -= 1

		for _, data in pairs(PlayerState.GetAll()) do
			local cps = PlayerState.GetTotalCps(data)
			if cps > 0 then
				data.PendingCash += cps
			end
			PlayerState.RefreshPlotVisuals(data)
			PlayerState.Sync(data)
		end

		if waveTimer <= 0 then
			waveTimer = GameConfig.WaveInterval
			refreshRivalPets()
			Remotes.Get(Remotes.EventNames.EventBanner):FireAllClients({
				Text = "RIVAL RAID & OHIO STORM! Lock Base Shield & Check Rival Base!",
				Color = Color3.fromRGB(255, 78, 108),
			})
			-- Check unshielded bases after 6 seconds
			task.delay(6, function()
				local now = os.clock()
				for _, data in pairs(PlayerState.GetAll()) do
					if now >= data.ShieldUntil and #data.Pets > 1 then
						-- Rival thief steals lowest-value pet if base is unshielded!
						local victim = data.Pets[1]
						PlayerState.RemovePetByUid(data, victim.Uid)
						PlayerState.Sync(data)
						Remotes.Get(Remotes.EventNames.EventBanner):FireClient(data.Player, {
							Text = "A RIVAL STOLE YOUR UNSHIELDED PET! Use Shield Pad!",
							Color = Color3.fromRGB(255, 68, 68),
						})
					end
				end
			end)
		end
	end
end)
