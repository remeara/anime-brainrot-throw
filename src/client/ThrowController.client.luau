--!strict
-- Client-side Throw Power Meter (BloxRNG Design System):
-- FredokaOne cartoon-arcade typography, GREAT + SWEET SPOT zones, pulsing glow, squish press, and 3D food arc.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local PetCatalog = require(ReplicatedStorage.Shared.PetCatalog)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local UITheme = require(ReplicatedStorage.Shared.UITheme)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ThrowHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Result Chip above dock
local resultChip = Instance.new("Frame")
resultChip.Size = UDim2.fromOffset(490, 40)
resultChip.Position = UDim2.new(0.5, -245, 1, -174)
resultChip.BackgroundColor3 = UITheme.Colors.PillNavy
resultChip.BackgroundTransparency = 0.08
resultChip.BorderSizePixel = 0
resultChip.Visible = false
resultChip.Parent = gui

Instance.new("UICorner", resultChip).CornerRadius = UDim.new(0, 12)

local rcStroke = Instance.new("UIStroke")
rcStroke.Color = UITheme.Colors.CashGreen
rcStroke.Thickness = 2.5
rcStroke.Parent = resultChip

local rcDot = Instance.new("Frame")
rcDot.Size = UDim2.fromOffset(10, 10)
rcDot.Position = UDim2.new(0, 14, 0.5, -5)
rcDot.BackgroundColor3 = UITheme.Colors.CashGreen
rcDot.BorderSizePixel = 0
rcDot.Parent = resultChip
Instance.new("UICorner", rcDot).CornerRadius = UDim.new(1, 0)

local catchToast = Instance.new("TextLabel")
catchToast.Size = UDim2.new(1, -36, 1, 0)
catchToast.Position = UDim2.fromOffset(32, 0)
catchToast.BackgroundTransparency = 1
catchToast.Font = UITheme.Fonts.Display
catchToast.TextSize = 16
catchToast.TextColor3 = UITheme.Colors.CashGreen
catchToast.TextXAlignment = Enum.TextXAlignment.Left
catchToast.Text = ""
catchToast.Parent = resultChip

-- Main Timing & Launch Action Dock
local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(440, 118)
container.Position = UDim2.new(0.5, -220, 1, -126)
container.BackgroundColor3 = UITheme.Colors.PillNavy
container.BackgroundTransparency = 0.05
container.BorderSizePixel = 0
container.Parent = gui

Instance.new("UICorner", container).CornerRadius = UDim.new(0, 22)

local cStroke = Instance.new("UIStroke")
cStroke.Color = UITheme.Colors.Accent
cStroke.Thickness = 3.5
cStroke.Parent = container

-- Smooth pulsing glow on dock stroke
task.spawn(function()
	while container.Parent do
		TweenService:Create(cStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 4.5 }):Play()
		task.wait(0.9)
		TweenService:Create(cStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Thickness = 3.0 }):Play()
		task.wait(0.9)
	end
end)

-- Precision Timing Gauge Bar
local meterBg = Instance.new("Frame")
meterBg.Size = UDim2.new(1, -24, 0, 30)
meterBg.Position = UDim2.fromOffset(12, 12)
meterBg.BackgroundColor3 = UITheme.Colors.StrokeDark
meterBg.BorderSizePixel = 0
meterBg.ClipsDescendants = true
meterBg.Parent = container

Instance.new("UICorner", meterBg).CornerRadius = UDim.new(0, 10)

local mStroke = Instance.new("UIStroke")
mStroke.Color = UITheme.Colors.StrokePill
mStroke.Thickness = 2.5
mStroke.Parent = meterBg

-- GREAT Zone (68% - 85%)
local greatZone = Instance.new("TextLabel")
greatZone.Size = UDim2.new(0.17, 0, 1, 0)
greatZone.Position = UDim2.new(0.68, 0, 0, 0)
greatZone.BackgroundColor3 = UITheme.Colors.Gold
greatZone.BorderSizePixel = 0
greatZone.Font = UITheme.Fonts.Display
greatZone.TextSize = 11
greatZone.TextColor3 = UITheme.Colors.StrokeDark
greatZone.Text = "GREAT"
greatZone.Parent = meterBg

-- SWEET SPOT Zone (85% - 100%)
local perfectZone = Instance.new("TextLabel")
perfectZone.Size = UDim2.new(0.15, 0, 1, 0)
perfectZone.Position = UDim2.new(0.85, 0, 0, 0)
perfectZone.BackgroundColor3 = UITheme.Colors.LuckGreen
perfectZone.BorderSizePixel = 0
perfectZone.Font = UITheme.Fonts.Display
perfectZone.TextSize = 10
perfectZone.TextColor3 = UITheme.Colors.StrokeDark
perfectZone.Text = "SWEET"
perfectZone.Parent = meterBg

