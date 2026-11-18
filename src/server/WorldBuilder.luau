--!strict
-- Procedurally constructs the 3D Hub Plaza, Player Bases, Rival Base, Throw Runway, and 5 Biome Zones.

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

export type BasePlot = {
	Index: number,
	OwnerUserId: number?,
	Origin: Vector3,
	Model: Model,
	Pedestals: { Part },
	CollectPad: Part,
	CollectLabel: TextLabel,
	ShieldPad: Part,
	ShieldLabel: TextLabel,
	ShieldDome: Part,
	OwnerLabel: TextLabel,
}

local WorldBuilder = {}

local function makePart(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	parent: Instance,
	canCollide: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = if canCollide == nil then true else canCollide
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addSign(part: Part, text: string, subtext: string?, color: Color3?, offset: Vector3?): TextLabel
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(220, 72)
	bb.StudsOffset = offset or Vector3.new(0, 4.5, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 110
	bb.Parent = part

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
	bg.BackgroundTransparency = 0.2
	bg.BorderSizePixel = 0
	bg.Parent = bb

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = bg

	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(255, 210, 72)
	stroke.Thickness = 2
	stroke.Parent = bg

	local main = Instance.new("TextLabel")
	main.Size = UDim2.new(1, -8, if subtext then 0.55 else 1, 0)
	main.Position = UDim2.fromOffset(4, 2)
	main.BackgroundTransparency = 1
	main.Font = Enum.Font.GothamBlack
	main.TextScaled = true
	main.TextColor3 = color or Color3.new(1, 1, 1)
	main.Text = text
	main.Parent = bg

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -8, 0.4, 0)
		sub.Position = UDim2.new(0, 4, 0.56, 0)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.GothamSemibold
		sub.TextScaled = true
		sub.TextColor3 = Color3.fromRGB(215, 224, 240)
		sub.Text = subtext
		sub.Parent = bg
	end

	return main
end

local function createBasePlot(index: number, origin: Vector3, parent: Instance): BasePlot
	local model = Instance.new("Model")
	model.Name = "BasePlot_" .. tostring(index)
	model.Parent = parent

	local floor = makePart(
		"BaseFloor",
		Vector3.new(26, 1, 26),
		CFrame.new(origin),
		Color3.fromRGB(38, 44, 62),
		Enum.Material.SmoothPlastic,
		model
	)
	makePart(
		"NeonTrim",
		Vector3.new(26.6, 0.35, 26.6),
		CFrame.new(origin - Vector3.new(0, 0.35, 0)),
		Color3.fromRGB(82, 198, 255),
		Enum.Material.Neon,
		model,
		false
	)

	-- Sign post
	local signPart = makePart(
		"OwnerSign",
		Vector3.new(6, 3.5, 0.6),
		CFrame.new(origin + Vector3.new(0, 4.5, -12.5)),
		Color3.fromRGB(24, 28, 40),
		Enum.Material.SmoothPlastic,
		model
	)
	local ownerLabel = addSign(signPart, "OPEN BASE #" .. tostring(index), "Claimed on join", Color3.fromRGB(108, 224, 255), Vector3.new(0, 0.2, 0))

	-- Collect Cash Pad
	local collectPad = makePart(
		"CollectPad",
		Vector3.new(5.5, 0.4, 5.5),
		CFrame.new(origin + Vector3.new(-7, 0.7, -8.5)),
		Color3.fromRGB(64, 232, 118),
		Enum.Material.Neon,
		model,
		false
	)
	local collectLabel = addSign(collectPad, "$0", "Step to Collect!", Color3.fromRGB(108, 255, 146), Vector3.new(0, 3.2, 0))

	-- Shield Lock Pad
	local shieldPad = makePart(
		"ShieldPad",
		Vector3.new(5.5, 0.4, 5.5),
		CFrame.new(origin + Vector3.new(7, 0.7, -8.5)),
		Color3.fromRGB(72, 188, 255),
		Enum.Material.Neon,
		model,
		false
	)
	local shieldLabel = addSign(shieldPad, "SHIELD READY", "Press [E] to Lock", Color3.fromRGB(92, 212, 255), Vector3.new(0, 3.2, 0))

	local shieldPrompt = Instance.new("ProximityPrompt")
	shieldPrompt.ActionText = "Lock Base Shield"
	shieldPrompt.ObjectText = "Anti-Steal Shield"
	shieldPrompt.HoldDuration = 0
	shieldPrompt.MaxActivationDistance = 10
	shieldPrompt.Parent = shieldPad

	local shieldDome = makePart(
		"ShieldDome",
		Vector3.new(25, 16, 25),
		CFrame.new(origin + Vector3.new(0, 8, 0)),
		Color3.fromRGB(72, 215, 255),
		Enum.Material.ForceField,
		model,
		false
	)
	shieldDome.Transparency = 1

	-- 12 Pet Pedestals in a 4x3 grid
	local pedestals: { Part } = {}
	for i = 1, GameConfig.MaxBaseSlots do
		local col = (i - 1) % 4
		local row = math.floor((i - 1) / 4)
		local px = origin.X - 7.5 + col * 5.0
		local pz = origin.Z - 1.5 + row * 5.2
		local ped = makePart(
			"Pedestal_" .. tostring(i),
			Vector3.new(3.6, 0.6, 3.6),
			CFrame.new(px, origin.Y + 0.8, pz),
			if i <= GameConfig.StartBaseSlots then Color3.fromRGB(72, 82, 112) else Color3.fromRGB(48, 48, 56),
			Enum.Material.SmoothPlastic,
			model
		)
		ped:SetAttribute("SlotIndex", i)
		table.insert(pedestals, ped)
	end

	return {
		Index = index,
		OwnerUserId = nil,
		Origin = origin,
		Model = model,
		Pedestals = pedestals,
		CollectPad = collectPad,
		CollectLabel = collectLabel,
		ShieldPad = shieldPad,
		ShieldLabel = shieldLabel,
		ShieldDome = shieldDome,
		OwnerLabel = ownerLabel,
	}
end

function WorldBuilder.Build(): { BasePlots: { BasePlot }, RivalPad: Part, TrainPrompt: ProximityPrompt, ShopPrompt: ProximityPrompt }
	-- Remove default Baseplate if present so custom hub & biome floors are visible
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end
	-- Clean old world if re-run
	local existing = Workspace:FindFirstChild("GameWorld")
	if existing then
		existing:Destroy()
	end

	-- Anime Arcade Lighting & Post-Processing
	for _, fx in ipairs(Lighting:GetChildren()) do
		if fx:IsA("PostEffect") or fx:IsA("Atmosphere") then
			fx:Destroy()
		end
	end
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.65
	bloom.Size = 22
	bloom.Threshold = 1.1
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.22
	cc.Contrast = 0.08
	cc.Parent = Lighting

	local atmo = Instance.new("Atmosphere")
	atmo.Density = 0.22
	atmo.Offset = 0.25
	atmo.Color = Color3.fromRGB(185, 225, 255)
	atmo.Decay = Color3.fromRGB(120, 170, 230)
	atmo.Glare = 0.2
	atmo.Haze = 1.2
	atmo.Parent = Lighting

	local world = Instance.new("Folder")
	world.Name = "GameWorld"
	world.Parent = Workspace

	-- Hub Floor
	makePart(
		"HubFloor",
		Vector3.new(130, 2, 82),
		CFrame.new(0, 0, 31),
		Color3.fromRGB(52, 58, 78),
		Enum.Material.SmoothPlastic,
		world
	)

	-- SpawnLocation
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "HubSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 1.2, 22)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Color = Color3.fromRGB(92, 198, 255)
	spawn.Material = Enum.Material.Neon
	spawn.Parent = world

	-- Throw Runway
	local runway = makePart(
		"ThrowRunway",
		Vector3.new(16, 0.6, 22),
		CFrame.new(0, 1.1, -1),
		Color3.fromRGB(36, 42, 58),
		Enum.Material.SmoothPlastic,
		world
	)
	local throwLine = makePart(
		"ThrowLine",
		Vector3.new(16, 0.65, 1.8),
		CFrame.new(0, 1.15, GameConfig.ThrowLineZ),
		Color3.fromRGB(255, 206, 52),
		Enum.Material.Neon,
		world,
		false
	)
	addSign(throwLine, "THROW FOOD HERE!", "Click or Press [SPACE]", Color3.fromRGB(255, 224, 72), Vector3.new(0, 5.5, 0))
	local _unused = runway

	-- Aura Training Stand
	local trainBase = makePart(
		"TrainStand",
		Vector3.new(10, 1, 10),
		CFrame.new(-22, 1.2, 16),
		Color3.fromRGB(255, 104, 52),
		Enum.Material.SmoothPlastic,
		world
	)
	makePart("PullupLeft", Vector3.new(0.8, 7, 0.8), CFrame.new(-25.5, 4.7, 16), Color3.fromRGB(210, 218, 230), Enum.Material.Metal, world)
	makePart("PullupRight", Vector3.new(0.8, 7, 0.8), CFrame.new(-18.5, 4.7, 16), Color3.fromRGB(210, 218, 230), Enum.Material.Metal, world)
	makePart("PullupBar", Vector3.new(7.8, 0.5, 0.5), CFrame.new(-22, 8.0, 16), Color3.fromRGB(255, 210, 62), Enum.Material.Neon, world)
	addSign(trainBase, "AURA GYM", "Train Throw Power [E]", Color3.fromRGB(255, 142, 72), Vector3.new(0, 6.2, 0))

	local trainPrompt = Instance.new("ProximityPrompt")
	trainPrompt.ActionText = "Train Throw Power"
	trainPrompt.ObjectText = "Aura Pull-Up Bar"
	trainPrompt.HoldDuration = 0
	trainPrompt.MaxActivationDistance = 12
	trainPrompt.Parent = trainBase

	-- Food Shop Stall
	local shopBase = makePart(
		"FoodShopStall",
		Vector3.new(10, 1, 10),
		CFrame.new(22, 1.2, 16),
		Color3.fromRGB(74, 186, 255),
		Enum.Material.SmoothPlastic,
		world
	)
	makePart("ShopRoof", Vector3.new(11, 1.2, 11), CFrame.new(22, 7.5, 16), Color3.fromRGB(255, 86, 112), Enum.Material.SmoothPlastic, world)
	makePart("ShopPillar1", Vector3.new(0.8, 6, 0.8), CFrame.new(17.5, 4.5, 11.5), Color3.fromRGB(245, 245, 250), Enum.Material.SmoothPlastic, world)
	makePart("ShopPillar2", Vector3.new(0.8, 6, 0.8), CFrame.new(26.5, 4.5, 11.5), Color3.fromRGB(245, 245, 250), Enum.Material.SmoothPlastic, world)
	addSign(shopBase, "ANIME FOOD SHOP", "Better Food = Rarer Pets [E]", Color3.fromRGB(92, 224, 255), Vector3.new(0, 6.8, 0))

	local shopPrompt = Instance.new("ProximityPrompt")
	shopPrompt.ActionText = "Open Food Shop"
	shopPrompt.ObjectText = "Ichiraku Stall"
	shopPrompt.HoldDuration = 0
	shopPrompt.MaxActivationDistance = 12
	shopPrompt.Parent = shopBase

	-- Rival NPC Base at back of Hub (for solo/multiplayer stealing!)
	local rivalPad = makePart(
		"RivalBase",
		Vector3.new(18, 1, 14),
		CFrame.new(0, 1.2, 54),
		Color3.fromRGB(162, 42, 78),
		Enum.Material.SmoothPlastic,
		world
	)
	addSign(rivalPad, "OHIO RIVAL BASE", "Steal Pets When Unlocked!", Color3.fromRGB(255, 92, 128), Vector3.new(0, 5.2, 0))

	-- 4 Player Base Plots
	local baseOrigins = {
		Vector3.new(-46, 0.8, 40),
		Vector3.new(46, 0.8, 40),
		Vector3.new(-46, 0.8, 6),
		Vector3.new(46, 0.8, 6),
	}
	local plots: { BasePlot } = {}
	for i, orig in ipairs(baseOrigins) do
		table.insert(plots, createBasePlot(i, orig, world))
	end

	-- 5 Biome Zones extending along -Z
	local zonesFolder = Instance.new("Folder")
	zonesFolder.Name = "BiomeZones"
	zonesFolder.Parent = world

	for idx, zDef in ipairs(GameConfig.Zones) do
		local len = zDef.EndZ - zDef.StartZ
		local centerZ = GameConfig.ThrowLineZ - zDef.StartZ - len / 2
		makePart(
			"Zone_" .. tostring(idx),
			Vector3.new(110, 2, len),
			CFrame.new(0, 0, centerZ),
			zDef.Color,
			Enum.Material.SmoothPlastic,
			zonesFolder
		)

		-- Side border rails
		makePart("RailL_" .. tostring(idx), Vector3.new(3, 5, len), CFrame.new(-56, 2.5, centerZ), zDef.AccentColor, Enum.Material.SmoothPlastic, zonesFolder)
		makePart("RailR_" .. tostring(idx), Vector3.new(3, 5, len), CFrame.new(56, 2.5, centerZ), zDef.AccentColor, Enum.Material.SmoothPlastic, zonesFolder)

		-- Distance arch at start of each zone
		local archZ = GameConfig.ThrowLineZ - zDef.StartZ - 2
		local archTop = makePart("ArchTop_" .. tostring(idx), Vector3.new(32, 2.2, 2), CFrame.new(0, 14, archZ), zDef.AccentColor, Enum.Material.Neon, zonesFolder, false)
		makePart("ArchL_" .. tostring(idx), Vector3.new(2, 14, 2), CFrame.new(-15, 7, archZ), zDef.AccentColor, Enum.Material.SmoothPlastic, zonesFolder)
		makePart("ArchR_" .. tostring(idx), Vector3.new(2, 14, 2), CFrame.new(15, 7, archZ), zDef.AccentColor, Enum.Material.SmoothPlastic, zonesFolder)
		addSign(archTop, zDef.Name:upper(), tostring(zDef.StartZ) .. "m+ • " .. zDef.MinRarity .. "+", zDef.AccentColor, Vector3.new(0, 3.2, 0))

		-- Decorative 3D anime biome props along edges
		for p = 1, 5 do
			local propZ = GameConfig.ThrowLineZ - zDef.StartZ - (p * (len / 6))
			local side = if p % 2 == 0 then 1 else -1
			local px = side * math.random(34, 48)
			if idx == 1 or idx == 2 then
				-- Bamboo / Lantern Pillars
				makePart("Bamboo_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(1.6, 12, 1.6), CFrame.new(px, 7, propZ), zDef.AccentColor, Enum.Material.SmoothPlastic, zonesFolder)
				makePart("Bamboo2_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(1.4, 9, 1.4), CFrame.new(px + 2.2, 5.5, propZ + 1.5), zDef.Color, Enum.Material.SmoothPlastic, zonesFolder)
				makePart("Lantern_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(2.2, 2.2, 2.2), CFrame.new(px, 13.5, propZ), Color3.fromRGB(255, 230, 110), Enum.Material.Neon, zonesFolder, false)
			elseif idx == 3 or idx == 4 then
				-- Tilted Energy Crystals
				makePart("Crystal_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(3.2, 14, 3.2), CFrame.new(px, 7, propZ) * CFrame.Angles(math.rad(12 * side), 0, math.rad(16 * side)), zDef.AccentColor, Enum.Material.Neon, zonesFolder)
			else
				-- Crimson Shrine Pillars with floating orb
				makePart("ShrinePillar_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(3.5, 16, 3.5), CFrame.new(px, 8, propZ), Color3.fromRGB(36, 18, 44), Enum.Material.SmoothPlastic, zonesFolder)
				local orb = makePart("ShrineOrb_" .. tostring(idx) .. "_" .. tostring(p), Vector3.new(3.6, 3.6, 3.6), CFrame.new(px, 18.5, propZ), zDef.AccentColor, Enum.Material.Neon, zonesFolder, false)
				orb.Shape = Enum.PartType.Ball
			end
		end
	end

	-- Center Neon Distance Strip Markers every 50m
	for dist = 50, 400, 50 do
		local stripZ = GameConfig.ThrowLineZ - dist
		local strip = makePart("DistStrip_" .. tostring(dist), Vector3.new(22, 0.2, 1.4), CFrame.new(0, 1.05, stripZ), Color3.fromRGB(255, 224, 88), Enum.Material.Neon, zonesFolder, false)
		addSign(strip, tostring(dist) .. "m", nil, Color3.fromRGB(255, 232, 112), Vector3.new(0, 2.4, 0))
	end

	return {
		BasePlots = plots,
		RivalPad = rivalPad,
		TrainPrompt = trainPrompt,
		ShopPrompt = shopPrompt,
	}
end

return WorldBuilder
