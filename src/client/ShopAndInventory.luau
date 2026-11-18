--!strict
-- BloxRNG Shop Modal (Foods + Potions + Purchase Confirmation) and 2-Column Backpack & Inventory Modal (Grid + Item Inspector).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FoodCatalog = require(ReplicatedStorage.Shared.FoodCatalog)
local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UITheme = require(ReplicatedStorage.Shared.UITheme)

export type Controller = {
	OpenShop: () -> (),
	OpenInventory: () -> (),
	CloseAll: () -> (),
	UpdateState: (state: any) -> (),
}

local ShopAndInventory = {}

function ShopAndInventory.Create(gui: ScreenGui, backdrop: Frame): Controller
	local latestState: any = nil
	local shopFilter = "all"
	local invFilter = "all"
	local selectedKind: string? = nil
	local selectedId: string? = nil

	-- =========================================================================
	-- 1. ROBLOX GAME STORE MODAL (Foods + Potions)
	-- =========================================================================
	local shopModal = Instance.new("Frame")
	shopModal.Size = UDim2.fromOffset(720, 470)
	shopModal.Position = UDim2.new(0.5, -360, 0.5, -235)
	shopModal.BackgroundColor3 = UITheme.Colors.Surface
	shopModal.BorderSizePixel = 0
	shopModal.Visible = false
	shopModal.ZIndex = 10
	shopModal.Parent = gui
	Instance.new("UICorner", shopModal).CornerRadius = UDim.new(0, 22)

	local smStroke = Instance.new("UIStroke")
	smStroke.Color = Color3.fromHex("#6366F1")
	smStroke.Thickness = 4
	smStroke.Parent = shopModal

	local shopHeader = Instance.new("Frame")
	shopHeader.Size = UDim2.new(1, 0, 0, 74)
	shopHeader.BackgroundColor3 = UITheme.Colors.PillNavy
	shopHeader.BorderSizePixel = 0
	shopHeader.ZIndex = 11
	shopHeader.Parent = shopModal
	Instance.new("UICorner", shopHeader).CornerRadius = UDim.new(0, 22)

	local shGrad = Instance.new("UIGradient")
	shGrad.Color = ColorSequence.new(UITheme.Colors.StrokePill, Color3.fromHex("#3B0764"))
	shGrad.Parent = shopHeader

	local shopTitle = Instance.new("TextLabel")
	shopTitle.Size = UDim2.fromOffset(260, 28)
	shopTitle.Position = UDim2.fromOffset(20, 12)
	shopTitle.BackgroundTransparency = 1
	shopTitle.Font = UITheme.Fonts.Display
	shopTitle.TextSize = 21
	shopTitle.TextXAlignment = Enum.TextXAlignment.Left
	shopTitle.TextColor3 = Color3.fromHex("#FCD34D")
	shopTitle.Text = "ROBLOX GAME STORE"
	shopTitle.ZIndex = 12
	shopTitle.Parent = shopHeader

	local saleBadge = Instance.new("TextLabel")
	saleBadge.Size = UDim2.fromOffset(88, 20)
	saleBadge.Position = UDim2.fromOffset(252, 16)
	saleBadge.BackgroundColor3 = UITheme.Colors.HeartRed
	saleBadge.Font = UITheme.Fonts.Display
	saleBadge.TextSize = 10
	saleBadge.TextColor3 = Color3.new(1, 1, 1)
	saleBadge.Text = "LUCKY SALE"
	saleBadge.ZIndex = 12
	saleBadge.Parent = shopHeader
	Instance.new("UICorner", saleBadge).CornerRadius = UDim.new(1, 0)

	local shopSub = Instance.new("TextLabel")
	shopSub.Size = UDim2.fromOffset(340, 18)
	shopSub.Position = UDim2.fromOffset(20, 44)
	shopSub.BackgroundTransparency = 1
	shopSub.Font = UITheme.Fonts.Body
	shopSub.TextSize = 12
	shopSub.TextXAlignment = Enum.TextXAlignment.Left
	shopSub.TextColor3 = Color3.fromHex("#CBD5E1")
	shopSub.Text = "Upgrade throwable anime foods & luck potions"
	shopSub.ZIndex = 12
	shopSub.Parent = shopHeader

	local shopClose = Instance.new("TextButton")
	shopClose.Size = UDim2.fromOffset(36, 36)
	shopClose.Position = UDim2.new(1, -48, 0, 19)
	shopClose.BackgroundColor3 = UITheme.Colors.HeartRed
	shopClose.Font = UITheme.Fonts.Display
	shopClose.Text = "X"
	shopClose.TextColor3 = Color3.new(1, 1, 1)
	shopClose.TextSize = 16
	shopClose.ZIndex = 12
	shopClose.Parent = shopHeader
	Instance.new("UICorner", shopClose).CornerRadius = UDim.new(0, 10)
	UITheme.AttachSquish(shopClose)

	-- Shop Filter Tabs
	local shopTabsFrame = Instance.new("Frame")
	shopTabsFrame.Size = UDim2.fromOffset(270, 38)
	shopTabsFrame.Position = UDim2.new(1, -330, 0, 18)
	shopTabsFrame.BackgroundColor3 = UITheme.Colors.StrokeDark
	shopTabsFrame.ZIndex = 12
	shopTabsFrame.Parent = shopHeader
	Instance.new("UICorner", shopTabsFrame).CornerRadius = UDim.new(0, 12)

	local stLayout = Instance.new("UIListLayout")
	stLayout.FillDirection = Enum.FillDirection.Horizontal
	stLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	stLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	stLayout.Padding = UDim.new(0, 4)
	stLayout.Parent = shopTabsFrame

	local shopScroll = Instance.new("ScrollingFrame")
	shopScroll.Size = UDim2.new(1, -28, 1, -92)
	shopScroll.Position = UDim2.fromOffset(14, 82)
	shopScroll.BackgroundTransparency = 1
	shopScroll.CanvasSize = UDim2.fromOffset(0, 0)
	shopScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	shopScroll.ScrollBarThickness = 6
	shopScroll.ZIndex = 11
	shopScroll.Parent = shopModal

	local shopGrid = Instance.new("UIGridLayout")
	shopGrid.CellSize = UDim2.fromOffset(332, 134)
	shopGrid.CellPadding = UDim2.fromOffset(12, 12)
	shopGrid.Parent = shopScroll

	-- =========================================================================
	-- 2. PURCHASE CONFIRMATION POPUP
	-- =========================================================================
	local confirmModal = Instance.new("Frame")
	confirmModal.Size = UDim2.fromOffset(380, 230)
	confirmModal.Position = UDim2.new(0.5, -190, 0.5, -115)
	confirmModal.BackgroundColor3 = UITheme.Colors.Surface
	confirmModal.Visible = false
	confirmModal.ZIndex = 20
	confirmModal.Parent = gui
	Instance.new("UICorner", confirmModal).CornerRadius = UDim.new(0, 20)

	local cmStroke = Instance.new("UIStroke")
	cmStroke.Color = UITheme.Colors.Accent
	cmStroke.Thickness = 4
	cmStroke.Parent = confirmModal

	local cmTitle = Instance.new("TextLabel")
	cmTitle.Size = UDim2.new(1, -32, 0, 30)
	cmTitle.Position = UDim2.fromOffset(16, 22)
	cmTitle.BackgroundTransparency = 1
	cmTitle.Font = UITheme.Fonts.Display
	cmTitle.TextSize = 20
	cmTitle.TextColor3 = Color3.new(1, 1, 1)
	cmTitle.Text = "PURCHASE CONFIRMATION"
	cmTitle.ZIndex = 21
	cmTitle.Parent = confirmModal

	local cmDesc = Instance.new("TextLabel")
	cmDesc.Size = UDim2.new(1, -40, 0, 60)
	cmDesc.Position = UDim2.fromOffset(20, 66)
	cmDesc.BackgroundTransparency = 1
	cmDesc.Font = UITheme.Fonts.Body
	cmDesc.TextSize = 15
	cmDesc.TextWrapped = true
	cmDesc.TextColor3 = Color3.fromHex("#CBD5E1")
	cmDesc.ZIndex = 21
	cmDesc.Parent = confirmModal

	local cmCancel = Instance.new("TextButton")
	cmCancel.Size = UDim2.fromOffset(156, 44)
	cmCancel.Position = UDim2.fromOffset(24, 164)
	cmCancel.BackgroundColor3 = Color3.fromHex("#334155")
	cmCancel.Font = UITheme.Fonts.Display
	cmCancel.TextSize = 15
	cmCancel.TextColor3 = Color3.new(1, 1, 1)
	cmCancel.Text = "CANCEL"
	cmCancel.ZIndex = 21
	cmCancel.Parent = confirmModal
	Instance.new("UICorner", cmCancel).CornerRadius = UDim.new(0, 12)
	UITheme.AttachSquish(cmCancel)

	local cmBuy = Instance.new("TextButton")
	cmBuy.Size = UDim2.fromOffset(156, 44)
	cmBuy.Position = UDim2.fromOffset(200, 164)
	cmBuy.BackgroundColor3 = UITheme.Colors.CashGreen
	cmBuy.Font = UITheme.Fonts.Display
	cmBuy.TextSize = 15
	cmBuy.TextColor3 = UITheme.Colors.StrokeDark
	cmBuy.Text = "BUY NOW"
	cmBuy.ZIndex = 21
	cmBuy.Parent = confirmModal
	Instance.new("UICorner", cmBuy).CornerRadius = UDim.new(0, 12)
	UITheme.AttachSquish(cmBuy)

	local pendingBuyFn: (() -> ())? = nil
	cmCancel.MouseButton1Click:Connect(function()
		confirmModal.Visible = false
		pendingBuyFn = nil
	end)
	cmBuy.MouseButton1Click:Connect(function()
		if pendingBuyFn then
			pendingBuyFn()
		end
		confirmModal.Visible = false
		pendingBuyFn = nil
	end)

	local function openConfirm(itemName: string, cost: number, onConfirm: () -> ())
		pendingBuyFn = onConfirm
		cmDesc.Text = "Buy " .. itemName .. " for " .. UITheme.FormatCash(cost) .. "?"
		UITheme.PopInModal(confirmModal)
	end

	-- =========================================================================
	-- 3. BACKPACK & INVENTORY MODAL (2-Column: Grid + Item Inspector)
	-- =========================================================================
	local invModal = Instance.new("Frame")
	invModal.Size = UDim2.fromOffset(760, 470)
	invModal.Position = UDim2.new(0.5, -380, 0.5, -235)
	invModal.BackgroundColor3 = UITheme.Colors.Surface
	invModal.BorderSizePixel = 0
	invModal.Visible = false
	invModal.ZIndex = 10
	invModal.Parent = gui
	Instance.new("UICorner", invModal).CornerRadius = UDim.new(0, 22)

	local imStroke = Instance.new("UIStroke")
	imStroke.Color = UITheme.Colors.EnergyBlue
	imStroke.Thickness = 4
	imStroke.Parent = invModal

	local invHeader = Instance.new("Frame")
	invHeader.Size = UDim2.new(1, 0, 0, 74)
	invHeader.BackgroundColor3 = UITheme.Colors.PillNavy
	invHeader.BorderSizePixel = 0
	invHeader.ZIndex = 11
	invHeader.Parent = invModal
	Instance.new("UICorner", invHeader).CornerRadius = UDim.new(0, 22)

	local ihGrad = Instance.new("UIGradient")
	ihGrad.Color = ColorSequence.new(Color3.fromHex("#082F49"), UITheme.Colors.StrokePill)
	ihGrad.Parent = invHeader

	local invTitle = Instance.new("TextLabel")
	invTitle.Size = UDim2.fromOffset(330, 28)
	invTitle.Position = UDim2.fromOffset(20, 12)
	invTitle.BackgroundTransparency = 1
	invTitle.Font = UITheme.Fonts.Display
	invTitle.TextSize = 20
	invTitle.TextXAlignment = Enum.TextXAlignment.Left
	invTitle.TextColor3 = Color3.fromHex("#67E8F9")
	invTitle.Text = "BACKPACK & INVENTORY"
	invTitle.ZIndex = 12
	invTitle.Parent = invHeader

	local invSub = Instance.new("TextLabel")
	invSub.Size = UDim2.fromOffset(350, 18)
	invSub.Position = UDim2.fromOffset(20, 44)
	invSub.BackgroundTransparency = 1
	invSub.Font = UITheme.Fonts.Body
	invSub.TextSize = 12
	invSub.TextXAlignment = Enum.TextXAlignment.Left
	invSub.TextColor3 = Color3.fromHex("#CBD5E1")
	invSub.Text = "Inspect pets, lock favorites, equip foods & check active potions"
	invSub.ZIndex = 12
	invSub.Parent = invHeader

	local invClose = Instance.new("TextButton")
	invClose.Size = UDim2.fromOffset(36, 36)
	invClose.Position = UDim2.new(1, -48, 0, 19)
	invClose.BackgroundColor3 = UITheme.Colors.HeartRed
	invClose.Font = UITheme.Fonts.Display
	invClose.Text = "X"
	invClose.TextColor3 = Color3.new(1, 1, 1)
	invClose.TextSize = 16
	invClose.ZIndex = 12
	invClose.Parent = invHeader
	Instance.new("UICorner", invClose).CornerRadius = UDim.new(0, 10)
	UITheme.AttachSquish(invClose)

	local invTabsFrame = Instance.new("Frame")
	invTabsFrame.Size = UDim2.fromOffset(290, 38)
	invTabsFrame.Position = UDim2.new(1, -350, 0, 18)
	invTabsFrame.BackgroundColor3 = UITheme.Colors.StrokeDark
	invTabsFrame.ZIndex = 12
	invTabsFrame.Parent = invHeader
	Instance.new("UICorner", invTabsFrame).CornerRadius = UDim.new(0, 12)

	local itLayout = Instance.new("UIListLayout")
	itLayout.FillDirection = Enum.FillDirection.Horizontal
	itLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	itLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	itLayout.Padding = UDim.new(0, 4)
	itLayout.Parent = invTabsFrame

	-- Left Grid
	local invScroll = Instance.new("ScrollingFrame")
	invScroll.Size = UDim2.new(1, -276, 1, -92)
	invScroll.Position = UDim2.fromOffset(14, 82)
	invScroll.BackgroundTransparency = 1
	invScroll.CanvasSize = UDim2.fromOffset(0, 0)
	invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	invScroll.ScrollBarThickness = 6
	invScroll.ZIndex = 11
	invScroll.Parent = invModal

	local invGrid = Instance.new("UIGridLayout")
	invGrid.CellSize = UDim2.fromOffset(110, 118)
	invGrid.CellPadding = UDim2.fromOffset(10, 10)
	invGrid.Parent = invScroll

	-- Right Item Inspector Panel
	local inspector = Instance.new("Frame")
	inspector.Size = UDim2.new(0, 240, 1, -92)
	inspector.Position = UDim2.new(1, -252, 0, 82)
	inspector.BackgroundColor3 = UITheme.Colors.PillNavy
	inspector.ZIndex = 11
	inspector.Parent = invModal
	Instance.new("UICorner", inspector).CornerRadius = UDim.new(0, 16)

	local insStroke = Instance.new("UIStroke")
	insStroke.Color = UITheme.Colors.Accent
	insStroke.Thickness = 2.5
	insStroke.Parent = inspector

	local insBadge = Instance.new("Frame")
	insBadge.Size = UDim2.fromOffset(66, 66)
	insBadge.Position = UDim2.new(0.5, -33, 0, 16)
	insBadge.BackgroundColor3 = UITheme.Colors.GemPurple
	insBadge.ZIndex = 12
	insBadge.Parent = inspector
	Instance.new("UICorner", insBadge).CornerRadius = UDim.new(1, 0)

	local insBadgeStroke = Instance.new("UIStroke")
	insBadgeStroke.Color = Color3.new(1, 1, 1)
	insBadgeStroke.Thickness = 2.5
	insBadgeStroke.Parent = insBadge

	local insBadgeTxt = Instance.new("TextLabel")
	insBadgeTxt.Size = UDim2.fromScale(1, 1)
	insBadgeTxt.BackgroundTransparency = 1
	insBadgeTxt.Font = UITheme.Fonts.Display
	insBadgeTxt.TextSize = 20
	insBadgeTxt.TextColor3 = Color3.new(1, 1, 1)
	insBadgeTxt.Text = "PET"
	insBadgeTxt.ZIndex = 13
	insBadgeTxt.Parent = insBadge

	local insTitle = Instance.new("TextLabel")
	insTitle.Size = UDim2.new(1, -16, 0, 38)
	insTitle.Position = UDim2.fromOffset(8, 88)
	insTitle.BackgroundTransparency = 1
	insTitle.Font = UITheme.Fonts.Display
	insTitle.TextSize = 15
	insTitle.TextWrapped = true
	insTitle.TextColor3 = UITheme.Colors.Accent
	insTitle.Text = "Select an Item"
	insTitle.ZIndex = 12
	insTitle.Parent = inspector

	local insTag = Instance.new("TextLabel")
	insTag.Size = UDim2.fromOffset(170, 22)
	insTag.Position = UDim2.new(0.5, -85, 0, 128)
	insTag.BackgroundColor3 = UITheme.Colors.GemPurple
	insTag.Font = UITheme.Fonts.Display
	insTag.TextSize = 11
	insTag.TextColor3 = Color3.new(1, 1, 1)
	insTag.Text = "ITEM INSPECTOR"
	insTag.ZIndex = 12
	insTag.Parent = inspector
	Instance.new("UICorner", insTag).CornerRadius = UDim.new(0, 6)

	local insPerks = Instance.new("TextLabel")
	insPerks.Size = UDim2.new(1, -20, 0, 80)
	insPerks.Position = UDim2.fromOffset(10, 158)
	insPerks.BackgroundColor3 = UITheme.Colors.StrokeDark
	insPerks.Font = UITheme.Fonts.Body
	insPerks.TextSize = 12
	insPerks.TextWrapped = true
	insPerks.TextColor3 = UITheme.Colors.CashGreen
	insPerks.Text = "Click any pet, food, or active potion on the left to inspect stats and actions."
	insPerks.ZIndex = 12
	insPerks.Parent = inspector
	Instance.new("UICorner", insPerks).CornerRadius = UDim.new(0, 10)

	local insAction1 = Instance.new("TextButton")
	insAction1.Size = UDim2.new(1, -20, 0, 38)
	insAction1.Position = UDim2.new(0, 10, 1, -90)
	insAction1.BackgroundColor3 = UITheme.Colors.CashGreen
	insAction1.Font = UITheme.Fonts.Display
	insAction1.TextSize = 13
	insAction1.TextColor3 = UITheme.Colors.StrokeDark
	insAction1.Text = "EQUIP / LOCK"
	insAction1.Visible = false
	insAction1.ZIndex = 12
	insAction1.Parent = inspector
	Instance.new("UICorner", insAction1).CornerRadius = UDim.new(0, 10)
	UITheme.AttachSquish(insAction1)

	local insAction2 = Instance.new("TextButton")
	insAction2.Size = UDim2.new(1, -20, 0, 34)
	insAction2.Position = UDim2.new(0, 10, 1, -44)
	insAction2.BackgroundColor3 = UITheme.Colors.HeartRed
	insAction2.Font = UITheme.Fonts.Display
	insAction2.TextSize = 12
	insAction2.TextColor3 = Color3.new(1, 1, 1)
	insAction2.Text = "SELL PET"
	insAction2.Visible = false
	insAction2.ZIndex = 12
	insAction2.Parent = inspector
	Instance.new("UICorner", insAction2).CornerRadius = UDim.new(0, 10)
	UITheme.AttachSquish(insAction2)

	-- Forward declarations for renderers
	local renderShop: () -> ()
	local renderInventory: () -> ()

	local function makeFilterTab(parent: Frame, label: string, width: number, isActive: boolean, onClick: () -> ()): TextButton
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(width, 28)
		btn.BackgroundColor3 = if isActive then UITheme.Colors.EnergyBlue else UITheme.Colors.StrokeDark
		btn.BackgroundTransparency = if isActive then 0 else 1
		btn.Font = UITheme.Fonts.Display
		btn.TextSize = 11
		btn.TextColor3 = if isActive then UITheme.Colors.StrokeDark else Color3.fromHex("#94A3B8")
		btn.Text = label
		btn.ZIndex = 13
		btn.Parent = parent
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end

	renderShop = function()
		for _, c in ipairs(shopTabsFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		makeFilterTab(shopTabsFrame, "ALL", 68, shopFilter == "all", function() shopFilter = "all"; renderShop() end)
		makeFilterTab(shopTabsFrame, "FOODS", 86, shopFilter == "foods", function() shopFilter = "foods"; renderShop() end)
		makeFilterTab(shopTabsFrame, "POTIONS", 96, shopFilter == "potions", function() shopFilter = "potions"; renderShop() end)

		for _, c in ipairs(shopScroll:GetChildren()) do
			if c:IsA("Frame") then c:Destroy() end
		end
		if not latestState then return end

		if shopFilter == "all" or shopFilter == "foods" then
			for _, food in ipairs(FoodCatalog.Foods) do
				local card = Instance.new("Frame")
				card.BackgroundColor3 = UITheme.Colors.SurfaceCard
				card.ZIndex = 12
				card.Parent = shopScroll
				Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

				local owned = latestState.OwnedFoods[food.Id]
				local equipped = latestState.EquippedFoodId == food.Id
				local cs = Instance.new("UIStroke")
				cs.Color = if equipped then UITheme.Colors.CashGreen elseif food.Cost > 0 then UITheme.Colors.Gold else UITheme.Colors.StrokePill
				cs.Thickness = 2
				cs.Parent = card

				local badge = Instance.new("TextLabel")
				badge.Size = UDim2.fromOffset(142, 20)
				badge.Position = UDim2.fromOffset(12, 10)
				badge.BackgroundColor3 = if food.Cost == 0 then UITheme.Colors.StrokePill else UITheme.Colors.Gold
				badge.Font = UITheme.Fonts.Display
				badge.TextSize = 10
				badge.TextColor3 = if food.Cost == 0 then UITheme.Colors.OnSurface else UITheme.Colors.StrokeDark
				badge.Text = "FOOD • x" .. tostring(food.PowerMult) .. " DIST"
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
				desc.Text = food.Description .. " (x" .. tostring(food.LuckMult) .. " Luck)"
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
						openConfirm(food.DisplayName, food.Cost, function()
							Remotes.Get(Remotes.EventNames.BuyFood):FireServer(food.Id)
						end)
					end
				end)
			end
		end

		if shopFilter == "all" or shopFilter == "potions" then
			for _, pot in ipairs(FoodCatalog.Potions) do
				local card = Instance.new("Frame")
				card.BackgroundColor3 = UITheme.Colors.SurfaceCard
				card.ZIndex = 12
				card.Parent = shopScroll
				Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

				local cs = Instance.new("UIStroke")
				cs.Color = pot.Color
				cs.Thickness = 2
				cs.Parent = card

				local badge = Instance.new("TextLabel")
				badge.Size = UDim2.fromOffset(120, 20)
				badge.Position = UDim2.fromOffset(12, 10)
				badge.BackgroundColor3 = pot.Color
				badge.Font = UITheme.Fonts.Display
				badge.TextSize = 10
				badge.TextColor3 = UITheme.Colors.StrokeDark
				badge.Text = "ALCHEMY POTION"
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
				title.TextColor3 = pot.Color
				title.Text = pot.DisplayName
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
				desc.Text = pot.Description
				desc.ZIndex = 13
				desc.Parent = card

				local act = Instance.new("TextButton")
				act.Size = UDim2.new(1, -24, 0, 30)
				act.Position = UDim2.fromOffset(12, 94)
				act.BackgroundColor3 = UITheme.Colors.EnergyBlue
				act.Font = UITheme.Fonts.Display
				act.TextSize = 12
				act.TextColor3 = UITheme.Colors.StrokeDark
				act.Text = "DRINK NOW (" .. UITheme.FormatCash(pot.Cost) .. ")"
				act.ZIndex = 13
				act.Parent = card
				Instance.new("UICorner", act).CornerRadius = UDim.new(0, 8)
				UITheme.AttachSquish(act)

				act.MouseButton1Click:Connect(function()
					openConfirm(pot.DisplayName, pot.Cost, function()
						Remotes.Get(Remotes.EventNames.BuyPotion):FireServer(pot.Id)
					end)
				end)
			end
		end
	end

	local function updateInspector()
		insAction1.Visible = false
		insAction2.Visible = false
		if not latestState or not selectedKind or not selectedId then
			return
		end

		if selectedKind == "Pet" then
			for _, p in ipairs(latestState.Pets) do
				if p.Uid == selectedId then
					local def = PetCatalog.GetById(p.PetId) or PetCatalog.Pets[1]
					local rar = PetCatalog.Rarities[def.Rarity] or PetCatalog.Rarities.Common
					insBadge.BackgroundColor3 = rar.Color
					insBadgeTxt.Text = def.StyleTag:sub(1, 3):upper()
					insTitle.Text = (if p.Mutation ~= "Normal" then ("[" .. p.Mutation .. "] ") else "") .. def.DisplayName
					insTitle.TextColor3 = rar.Color
					insTag.BackgroundColor3 = rar.Color
					insTag.TextColor3 = UITheme.Colors.StrokeDark
					insTag.Text = rar.Name .. " • " .. p.Mutation
					insPerks.Text = "Earns +" .. UITheme.FormatCash(p.CashPerSec) .. "/s on Base\n" .. def.Quote .. "\nStatus: " .. (if p.Locked then "LOCKED" else "Unlocked")

					insAction1.Visible = true
					insAction1.BackgroundColor3 = if p.Locked then UITheme.Colors.Gold else UITheme.Colors.EnergyBlue
					insAction1.Text = if p.Locked then "UNLOCK PET" else "LOCK PET"
					insAction1.MouseButton1Click:Connect(function()
						Remotes.Get(Remotes.EventNames.ToggleLockPet):FireServer(p.Uid)
					end)

					insAction2.Visible = not p.Locked
					insAction2.Text = "SELL (+" .. UITheme.FormatCash(p.CashPerSec * 15) .. ")"
					insAction2.MouseButton1Click:Connect(function()
						Remotes.Get(Remotes.EventNames.SellPet):FireServer(p.Uid)
						selectedKind = nil
						selectedId = nil
					end)
					return
				end
			end
		elseif selectedKind == "Food" then
			local food = FoodCatalog.GetById(selectedId)
			local equipped = latestState.EquippedFoodId == food.Id
			insBadge.BackgroundColor3 = food.Color
			insBadgeTxt.Text = "FOOD"
			insTitle.Text = food.DisplayName
			insTitle.TextColor3 = UITheme.Colors.Accent
			insTag.BackgroundColor3 = UITheme.Colors.EnergyBlue
			insTag.TextColor3 = UITheme.Colors.StrokeDark
			insTag.Text = "Throwable Food"
			insPerks.Text = "Distance x" .. tostring(food.PowerMult) .. "\nLuck x" .. tostring(food.LuckMult) .. "\nLure Radius: " .. tostring(food.LureRadius) .. "m"

			insAction1.Visible = true
			insAction1.BackgroundColor3 = if equipped then UITheme.Colors.CashGreen else UITheme.Colors.EnergyBlue
			insAction1.Text = if equipped then "EQUIPPED" else "EQUIP FOOD"
			insAction1.MouseButton1Click:Connect(function()
				if not equipped then
					Remotes.Get(Remotes.EventNames.EquipFood):FireServer(food.Id)
				end
			end)
		end
	end

	renderInventory = function()
		for _, c in ipairs(invTabsFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		makeFilterTab(invTabsFrame, "ALL", 60, invFilter == "all", function() invFilter = "all"; renderInventory() end)
		makeFilterTab(invTabsFrame, "PETS", 66, invFilter == "pets", function() invFilter = "pets"; renderInventory() end)
		makeFilterTab(invTabsFrame, "FOODS", 74, invFilter == "foods", function() invFilter = "foods"; renderInventory() end)
		makeFilterTab(invTabsFrame, "BOOSTS", 74, invFilter == "boosts", function() invFilter = "boosts"; renderInventory() end)

		for _, c in ipairs(invScroll:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		if not latestState then return end

		if invFilter == "all" or invFilter == "pets" then
			for _, p in ipairs(latestState.Pets) do
				local def = PetCatalog.GetById(p.PetId) or PetCatalog.Pets[1]
				local rar = PetCatalog.Rarities[def.Rarity] or PetCatalog.Rarities.Common
				local slot = Instance.new("TextButton")
				slot.BackgroundColor3 = UITheme.Colors.SurfaceCard
				slot.Text = ""
				slot.ZIndex = 12
				slot.Parent = invScroll
				Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 14)

				local ss = Instance.new("UIStroke")
				ss.Color = rar.Color
				ss.Thickness = if selectedKind == "Pet" and selectedId == p.Uid then 3 else 2
				ss.Parent = slot

				local icon = Instance.new("TextLabel")
				icon.Size = UDim2.fromOffset(48, 48)
				icon.Position = UDim2.new(0.5, -24, 0, 16)
				icon.BackgroundColor3 = rar.Color
				icon.Font = UITheme.Fonts.Display
				icon.TextSize = 14
				icon.TextColor3 = UITheme.Colors.StrokeDark
				icon.Text = def.StyleTag:sub(1, 3):upper()
				icon.ZIndex = 13
				icon.Parent = slot
				Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, -8, 0, 28)
				lbl.Position = UDim2.fromOffset(4, 68)
				lbl.BackgroundTransparency = 1
				lbl.Font = UITheme.Fonts.Display
				lbl.TextSize = 11
				lbl.TextWrapped = true
				lbl.TextColor3 = Color3.new(1, 1, 1)
				lbl.Text = def.DisplayName
				lbl.ZIndex = 13
				lbl.Parent = slot

				local sub = Instance.new("TextLabel")
				sub.Size = UDim2.new(1, -8, 0, 16)
				sub.Position = UDim2.fromOffset(4, 96)
				sub.BackgroundTransparency = 1
				sub.Font = UITheme.Fonts.Body
				sub.TextSize = 10
				sub.TextColor3 = UITheme.Colors.CashGreen
				sub.Text = (if p.Locked then "[LOCK] " else "") .. UITheme.FormatCash(p.CashPerSec) .. "/s"
				sub.ZIndex = 13
				sub.Parent = slot

				UITheme.AttachSquish(slot)
				slot.MouseButton1Click:Connect(function()
					selectedKind = "Pet"
					selectedId = p.Uid
					updateInspector()
					renderInventory()
				end)
			end
		end

		if invFilter == "all" or invFilter == "foods" then
			for _, food in ipairs(FoodCatalog.Foods) do
				if latestState.OwnedFoods[food.Id] then
					local equipped = latestState.EquippedFoodId == food.Id
					local slot = Instance.new("TextButton")
					slot.BackgroundColor3 = UITheme.Colors.SurfaceCard
					slot.Text = ""
					slot.ZIndex = 12
					slot.Parent = invScroll
					Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 14)

					local ss = Instance.new("UIStroke")
					ss.Color = if equipped then UITheme.Colors.CashGreen else UITheme.Colors.EnergyBlue
					ss.Thickness = 2
					ss.Parent = slot

					local icon = Instance.new("TextLabel")
					icon.Size = UDim2.fromOffset(48, 48)
					icon.Position = UDim2.new(0.5, -24, 0, 16)
					icon.BackgroundColor3 = food.Color
					icon.Font = UITheme.Fonts.Display
					icon.TextSize = 12
					icon.TextColor3 = UITheme.Colors.StrokeDark
					icon.Text = "FOOD"
					icon.ZIndex = 13
					icon.Parent = slot
					Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(1, -8, 0, 28)
					lbl.Position = UDim2.fromOffset(4, 68)
					lbl.BackgroundTransparency = 1
					lbl.Font = UITheme.Fonts.Display
					lbl.TextSize = 11
					lbl.TextWrapped = true
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.Text = food.DisplayName
					lbl.ZIndex = 13
					lbl.Parent = slot

					local sub = Instance.new("TextLabel")
					sub.Size = UDim2.new(1, -8, 0, 16)
					sub.Position = UDim2.fromOffset(4, 96)
					sub.BackgroundTransparency = 1
					sub.Font = UITheme.Fonts.Body
					sub.TextSize = 10
					sub.TextColor3 = if equipped then UITheme.Colors.CashGreen else UITheme.Colors.GemBlue
					sub.Text = if equipped then "EQUIPPED" else ("x" .. tostring(food.PowerMult) .. " Dist")
					sub.ZIndex = 13
					sub.Parent = slot

					UITheme.AttachSquish(slot)
					slot.MouseButton1Click:Connect(function()
						selectedKind = "Food"
						selectedId = food.Id
						updateInspector()
						renderInventory()
					end)
				end
			end
		end

		if invFilter == "all" or invFilter == "boosts" then
			local boosts = {
				{ Name = "Super Luck", Sec = latestState.LuckRemaining or 0, Color = UITheme.Colors.LuckGreen },
				{ Name = "Throw Haste", Sec = latestState.HasteRemaining or 0, Color = UITheme.Colors.EnergyBlue },
				{ Name = "Fortune Elixir", Sec = latestState.FortuneRemaining or 0, Color = UITheme.Colors.GemPurple },
			}
			for _, b in ipairs(boosts) do
				if b.Sec > 0 then
					local slot = Instance.new("TextButton")
					slot.BackgroundColor3 = UITheme.Colors.SurfaceCard
					slot.Text = ""
					slot.ZIndex = 12
					slot.Parent = invScroll
					Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 14)

					local ss = Instance.new("UIStroke")
					ss.Color = b.Color
					ss.Thickness = 2
					ss.Parent = slot

					local icon = Instance.new("TextLabel")
					icon.Size = UDim2.fromOffset(48, 48)
					icon.Position = UDim2.new(0.5, -24, 0, 16)
					icon.BackgroundColor3 = b.Color
					icon.Font = UITheme.Fonts.Display
					icon.TextSize = 12
					icon.TextColor3 = UITheme.Colors.StrokeDark
					icon.Text = "BUFF"
					icon.ZIndex = 13
					icon.Parent = slot
					Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(1, -8, 0, 28)
					lbl.Position = UDim2.fromOffset(4, 68)
					lbl.BackgroundTransparency = 1
					lbl.Font = UITheme.Fonts.Display
					lbl.TextSize = 11
					lbl.TextWrapped = true
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.Text = b.Name
					lbl.ZIndex = 13
					lbl.Parent = slot

					local sub = Instance.new("TextLabel")
					sub.Size = UDim2.new(1, -8, 0, 16)
					sub.Position = UDim2.fromOffset(4, 96)
					sub.BackgroundTransparency = 1
					sub.Font = UITheme.Fonts.Body
					sub.TextSize = 10
					sub.TextColor3 = b.Color
					sub.Text = tostring(b.Sec) .. "s left"
					sub.ZIndex = 13
					sub.Parent = slot
				end
			end
		end
	end

	local function closeAll()
		shopModal.Visible = false
		invModal.Visible = false
		confirmModal.Visible = false
		backdrop.Visible = false
	end

	shopClose.MouseButton1Click:Connect(closeAll)
	invClose.MouseButton1Click:Connect(closeAll)

	return {
		OpenShop = function()
			invModal.Visible = false
			confirmModal.Visible = false
			backdrop.Visible = true
			renderShop()
			UITheme.PopInModal(shopModal)
		end,
		OpenInventory = function()
			shopModal.Visible = false
			confirmModal.Visible = false
			backdrop.Visible = true
			renderInventory()
			updateInspector()
			UITheme.PopInModal(invModal)
		end,
		CloseAll = closeAll,
		UpdateState = function(state: any)
			latestState = state
			if shopModal.Visible then
				renderShop()
			end
			if invModal.Visible then
				renderInventory()
				updateInspector()
			end
		end,
	}
end

return ShopAndInventory
