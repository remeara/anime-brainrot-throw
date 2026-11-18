--!strict
-- Client-side HUD applying the BloxRNG Game UI Design System:
-- FredokaOne arcade typography, thick #0F172A/#1E1B4B strokes, 3D-bevel tiles with squish, bouncy modals, and suffix cash formatting.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FoodCatalog = require(ReplicatedStorage.Shared.FoodCatalog)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UITheme = require(ReplicatedStorage.Shared.UITheme)
local ShopAndInventory = require(script.Parent.ShopAndInventory)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "MainHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local latestState: any = nil

-- Top-Center High-Contrast Navy Capsule (clear of top-left Roblox core UI)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.fromOffset(720, 58)
topBar.Position = UDim2.new(0.5, -360, 0, 12)
topBar.BackgroundColor3 = UITheme.Colors.PillNavy
topBar.BackgroundTransparency = 0.08
topBar.BorderSizePixel = 0
topBar.Parent = gui

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 16)

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = UITheme.Colors.GemBlue
tbStroke.Thickness = 3
tbStroke.Parent = topBar

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Padding = UDim.new(0, 8)
topLayout.Parent = topBar

local function makeStatPill(width: number, color: Color3): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(width, 38)
	lbl.BackgroundColor3 = UITheme.Colors.StrokeDark
	lbl.BackgroundTransparency = 0.12
	lbl.Font = UITheme.Fonts.Display
	lbl.TextSize = 14
	lbl.TextColor3 = color
	lbl.Text = "..."
	lbl.Parent = topBar

	Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 10)

	local s = Instance.new("UIStroke")
	s.Color = UITheme.Colors.StrokePill
	s.Thickness = 2
	s.Parent = lbl
	return lbl
end

local cashPill = makeStatPill(134, UITheme.Colors.CashGreen)
local cpsPill = makeStatPill(114, UITheme.Colors.Accent)
local powerPill = makeStatPill(114, UITheme.Colors.BoostOrange)
local foodPill = makeStatPill(168, UITheme.Colors.GemBlue)
local slotPill = makeStatPill(118, UITheme.Colors.GemPurple)

-- Event Banner below Top Bar
local eventBanner = Instance.new("TextLabel")
eventBanner.Size = UDim2.fromOffset(580, 38)
eventBanner.Position = UDim2.new(0.5, -290, 0, 78)
eventBanner.BackgroundColor3 = UITheme.Colors.PillNavy
eventBanner.BackgroundTransparency = 0.08
eventBanner.Font = UITheme.Fonts.Display
eventBanner.TextSize = 15
eventBanner.TextColor3 = UITheme.Colors.HeartRed
eventBanner.Visible = false
eventBanner.Parent = gui

Instance.new("UICorner", eventBanner).CornerRadius = UDim.new(0, 12)

local ebStroke = Instance.new("UIStroke")
ebStroke.Color = UITheme.Colors.HeartRed
ebStroke.Thickness = 2.5
ebStroke.Parent = eventBanner

-- Right-Side Vertical Stack of Arcade Feature Tiles (3D bevel + squish)
local dock = Instance.new("Frame")
dock.Size = UDim2.fromOffset(214, 354)
dock.Position = UDim2.new(1, -230, 0.5, -177)
dock.BackgroundTransparency = 1
dock.Parent = gui

local dockLayout = Instance.new("UIListLayout")
dockLayout.Padding = UDim.new(0, 10)
dockLayout.Parent = dock

local function makeArcadeTile(
	text: string,
	topColor: Color3,
	botColor: Color3,
	lipColor: Color3,
	textColor: Color3
): TextButton
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(214, 50)
	holder.BackgroundColor3 = lipColor
	holder.BorderSizePixel = 0
	holder.Parent = dock

	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 16)

	local hStroke = Instance.new("UIStroke")
	hStroke.Color = UITheme.Colors.StrokeDark
	hStroke.Thickness = 2.5
	hStroke.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, -5)
	btn.BackgroundColor3 = topColor
	btn.BorderSizePixel = 0
	btn.Font = UITheme.Fonts.Display
	btn.TextSize = 15
	btn.TextColor3 = textColor
	btn.Text = text
	btn.Parent = holder

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)

	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = ColorSequence.new(topColor, botColor)
	grad.Parent = btn

	UITheme.AttachSquish(btn, holder)
	return btn