local pzGrad = Instance.new("UIGradient")
pzGrad.Color = ColorSequence.new(Color3.fromHex("#34D399"), UITheme.Colors.LuckGreen)
pzGrad.Parent = perfectZone

-- Sweeping Needle
local needle = Instance.new("Frame")
needle.Size = UDim2.new(0, 12, 1, -4)
needle.Position = UDim2.new(0.5, -6, 0, 2)
needle.BackgroundColor3 = Color3.new(1, 1, 1)
needle.BorderSizePixel = 0
needle.ZIndex = 4
needle.Parent = meterBg
Instance.new("UICorner", needle).CornerRadius = UDim.new(0, 4)

local nStroke = Instance.new("UIStroke")
nStroke.Color = UITheme.Colors.StrokeDark
nStroke.Thickness = 2
nStroke.Parent = needle

-- Big 3D-Bevel Primary Button: THROW FOOD! [F]
local throwLip = Instance.new("Frame")
throwLip.Size = UDim2.new(1, -24, 0, 56)
throwLip.Position = UDim2.fromOffset(12, 50)
throwLip.BackgroundColor3 = Color3.fromHex("#92400E")
throwLip.BorderSizePixel = 0
throwLip.Parent = container
Instance.new("UICorner", throwLip).CornerRadius = UDim.new(0, 16)

local throwBtn = Instance.new("TextButton")
throwBtn.Size = UDim2.new(1, 0, 1, -6)
throwBtn.Position = UDim2.fromOffset(0, 0)
throwBtn.BackgroundColor3 = UITheme.Colors.Accent
throwBtn.BorderSizePixel = 0
throwBtn.Font = UITheme.Fonts.Display
throwBtn.Text = "THROW FOOD! [F]"
throwBtn.TextColor3 = UITheme.Colors.StrokeDark
throwBtn.TextSize = 22
throwBtn.Parent = throwLip
Instance.new("UICorner", throwBtn).CornerRadius = UDim.new(0, 16)

local tbGrad = Instance.new("UIGradient")
tbGrad.Rotation = 90
tbGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("#FDE047")),
	ColorSequenceKeypoint.new(0.5, UITheme.Colors.Accent),
	ColorSequenceKeypoint.new(1, Color3.fromHex("#EAB308")),
})
tbGrad.Parent = throwBtn

UITheme.AttachSquish(throwBtn, throwLip)

local currentRatio = 0.5
local direction = 1
local cooldown = false
local hasteActive = false
local perfectStreak = 0

local comboBadge = Instance.new("TextLabel")
comboBadge.Size = UDim2.fromOffset(118, 28)
comboBadge.Position = UDim2.new(1, -124, 0, -34)
comboBadge.BackgroundColor3 = UITheme.Colors.BoostOrange
comboBadge.Font = UITheme.Fonts.Display
comboBadge.TextSize = 13
comboBadge.TextColor3 = UITheme.Colors.StrokeDark
comboBadge.Text = "STREAK x2!"
comboBadge.Visible = false
comboBadge.Parent = container
Instance.new("UICorner", comboBadge).CornerRadius = UDim.new(1, 0)
local cbStroke = Instance.new("UIStroke")
cbStroke.Color = Color3.new(1, 1, 1)
cbStroke.Thickness = 2
cbStroke.Parent = comboBadge

Remotes.Get(Remotes.EventNames.StateSync).OnClientEvent:Connect(function(state: any)
	hasteActive = (state and state.HasteRemaining and state.HasteRemaining > 0) == true
end)

RunService.RenderStepped:Connect(function(dt: number)
	currentRatio += direction * dt * 1.35
	if currentRatio >= 0.98 then
		currentRatio = 0.98
		direction = -1
	elseif currentRatio <= 0.04 then
		currentRatio = 0.04
		direction = 1
	end
	needle.Position = UDim2.new(currentRatio, -6, 0, 2)
end)

local function doThrow()
	if cooldown then
		return
	end
	cooldown = true
	throwBtn.Position = UDim2.fromOffset(0, 4)

	local aimX = 0
	local char = player.Character
	local hrp = if char then char:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
	if hrp then
		aimX = hrp.Position.X
	end

	Remotes.Get(Remotes.EventNames.ThrowFood):FireServer(currentRatio, aimX)

	task.delay(0.15, function()
		throwBtn.Position = UDim2.fromOffset(0, 0)
	end)
	task.delay(if hasteActive then 0.30 else 0.65, function()
		cooldown = false
	end)
end

throwBtn.MouseButton1Click:Connect(doThrow)

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		doThrow()
	end
