--!strict
-- Builds 3D chibi Anime MC Brainrot Pet models with distinct props, mutation FX, and BillboardGui labels.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)

local PetVisuals = {}

local function makePart(
	name: string,
	size: Vector3,
	color: Color3,
	material: Enum.Material,
	parent: Instance,
	shape: Enum.PartType?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		p.Shape = shape
	end
	p.Parent = parent
	return p
end

local function addStyleProps(model: Model, head: Part, torso: Part, def: PetCatalog.PetDef)
	local tag = def.StyleTag
	local cfHead = head.CFrame
	local cfTorso = torso.CFrame

	if tag == "Ninja" then
		-- Ninja headband + ramen bowl on top
		local band = makePart("Headband", Vector3.new(1.52, 0.28, 1.52), def.AccentColor, Enum.Material.SmoothPlastic, model)
		band.CFrame = cfHead * CFrame.new(0, 0.35, 0)
		local plate = makePart("Plate", Vector3.new(0.65, 0.22, 0.12), Color3.fromRGB(205, 212, 224), Enum.Material.Metal, model)
		plate.CFrame = cfHead * CFrame.new(0, 0.35, -0.78)
		local bowl = makePart("RamenBowl", Vector3.new(1.1, 0.55, 1.1), Color3.fromRGB(250, 250, 245), Enum.Material.SmoothPlastic, model, Enum.PartType.Cylinder)
		bowl.CFrame = cfHead * CFrame.new(0, 0.95, 0) * CFrame.Angles(0, 0, math.rad(90))
	elseif tag == "Deku" then
		-- Messy green hair tufts + red shoes accent
		for i = -1, 1 do
			local tuft = makePart("HairTuft", Vector3.new(0.55, 0.55, 0.55), def.HairColor, Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
			tuft.CFrame = cfHead * CFrame.new(i * 0.45, 0.72, 0.1)
		end
	elseif tag == "Pirate" then
		-- Straw Hat
		local brim = makePart("HatBrim", Vector3.new(2.2, 0.15, 2.2), def.AccentColor, Enum.Material.Fabric, model, Enum.PartType.Cylinder)
		brim.CFrame = cfHead * CFrame.new(0, 0.68, 0) * CFrame.Angles(0, 0, math.rad(90))
		local dome = makePart("HatDome", Vector3.new(1.35, 0.55, 1.35), def.AccentColor, Enum.Material.Fabric, model)
		dome.CFrame = cfHead * CFrame.new(0, 0.92, 0)
		local ribbon = makePart("HatRibbon", Vector3.new(1.4, 0.16, 1.4), Color3.fromRGB(220, 42, 42), Enum.Material.SmoothPlastic, model)
		ribbon.CFrame = cfHead * CFrame.new(0, 0.76, 0)
	elseif tag == "Slayer" then
		-- Checkered haori wings + bamboo muzzle
		local bamboo = makePart("Bamboo", Vector3.new(0.75, 0.22, 0.22), Color3.fromRGB(116, 204, 92), Enum.Material.SmoothPlastic, model)
		bamboo.CFrame = cfHead * CFrame.new(0, -0.22, -0.76)
		local blade = makePart("Nichirin", Vector3.new(0.16, 2.2, 0.24), Color3.fromRGB(40, 44, 52), Enum.Material.Metal, model)
		blade.CFrame = cfTorso * CFrame.new(0.8, 0.4, 0.65) * CFrame.Angles(0, 0, math.rad(-25))
	elseif tag == "Shinigami" then
		-- Huge Zanpakuto on back + spiky orange hair
		local sword = makePart("Zanpakuto", Vector3.new(0.28, 3.2, 0.52), Color3.fromRGB(215, 222, 232), Enum.Material.Metal, model)
		sword.CFrame = cfTorso * CFrame.new(0, 0.8, 0.72) * CFrame.Angles(0, 0, math.rad(-32))
		local hair = makePart("SpikyHair", Vector3.new(1.55, 0.5, 1.55), def.HairColor, Enum.Material.SmoothPlastic, model)
		hair.CFrame = cfHead * CFrame.new(0, 0.72, 0)
	elseif tag == "Chainsaw" then
		-- Chainsaw blade snout + handle on top
		local saw = makePart("ChainsawSnout", Vector3.new(0.32, 0.55, 1.55), Color3.fromRGB(190, 198, 210), Enum.Material.Metal, model)
		saw.CFrame = cfHead * CFrame.new(0, 0.05, -1.1)
		local handle = makePart("PullHandle", Vector3.new(0.18, 0.45, 0.8), def.BodyColor, Enum.Material.SmoothPlastic, model)
		handle.CFrame = cfHead * CFrame.new(0, 0.85, 0)
	elseif tag == "Saiyan" then
		-- Golden spiky Saiyan hair + glowing aura ring
		for i = -1, 1 do
			local spike = makePart("SaiyanSpike", Vector3.new(0.55, 0.95, 0.55), def.HairColor, Enum.Material.Neon, model)
			spike.CFrame = cfHead * CFrame.new(i * 0.42, 0.88, 0) * CFrame.Angles(0, 0, math.rad(i * -18))
		end
		local aura = makePart("AuraRing", Vector3.new(2.8, 0.14, 2.8), def.HairColor, Enum.Material.Neon, model, Enum.PartType.Cylinder)
		aura.Transparency = 0.35
		aura.CFrame = cfTorso * CFrame.new(0, -1.2, 0) * CFrame.Angles(0, 0, math.rad(90))
	elseif tag == "Titan" then
		-- Survey Corps green cape
		local cape = makePart("SurveyCape", Vector3.new(1.7, 1.4, 0.18), Color3.fromRGB(54, 128, 68), Enum.Material.Fabric, model)
		cape.CFrame = cfTorso * CFrame.new(0, 0.1, 0.65) * CFrame.Angles(math.rad(12), 0, 0)
	elseif tag == "Baldy" then
		-- Shiny bald dome + white hero cape
		local shine = makePart("BaldShine", Vector3.new(0.45, 0.25, 0.45), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, model, Enum.PartType.Ball)
		shine.Transparency = 0.25
		shine.CFrame = cfHead * CFrame.new(0.32, 0.62, -0.32)
		local cape = makePart("HeroCape", Vector3.new(1.75, 1.5, 0.16), Color3.fromRGB(248, 248, 252), Enum.Material.Fabric, model)
		cape.CFrame = cfTorso * CFrame.new(0, 0.05, 0.65) * CFrame.Angles(math.rad(12), 0, 0)
	elseif tag == "Jotaro" then
		-- Visor cap + gold chain
		local cap = makePart("VisorCap", Vector3.new(1.52, 0.42, 1.52), def.BodyColor, Enum.Material.SmoothPlastic, model)
		cap.CFrame = cfHead * CFrame.new(0, 0.68, 0)
		local brim = makePart("CapBrim", Vector3.new(1.45, 0.12, 0.65), def.BodyColor, Enum.Material.SmoothPlastic, model)
		brim.CFrame = cfHead * CFrame.new(0, 0.52, -0.78)
		local chain = makePart("GoldChain", Vector3.new(0.4, 0.18, 0.65), def.AccentColor, Enum.Material.Metal, model)
		chain.CFrame = cfTorso * CFrame.new(0.55, 0.45, -0.45)
	elseif tag == "Gojo" then
		-- Black blindfold + floating Hollow Purple orb
		local blindfold = makePart("Blindfold", Vector3.new(1.48, 0.38, 1.48), Color3.fromRGB(18, 18, 24), Enum.Material.SmoothPlastic, model)
		blindfold.CFrame = cfHead * CFrame.new(0, 0.12, 0)
		local hair = makePart("WhiteHair", Vector3.new(1.55, 0.55, 1.55), def.HairColor, Enum.Material.SmoothPlastic, model)
		hair.CFrame = cfHead * CFrame.new(0, 0.78, 0)
		local orb = makePart("HollowOrb", Vector3.new(0.75, 0.75, 0.75), Color3.fromRGB(175, 75, 255), Enum.Material.Neon, model, Enum.PartType.Ball)
		orb.CFrame = cfTorso * CFrame.new(1.35, 0.85, -0.4)
	elseif tag == "Sukuna" then
		-- Pink spiky hair + crimson shrine halo
		local hair = makePart("PinkHair", Vector3.new(1.55, 0.52, 1.55), def.HairColor, Enum.Material.SmoothPlastic, model)
		hair.CFrame = cfHead * CFrame.new(0, 0.75, 0)
		local halo = makePart("ShrineHalo", Vector3.new(2.7, 2.7, 0.16), def.AccentColor, Enum.Material.Neon, model)
		halo.Transparency = 0.25
		halo.CFrame = cfTorso * CFrame.new(0, 0.7, 0.85)
	end
end

function PetVisuals.CreateModel(
	petId: string,
	mutationName: string,
	baseCFrame: CFrame,
	cashPerSec: number,
	extraSubtitle: string?
): Model
	local def = PetCatalog.GetById(petId) or PetCatalog.Pets[1]
	local mut = PetCatalog.GetMutation(mutationName)
	local rarity = PetCatalog.Rarities[def.Rarity] or PetCatalog.Rarities.Common

	local model = Instance.new("Model")
	model.Name = "Pet_" .. def.Id

	local bodyMat = Enum.Material.SmoothPlastic
	local bodyColor = def.BodyColor
	if mut.Name == "Golden" then
		bodyMat = Enum.Material.Metal
		bodyColor = Color3.fromRGB(255, 212, 66)
	elseif mut.Name == "Diamond" then
		bodyMat = Enum.Material.Glass
		bodyColor = Color3.fromRGB(108, 238, 255)
	elseif mut.Name == "Rainbow" then
		bodyMat = Enum.Material.Neon
		bodyColor = Color3.fromRGB(255, 118, 235)
	end

	-- Torso
	local torso = makePart("Torso", Vector3.new(1.5, 1.4, 1.0), bodyColor, bodyMat, model)
	torso.CFrame = baseCFrame * CFrame.new(0, 1.35, 0)

	-- Head
	local skinColor = Color3.fromRGB(255, 222, 194)
	if mut.Name == "Golden" then
		skinColor = Color3.fromRGB(255, 224, 108)
	elseif mut.Name == "Diamond" then
		skinColor = Color3.fromRGB(172, 245, 255)
	end
	local head = makePart("Head", Vector3.new(1.4, 1.35, 1.4), skinColor, Enum.Material.SmoothPlastic, model)
	head.CFrame = baseCFrame * CFrame.new(0, 2.75, 0)

	-- Eyes (unless Gojo blindfold covers)
	if def.StyleTag ~= "Gojo" then
		local eyeL = makePart("EyeL", Vector3.new(0.22, 0.28, 0.1), Color3.fromRGB(20, 20, 26), Enum.Material.SmoothPlastic, model)
		eyeL.CFrame = head.CFrame * CFrame.new(-0.32, 0.1, -0.71)
		local eyeR = makePart("EyeR", Vector3.new(0.22, 0.28, 0.1), Color3.fromRGB(20, 20, 26), Enum.Material.SmoothPlastic, model)
		eyeR.CFrame = head.CFrame * CFrame.new(0.32, 0.1, -0.71)
	end

	-- Legs
	local legL = makePart("LegL", Vector3.new(0.55, 0.75, 0.7), def.AccentColor, Enum.Material.SmoothPlastic, model)
	legL.CFrame = baseCFrame * CFrame.new(-0.4, 0.38, 0)
	local legR = makePart("LegR", Vector3.new(0.55, 0.75, 0.7), def.AccentColor, Enum.Material.SmoothPlastic, model)
	legR.CFrame = baseCFrame * CFrame.new(0.4, 0.38, 0)

	-- Arms
	local armL = makePart("ArmL", Vector3.new(0.45, 1.1, 0.55), bodyColor, bodyMat, model)
	armL.CFrame = baseCFrame * CFrame.new(-1.05, 1.38, 0) * CFrame.Angles(0, 0, math.rad(12))
	local armR = makePart("ArmR", Vector3.new(0.45, 1.1, 0.55), bodyColor, bodyMat, model)
	armR.CFrame = baseCFrame * CFrame.new(1.05, 1.38, 0) * CFrame.Angles(0, 0, math.rad(-12))

	addStyleProps(model, head, torso, def)

	if mut.Name ~= "Normal" then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = mut.Color
		sparkles.Parent = torso
	end

	-- Overhead BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "PetLabel"
	bb.Adornee = head
	bb.Size = UDim2.fromOffset(220, 86)
	bb.StudsOffset = Vector3.new(0, 2.2, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 95
	bb.Parent = head

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
	stroke.Color = rarity.Color
	stroke.Thickness = 2
	stroke.Parent = bg

	local prefix = if mut.Name ~= "Normal" then ("[" .. mut.Name .. "] ") else ""
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -8, 0.38, 0)
	title.Position = UDim2.fromOffset(4, 2)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = if mut.Name ~= "Normal" then mut.Color else Color3.new(1, 1, 1)
	title.Text = prefix .. def.DisplayName
	title.Parent = bg

	local rarLabel = Instance.new("TextLabel")
	rarLabel.Size = UDim2.new(1, -8, 0.28, 0)
	rarLabel.Position = UDim2.new(0, 4, 0.38, 0)
	rarLabel.BackgroundTransparency = 1
	rarLabel.Font = Enum.Font.GothamSemibold
	rarLabel.TextScaled = true
	rarLabel.TextColor3 = rarity.Color
	rarLabel.Text = rarity.Name .. " • " .. def.AnimeRef
	rarLabel.Parent = bg

	local cashLabel = Instance.new("TextLabel")
	cashLabel.Size = UDim2.new(1, -8, 0.3, 0)
	cashLabel.Position = UDim2.new(0, 4, 0.68, 0)
	cashLabel.BackgroundTransparency = 1
	cashLabel.Font = Enum.Font.GothamBlack
	cashLabel.TextScaled = true
	cashLabel.TextColor3 = Color3.fromRGB(108, 255, 146)
	cashLabel.Text = extraSubtitle or ("+$" .. tostring(cashPerSec) .. "/s")
	cashLabel.Parent = bg

	model.PrimaryPart = torso
	return model
end

return PetVisuals