end

local shopBtn = makeArcadeTile("FOOD SHOP", Color3.fromHex("#7DD3FC"), UITheme.Colors.EnergyBlue, Color3.fromHex("#075985"), UITheme.Colors.StrokeDark)
local invBtn = makeArcadeTile("INVENTORY", Color3.fromHex("#38BDF8"), Color3.fromHex("#2563EB"), Color3.fromHex("#1E3A8A"), UITheme.Colors.OnSurface)
local indexBtn = makeArcadeTile("ANIME INDEX (0/12)", UITheme.Colors.GemPurple, Color3.fromHex("#6B21A8"), Color3.fromHex("#3B0764"), UITheme.Colors.OnSurface)
local slotBtn = makeArcadeTile("+1 SLOT ($250)", Color3.fromHex("#6EE7B7"), UITheme.Colors.CashGreen, Color3.fromHex("#065F46"), UITheme.Colors.StrokeDark)
local rebirthBtn = makeArcadeTile("REBIRTH ($15.0K)", UITheme.Colors.Gold, UITheme.Colors.BoostOrange, Color3.fromHex("#9A3412"), UITheme.Colors.StrokeDark)
local baseBtn = makeArcadeTile("TP TO BASE", Color3.fromHex("#334155"), UITheme.Colors.StrokeDark, Color3.fromHex("#020617"), UITheme.Colors.OnSurface)

-- Backdrop & Shared Modal Container
local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 0.35
backdrop.BorderSizePixel = 0
backdrop.Visible = false
backdrop.ZIndex = 9
backdrop.Parent = gui

local shopInv = ShopAndInventory.Create(gui, backdrop)

local modal = Instance.new("Frame")
modal.Size = UDim2.fromOffset(640, 440)
modal.Position = UDim2.new(0.5, -320, 0.5, -220)
modal.BackgroundColor3 = UITheme.Colors.Surface
modal.BorderSizePixel = 0
modal.Visible = false
modal.ZIndex = 10
modal.Parent = gui

Instance.new("UICorner", modal).CornerRadius = UDim.new(0, 22)

local mStroke = Instance.new("UIStroke")
mStroke.Color = UITheme.Colors.EnergyBlue
mStroke.Thickness = 4
mStroke.Parent = modal

local modalHeader = Instance.new("Frame")
modalHeader.Size = UDim2.new(1, 0, 0, 68)
modalHeader.BackgroundColor3 = UITheme.Colors.PillNavy
modalHeader.BorderSizePixel = 0
modalHeader.ZIndex = 11
modalHeader.Parent = modal
Instance.new("UICorner", modalHeader).CornerRadius = UDim.new(0, 22)

local mhGrad = Instance.new("UIGradient")
mhGrad.Color = ColorSequence.new(Color3.fromHex("#082F49"), UITheme.Colors.StrokePill)
mhGrad.Parent = modalHeader

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -76, 0, 28)
modalTitle.Position = UDim2.fromOffset(20, 10)
modalTitle.BackgroundTransparency = 1
modalTitle.Font = UITheme.Fonts.Display
modalTitle.TextSize = 22
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.TextColor3 = UITheme.Colors.GemBlue
modalTitle.ZIndex = 12
modalTitle.Parent = modalHeader

local modalSub = Instance.new("TextLabel")
modalSub.Size = UDim2.new(1, -76, 0, 20)
modalSub.Position = UDim2.fromOffset(20, 38)
modalSub.BackgroundTransparency = 1
modalSub.Font = UITheme.Fonts.Body
modalSub.TextSize = 14
modalSub.TextXAlignment = Enum.TextXAlignment.Left
modalSub.TextColor3 = UITheme.Colors.OnSurface
modalSub.ZIndex = 12
modalSub.Parent = modalHeader

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(38, 38)
closeBtn.Position = UDim2.new(1, -52, 0, 15)
closeBtn.BackgroundColor3 = UITheme.Colors.HeartRed
closeBtn.Font = UITheme.Fonts.Display
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 18
closeBtn.ZIndex = 12
closeBtn.Parent = modalHeader
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)

local clStroke = Instance.new("UIStroke")
clStroke.Color = Color3.new(1, 1, 1)
clStroke.Thickness = 2
clStroke.Parent = closeBtn
UITheme.AttachSquish(closeBtn)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -28, 1, -86)
scroll.Position = UDim2.fromOffset(14, 78)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 6
scroll.ZIndex = 11
scroll.Parent = modal

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.fromOffset(12, 12)
gridLayout.Parent = scroll