end)

-- Animate 3D parabolic food projectile + landing ring
Remotes.Get(Remotes.EventNames.ThrowResult).OnClientEvent:Connect(function(info: any)
	local startPos: Vector3 = info.StartPos
	local landPos: Vector3 = info.LandPos

	local foodPart = Instance.new("Part")
	foodPart.Name = "ThrownFood"
	foodPart.Shape = Enum.PartType.Ball
	foodPart.Size = Vector3.new(2.2, 2.2, 2.2)
	foodPart.Color = info.FoodColor or UITheme.Colors.Accent
	foodPart.Material = Enum.Material.Neon
	foodPart.Anchored = true
	foodPart.CanCollide = false
	foodPart.Position = startPos
	foodPart.Parent = Workspace

	local trail = Instance.new("ParticleEmitter")
	trail.Rate = 40
	trail.Lifetime = NumberRange.new(0.25, 0.45)
	trail.Speed = NumberRange.new(1, 3)
	trail.Color = ColorSequence.new(info.FoodAccent or Color3.new(1, 1, 1))
	trail.Parent = foodPart

	task.spawn(function()
		local duration = 0.65
		local elapsed = 0
		local peakHeight = math.clamp((startPos - landPos).Magnitude * 0.25, 12, 48)
		while elapsed < duration do
			elapsed += RunService.RenderStepped:Wait()
			local alpha = math.min(1, elapsed / duration)
			local flat = startPos:Lerp(landPos, alpha)
			local arcY = 4 * peakHeight * alpha * (1 - alpha)
			foodPart.Position = Vector3.new(flat.X, flat.Y + arcY, flat.Z)
		end

		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(0.3, 4, 4)
		ring.CFrame = CFrame.new(landPos) * CFrame.Angles(0, 0, math.rad(90))
		ring.Color = if info.IsPerfect then UITheme.Colors.CashGreen else (info.FoodColor or Color3.new(1, 1, 1))
		ring.Material = Enum.Material.Neon
		ring.Anchored = true
		ring.CanCollide = false
		ring.Transparency = 0.2
		ring.Parent = Workspace

		TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.3, 24, 24),
			Transparency = 1,
		}):Play()
		task.delay(0.5, function()
			ring:Destroy()
		end)
		foodPart:Destroy()
	end)

	if info.ThrowerUserId == player.UserId then
		local cam = Workspace.CurrentCamera
		if cam and cam.CameraType == Enum.CameraType.Custom then
			local baseFov = 70
			TweenService:Create(cam, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = if info.IsPerfect then 79 else 74 }):Play()
			task.delay(0.16, function()
				TweenService:Create(cam, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = baseFov }):Play()
			end)
		end

		if info.IsPerfect then
			perfectStreak += 1
		else
			perfectStreak = 0
		end
		if perfectStreak >= 2 then
			comboBadge.Text = "STREAK x" .. tostring(perfectStreak) .. "!"
			comboBadge.Visible = true
		else
			comboBadge.Visible = false
		end

		-- Rising anime rarity light pillar at landing spot for Rare+ catches!
		if info.Rarity ~= "Common" then
			task.delay(0.62, function()
				local rarInfo = PetCatalog.Rarities[info.Rarity] or PetCatalog.Rarities.Common
				local beam = Instance.new("Part")
				beam.Shape = Enum.PartType.Cylinder
				beam.Size = Vector3.new(42, 4, 4)
				beam.CFrame = CFrame.new(landPos + Vector3.new(0, 21, 0)) * CFrame.Angles(0, 0, math.rad(90))
				beam.Color = rarInfo.Color
				beam.Material = Enum.Material.Neon
				beam.Anchored = true
				beam.CanCollide = false
				beam.Transparency = 0.35
				beam.Parent = Workspace
				TweenService:Create(beam, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(52, 0.2, 0.2),
					Transparency = 1,
				}):Play()
				task.delay(0.75, function()
					beam:Destroy()
				end)
			end)
		end

		local rar = PetCatalog.Rarities[info.Rarity] or PetCatalog.Rarities.Common
		local perf = if info.IsPerfect then "PERFECT! " else ""
		local mut = if info.Mutation ~= "Normal" then ("[" .. info.Mutation .. "] ") else ""
		catchToast.Text = perf .. tostring(info.Distance) .. "m • " .. mut .. info.PetName .. " (" .. rar.Name .. ")"
		catchToast.TextColor3 = rar.Color
		rcStroke.Color = rar.Color
		rcDot.BackgroundColor3 = rar.Color
		UITheme.PopInModal(resultChip)
		task.delay(3.0, function()
			resultChip.Visible = false
		end)
	end
end)
