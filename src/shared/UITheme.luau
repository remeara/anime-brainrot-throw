--!strict
-- BloxRNG Game UI Design System tokens, number formatting, squish micro-interactions, and bouncy modal tweens.

local TweenService = game:GetService("TweenService")

local UITheme = {}

UITheme.Colors = {
	Accent = Color3.fromHex("#FFD200"),
	CashGreen = Color3.fromHex("#10B981"),
	GemPurple = Color3.fromHex("#A855F7"),
	GemBlue = Color3.fromHex("#06B6D4"),
	EnergyBlue = Color3.fromHex("#0EA5E9"),
	HeartRed = Color3.fromHex("#EF4444"),
	LuckGreen = Color3.fromHex("#22C55E"),
	BoostOrange = Color3.fromHex("#F97316"),
	StrokeDark = Color3.fromHex("#0F172A"),
	StrokePill = Color3.fromHex("#1E1B4B"),
	PillNavy = Color3.fromHex("#181A3A"),
	Surface = Color3.fromHex("#0F172A"),
	SurfaceCard = Color3.fromHex("#1E293B"),
	OnSurface = Color3.fromHex("#F8FAFC"),
	Gold = Color3.fromHex("#FBBF24"),
}

UITheme.Fonts = {
	Display = Enum.Font.FredokaOne,
	Body = Enum.Font.FredokaOne,
}

function UITheme.FormatCash(amount: number): string
	if amount >= 1e9 then
		return string.format("$%.2fB", amount / 1e9)
	elseif amount >= 1e6 then
		return string.format("$%.2fM", amount / 1e6)
	elseif amount >= 1e4 then
		return string.format("$%.1fK", amount / 1e3)
	end
	return "$" .. tostring(math.floor(amount))
end

function UITheme.AttachSquish(button: GuiButton, target: GuiObject?)
	local animTarget = target or button
	local scale = animTarget:FindFirstChildOfClass("UIScale")
	if not scale then
		local s = Instance.new("UIScale")
		s.Scale = 1
		s.Parent = animTarget
		scale = s
	end

	local tweenIn = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenOut = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	button.MouseEnter:Connect(function()
		TweenService:Create(scale :: UIScale, tweenIn, { Scale = 1.04 }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(scale :: UIScale, tweenOut, { Scale = 1.0 }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale :: UIScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale :: UIScale, tweenOut, { Scale = 1.04 }):Play()
	end)
end

function UITheme.PopInModal(frame: Frame)
	local scale = frame:FindFirstChildOfClass("UIScale")
	if not scale then
		local s = Instance.new("UIScale")
		s.Scale = 0.9
		s.Parent = frame
		scale = s
	end
	(scale :: UIScale).Scale = 0.9
	frame.Visible = true
	TweenService:Create(scale :: UIScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
end

return UITheme