-- Rebirth Confirmation Modal
local rebirthModal = Instance.new("Frame")
rebirthModal.Size = UDim2.fromOffset(400, 254)
rebirthModal.Position = UDim2.new(0.5, -200, 0.5, -127)
rebirthModal.BackgroundColor3 = UITheme.Colors.Surface
rebirthModal.BorderSizePixel = 0
rebirthModal.Visible = false
rebirthModal.ZIndex = 15
rebirthModal.Parent = gui

Instance.new("UICorner", rebirthModal).CornerRadius = UDim.new(0, 22)

local rmStroke = Instance.new("UIStroke")
rmStroke.Color = UITheme.Colors.BoostOrange
rmStroke.Thickness = 4
rmStroke.Parent = rebirthModal

local rmBadge = Instance.new("TextLabel")
rmBadge.Size = UDim2.fromOffset(58, 58)
rmBadge.Position = UDim2.new(0.5, -29, 0, 18)
rmBadge.BackgroundColor3 = UITheme.Colors.BoostOrange
rmBadge.Font = UITheme.Fonts.Display
rmBadge.TextSize = 24
rmBadge.TextColor3 = Color3.new(1, 1, 1)
rmBadge.Text = "2X"
rmBadge.ZIndex = 16
rmBadge.Parent = rebirthModal
Instance.new("UICorner", rmBadge).CornerRadius = UDim.new(1, 0)

local rmbStroke = Instance.new("UIStroke")
rmbStroke.Color = Color3.new(1, 1, 1)
rmbStroke.Thickness = 2.5
rmbStroke.Parent = rmBadge

local rmTitle = Instance.new("TextLabel")
rmTitle.Size = UDim2.new(1, -32, 0, 28)
rmTitle.Position = UDim2.fromOffset(16, 86)
rmTitle.BackgroundTransparency = 1
rmTitle.Font = UITheme.Fonts.Display
rmTitle.TextSize = 20
rmTitle.TextColor3 = UITheme.Colors.OnSurface
rmTitle.Text = "REBIRTH CONFIRMATION"
rmTitle.ZIndex = 16
rmTitle.Parent = rebirthModal

local rmDesc = Instance.new("TextLabel")
rmDesc.Size = UDim2.new(1, -36, 0, 44)
rmDesc.Position = UDim2.fromOffset(18, 116)
rmDesc.BackgroundTransparency = 1
rmDesc.Font = UITheme.Fonts.Body
rmDesc.TextSize = 14
rmDesc.TextWrapped = true
rmDesc.TextColor3 = Color3.fromHex("#CBD5E1")
rmDesc.Text = "Spend $15.0K Cash to gain 2x Cash & +25 Throw Power permanently!"
rmDesc.ZIndex = 16
rmDesc.Parent = rebirthModal

local rmCancel = Instance.new("TextButton")
rmCancel.Size = UDim2.fromOffset(168, 44)
rmCancel.Position = UDim2.fromOffset(22, 188)
rmCancel.BackgroundColor3 = Color3.fromHex("#334155")
rmCancel.Font = UITheme.Fonts.Display
rmCancel.TextSize = 15
rmCancel.TextColor3 = UITheme.Colors.OnSurface
rmCancel.Text = "CANCEL"
rmCancel.ZIndex = 16
rmCancel.Parent = rebirthModal
Instance.new("UICorner", rmCancel).CornerRadius = UDim.new(0, 12)
UITheme.AttachSquish(rmCancel)

local rmConfirm = Instance.new("TextButton")
rmConfirm.Size = UDim2.fromOffset(168, 44)
rmConfirm.Position = UDim2.fromOffset(210, 188)
rmConfirm.BackgroundColor3 = UITheme.Colors.BoostOrange
rmConfirm.Font = UITheme.Fonts.Display
rmConfirm.TextSize = 16
rmConfirm.TextColor3 = UITheme.Colors.StrokeDark
rmConfirm.Text = "REBIRTH!"
rmConfirm.ZIndex = 16
rmConfirm.Parent = rebirthModal
Instance.new("UICorner", rmConfirm).CornerRadius = UDim.new(0, 12)
UITheme.AttachSquish(rmConfirm)

