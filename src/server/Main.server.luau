local Players,RS,Run=game:GetService("Players"),game:GetService("ReplicatedStorage"),game:GetService("RunService")
local Rem=require(RS:WaitForChild("Shared"):WaitForChild("Remotes"))
local Eco,Heist,Plat,Ev,World,Tour=require(script.Parent.EconomyState),require(script.Parent.HeistAndThiefService),require(script.Parent.PlatformService),require(script.Parent.RunawayTrainEvent),require(script.Parent.StationWorld),require(script.Parent.TourShowcase)

local world=World.Build() local parade=Instance.new("Folder",world.Root) parade.Name="Parade" local rem=Rem.Get()
Plat.Init(world,parade) Heist.Init(world) Ev.Init(world,parade) Tour.Init(world)
local bf=Instance.new("BindableFunction",script.Parent) bf.Name,bf.OnInvoke="_TourApply",Tour.ApplyScene
local function syncP(st) Plat.ApplyPlayerSpeed(st) Plat.RefreshPadVisuals(st) Eco.SyncClient(st) end
local function onJoin(p)
	local st=Eco.InitPlayer(p)
	p.CharacterAdded:Connect(function() task.wait(.1) local h=Eco.HRP(p) if h then h.CFrame=world.SpawnCF end syncP(st) end)
	if p.Character then syncP(st) else Eco.SyncClient(st) end
end
Players.PlayerAdded:Connect(onJoin) for _,p in ipairs(Players:GetPlayers()) do task.spawn(onJoin,p) end Players.PlayerRemoving:Connect(Eco.Remove)

local function str(r,f) r.OnServerEvent:Connect(function(p,a) if typeof(a)=="string" then f(p,a) end end) end
str(rem.BuyParadeBrainrot,Plat.TryBuyParade) str(rem.BuyUpgrade,Plat.BuyUpgrade) str(rem.ClaimQuest,Plat.ClaimQuest)
str(rem.TriggerTourScene,function(_,s) Tour.ApplyScene(s) end)
rem.StealRivalBrainrot.OnServerEvent:Connect(function(p,w,i) if typeof(w)=="string" and typeof(i)=="number" then Heist.StealRival(p,w,i) end end)
rem.BankCarried.OnServerEvent:Connect(function(p,i) Plat.BankCarried(p,typeof(i)=="number" and i or nil) end)
rem.CollectPadCash.OnServerEvent:Connect(function(p,i) Plat.CollectPadCash(p,typeof(i)=="number" and i or 0) end)
rem.WhackThief.OnServerEvent:Connect(Heist.WhackThief) rem.LockPlatformGate.OnServerEvent:Connect(Plat.LockGate) rem.PerformRebirth.OnServerEvent:Connect(Plat.PerformRebirth)

local tA,sA,thA=0,0,0
Run.Heartbeat:Connect(function(dt)
	tA+=dt if tA>=.08 then local s=tA tA=0 if not Tour.IsActive then Plat.Tick(s) Heist.Tick(s) Ev.Tick(s) end end
	thA+=dt if thA>=11 and not Tour.IsActive then thA=0 Heist.SpawnThief() end
	sA+=dt if sA>=.5 then sA=0 for _,st in pairs(Eco.All()) do Eco.SyncClient(st) end end
end)