local activeMode: string? = nil

local function closeAllModals()
	modal.Visible = false
	rebirthModal.Visible = false
	shopInv.CloseAll()
	backdrop.Visible = false
	activeMode = nil
end

local function renderModal()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	if not latestState then
		return
	end

	if activeMode == "Shop" then
		mStroke.Color = UITheme.Colors.EnergyBlue
		mhGrad.Color = ColorSequence.new(Color3.fromHex("#082F49"), UITheme.Colors.StrokePill)
		modalTitle.Text = "ANIME FOOD WEAPON SHOP"
		modalTitle.TextColor3 = UITheme.Colors.GemBlue
		modalSub.Text = "Upgrade to stronger snacks to reach higher anime gates"
		gridLayout.CellSize = UDim2.fromOffset(292, 134)

		for _, food in ipairs(FoodCatalog.Foods) do
			local card = Instance.new("Frame")
			card.BackgroundColor3 = UITheme.Colors.SurfaceCard
			card.ZIndex = 12
			card.Parent = scroll
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

			local owned = latestState.OwnedFoods[food.Id]
			local equipped = latestState.EquippedFoodId == food.Id
			local cs = Instance.new("UIStroke")
			cs.Color = if equipped then UITheme.Colors.CashGreen elseif food.Cost > 0 then UITheme.Colors.Gold else UITheme.Colors.StrokePill
			cs.Thickness = 2
			cs.Parent = card

			local badge = Instance.new("TextLabel")
			badge.Size = UDim2.fromOffset(136, 20)
			badge.Position = UDim2.fromOffset(12, 10)
			badge.BackgroundColor3 = if food.Cost == 0 then UITheme.Colors.StrokePill else UITheme.Colors.Gold
			badge.Font = UITheme.Fonts.Display
			badge.TextSize = 10
			badge.TextColor3 = if food.Cost == 0 then UITheme.Colors.OnSurface else UITheme.Colors.StrokeDark
			badge.Text = "x" .. tostring(food.PowerMult) .. " DIST • x" .. tostring(food.LuckMult) .. " LUCK"
			badge.ZIndex = 13
			badge.Parent = card
			Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

			local title = Instance.new("TextLabel")
			title.Size = UDim2.new(1, -24, 0, 22)
			title.Position = UDim2.fromOffset(12, 34)
			title.BackgroundTransparency = 1
			title.Font = UITheme.Fonts.Display
			title.TextSize = 15
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextColor3 = if food.Cost == 0 then UITheme.Colors.OnSurface else UITheme.Colors.Accent
			title.Text = food.DisplayName
			title.ZIndex = 13
			title.Parent = card

			local desc = Instance.new("TextLabel")
			desc.Size = UDim2.new(1, -24, 0, 32)
			desc.Position = UDim2.fromOffset(12, 56)
			desc.BackgroundTransparency = 1
			desc.Font = UITheme.Fonts.Body
			desc.TextSize = 12
			desc.TextXAlignment = Enum.TextXAlignment.Left
			desc.TextWrapped = true
			desc.TextColor3 = Color3.fromHex("#94A3B8")
			desc.Text = food.Description
			desc.ZIndex = 13
			desc.Parent = card

			local act = Instance.new("TextButton")
			act.Size = UDim2.new(1, -24, 0, 30)
			act.Position = UDim2.fromOffset(12, 94)
			act.Font = UITheme.Fonts.Display
			act.TextSize = 12
			act.ZIndex = 13
			act.Parent = card
			Instance.new("UICorner", act).CornerRadius = UDim.new(0, 8)
			UITheme.AttachSquish(act)

			if equipped then
				act.Text = "EQUIPPED"
				act.BackgroundColor3 = UITheme.Colors.CashGreen
				act.TextColor3 = UITheme.Colors.StrokeDark
			elseif owned then
				act.Text = "EQUIP"
				act.BackgroundColor3 = UITheme.Colors.EnergyBlue
				act.TextColor3 = UITheme.Colors.StrokeDark
			else
				act.Text = "BUY NOW (" .. UITheme.FormatCash(food.Cost) .. ")"
				act.BackgroundColor3 = UITheme.Colors.Accent
				act.TextColor3 = UITheme.Colors.StrokeDark
			end

			act.MouseButton1Click:Connect(function()
				if owned then
					Remotes.Get(Remotes.EventNames.EquipFood):FireServer(food.Id)
				else
					Remotes.Get(Remotes.EventNames.BuyFood):FireServer(food.Id)
				end
			end)
		end
	elseif activeMode == "Index" then
		mStroke.Color = UITheme.Colors.GemPurple
		mhGrad.Color = ColorSequence.new(Color3.fromHex("#3B0764"), UITheme.Colors.StrokePill)
		modalTitle.Text = "ANIME CHARACTER INDEX"
		modalTitle.TextColor3 = UITheme.Colors.GemPurple
		modalSub.Text = "Discovered: " .. tostring(latestState.DiscoveredCount) .. " / " .. tostring(latestState.TotalCatalog) .. " Anime Brainrots"
		gridLayout.CellSize = UDim2.fromOffset(140, 104)

		for _, pet in ipairs(PetCatalog.Pets) do
			local rar = PetCatalog.Rarities[pet.Rarity] or PetCatalog.Rarities.Common
			local unlocked = latestState.Discovered[pet.Id] == true

			local card = Instance.new("Frame")
			card.BackgroundColor3 = if unlocked then UITheme.Colors.SurfaceCard else UITheme.Colors.StrokeDark
			card.BackgroundTransparency = if unlocked then 0 else 0.25
			card.ZIndex = 12
			card.Parent = scroll
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

			local cs = Instance.new("UIStroke")
			cs.Color = if unlocked then rar.Color else UITheme.Colors.StrokePill
			cs.Thickness = 2
			cs.Parent = card

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1, -12, 0, 38)
			nameLbl.Position = UDim2.fromOffset(6, 12)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Font = UITheme.Fonts.Display
			nameLbl.TextSize = 13
			nameLbl.TextWrapped = true
			nameLbl.TextColor3 = if unlocked then UITheme.Colors.OnSurface else Color3.fromHex("#64748B")
			nameLbl.Text = if unlocked then pet.DisplayName else "???"
			nameLbl.ZIndex = 13
			nameLbl.Parent = card

			local rarLbl = Instance.new("TextLabel")
			rarLbl.Size = UDim2.new(1, -12, 0, 18)
			rarLbl.Position = UDim2.fromOffset(6, 54)
			rarLbl.BackgroundTransparency = 1
			rarLbl.Font = UITheme.Fonts.Body
			rarLbl.TextSize = 11
			rarLbl.TextColor3 = if unlocked then rar.Color else Color3.fromHex("#475569")
			rarLbl.Text = rar.Name
			rarLbl.ZIndex = 13
			rarLbl.Parent = card

			local cpsLbl = Instance.new("TextLabel")
			cpsLbl.Size = UDim2.new(1, -12, 0, 18)
			cpsLbl.Position = UDim2.fromOffset(6, 74)
			cpsLbl.BackgroundTransparency = 1
			cpsLbl.Font = UITheme.Fonts.Display
			cpsLbl.TextSize = 11
			cpsLbl.TextColor3 = UITheme.Colors.CashGreen
			cpsLbl.Text = if unlocked then (UITheme.FormatCash(pet.BaseCashPerSec) .. "/s") else (tostring(pet.MinDistance) .. "m+")
			cpsLbl.ZIndex = 13
			cpsLbl.Parent = card
		end
	end
end

closeBtn.MouseButton1Click:Connect(closeAllModals)
rmCancel.MouseButton1Click:Connect(closeAllModals)
rmConfirm.MouseButton1Click:Connect(function()
	Remotes.Get(Remotes.EventNames.Rebirth):FireServer()
	closeAllModals()
end)

shopBtn.MouseButton1Click:Connect(function()
	modal.Visible = false
	rebirthModal.Visible = false
	activeMode = nil
	shopInv.OpenShop()
end)

invBtn.MouseButton1Click:Connect(function()
	modal.Visible = false
	rebirthModal.Visible = false
	activeMode = nil
	shopInv.OpenInventory()
end)

indexBtn.MouseButton1Click:Connect(function()
	shopInv.CloseAll()
	rebirthModal.Visible = false
	activeMode = "Index"
	backdrop.Visible = true
	renderModal()
	UITheme.PopInModal(modal)
end)

slotBtn.MouseButton1Click:Connect(function()
	Remotes.Get(Remotes.EventNames.UpgradeSlots):FireServer()
end)

rebirthBtn.MouseButton1Click:Connect(function()
	shopInv.CloseAll()
	modal.Visible = false
	activeMode = nil
	if latestState then
		rmDesc.Text = "Spend " .. UITheme.FormatCash(latestState.NextRebirthCost) .. " Cash to gain " .. tostring(latestState.RebirthMult * 2) .. "x Cash & +25 Throw Power permanently!"
	end
	backdrop.Visible = true
	UITheme.PopInModal(rebirthModal)
end)

baseBtn.MouseButton1Click:Connect(function()
	Remotes.Get(Remotes.EventNames.TeleportBase):FireServer()
end)

Remotes.Get(Remotes.EventNames.BuyFood).OnClientEvent:Connect(function(data: any)
	if data and data.OpenShop then
		modal.Visible = false
		rebirthModal.Visible = false
		activeMode = nil
		shopInv.OpenShop()
	end
end)

Remotes.Get(Remotes.EventNames.EventBanner).OnClientEvent:Connect(function(data: any)
	if data and data.Text then
		eventBanner.Text = data.Text
		eventBanner.TextColor3 = data.Color or UITheme.Colors.Accent
		UITheme.PopInModal(eventBanner :: any)
		task.delay(4.5, function()
			eventBanner.Visible = false
		end)
	end
end)

-- Bottom-Left Active Potions / Boosts Strip
local boostStrip = Instance.new("Frame")
boostStrip.Size = UDim2.fromOffset(240, 110)
boostStrip.Position = UDim2.new(0, 18, 1, -126)
boostStrip.BackgroundTransparency = 1
boostStrip.Parent = gui

local bsLayout = Instance.new("UIListLayout")
bsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
bsLayout.Padding = UDim.new(0, 6)
bsLayout.Parent = boostStrip

local function makeBoostPill(color: Color3): TextLabel
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(180, 30)
	lbl.BackgroundColor3 = UITheme.Colors.PillNavy
	lbl.Font = UITheme.Fonts.Display
	lbl.TextSize = 12
	lbl.TextColor3 = color
	lbl.Visible = false
	lbl.Parent = boostStrip
	Instance.new("UICorner", lbl).CornerRadius = UDim.new(1, 0)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = 2
	s.Parent = lbl
	return lbl
end

local luckPill = makeBoostPill(UITheme.Colors.LuckGreen)
local hastePill = makeBoostPill(UITheme.Colors.EnergyBlue)
local fortunePill = makeBoostPill(UITheme.Colors.GemPurple)

Remotes.Get(Remotes.EventNames.StateSync).OnClientEvent:Connect(function(state: any)
	latestState = state
	shopInv.UpdateState(state)
	cashPill.Text = "Cash: " .. UITheme.FormatCash(state.Cash)
	cpsPill.Text = "+" .. UITheme.FormatCash(state.CashPerSec) .. "/s"
	powerPill.Text = "Power: " .. tostring(state.ThrowPower)
	foodPill.Text = state.EquippedFoodName
	slotPill.Text = "Pets: " .. tostring(#state.Pets) .. "/" .. tostring(state.BaseSlots)

	local lr = state.LuckRemaining or 0
	luckPill.Visible = lr > 0
	if lr > 0 then luckPill.Text = "2X LUCK • " .. tostring(lr) .. "s" end

	local hr = state.HasteRemaining or 0
	hastePill.Visible = hr > 0
	if hr > 0 then hastePill.Text = "HASTE • " .. tostring(hr) .. "s" end

	local fr = state.FortuneRemaining or 0
	fortunePill.Visible = fr > 0
	if fr > 0 then fortunePill.Text = "FORTUNE • " .. tostring(fr) .. "s" end

	indexBtn.Text = "ANIME INDEX (" .. tostring(state.DiscoveredCount) .. "/" .. tostring(state.TotalCatalog) .. ")"
	slotBtn.Text = if state.BaseSlots >= GameConfig.MaxBaseSlots then "SLOTS MAXED" else ("+1 SLOT (" .. UITheme.FormatCash(state.NextSlotCost) .. ")")
	rebirthBtn.Text = "REBIRTH (" .. UITheme.FormatCash(state.NextRebirthCost) .. ")"

	if modal.Visible then
		renderModal()
	end
end)
