local Players,RS,Run,Tw,UIS,WS=game:GetService("Players"),game:GetService("ReplicatedStorage"),game:GetService("RunService"),game:GetService("TweenService"),game:GetService("UserInputService"),game:GetService("Workspace")
local rem=require(RS:WaitForChild("Shared"):WaitForChild("Remotes")).Get()
local plr,I,c3,v3,cf,ang,mr,ti,E=Players.LocalPlayer,Instance.new,Color3.fromRGB,Vector3.new,CFrame.new,CFrame.Angles,math.rad,TweenInfo.new,Enum
local fx=I("ScreenGui",plr:WaitForChild("PlayerGui")) fx.Name,fx.ResetOnSpawn,fx.IgnoreGuiInset="StationFX",false,true
local shOn,trOn,KC=false,false,E.KeyCode
local function part(p,sz,col,mat) local x=I("Part",p) x.Size,x.Color,x.Material,x.CanCollide,x.Anchored=sz,col or c3(255,255,255),mat or E.Material.SmoothPlastic,false,true return x end
local function swingMallet(hold)
	local ch=plr.Character local hrp=ch and ch:FindFirstChild("HumanoidRootPart") if not ch or not hrp then return end
	local old=ch:FindFirstChild("ConductorMallet") if old then old:Destroy() end
	local m=I("Model",ch) m.Name="ConductorMallet"
	local h,hd=part(m,v3(.3,3.4,.3),c3(118,66,32),E.Material.Wood),part(m,v3(1.3,1.1,2.1),c3(242,183,5),E.Material.Metal) h.Massless,hd.Massless=true,true
	task.spawn(function()
		local function ps(rx,y) local b=hrp.CFrame*cf(1.85,y,-1.7)*ang(mr(rx),0,mr(-22)) h.CFrame,hd.CFrame=b,b*cf(0,1.75,0) end
		if hold then ps(65,.4) task.wait(hold) else for s=0,10 do if not hrp.Parent then break end ps(-45+s*14,.5) task.wait(.025) end end m:Destroy()
	end)
end
local function tw(o,d,s,p) Tw:Create(o,ti(d,s),p):Play() task.delay(d+.08,function() o:Destroy() end) end
local function popup(pos,txt,col,life)
	local a=part(WS,v3(.5,.5,.5)) a.Position,a.Transparency=pos,1
	local bb=I("BillboardGui",a) bb.Size,bb.AlwaysOnTop,bb.Adornee=UDim2.fromOffset(180,48),true,a
	local l=I("TextLabel",bb) l.Size,l.BackgroundTransparency,l.Font,l.Text,l.TextColor3,l.TextSize=UDim2.fromScale(1,1),1,E.Font.GothamBlack,txt,col,24
	local st=I("UIStroke",l) st.Thickness,st.Color=2.5,c3(24,6,12)
	tw(a,life or 1.2,E.EasingStyle.Quad,{Position=pos+v3(0,4.2,0)})
end
local function ticket(sy)
	local tk=I("Frame",fx) tk.Size,tk.Position,tk.Rotation,tk.BackgroundColor3,tk.BackgroundTransparency,tk.BorderSizePixel=UDim2.fromOffset(18,10),UDim2.new(math.random(6,94)/100,0,sy or -.04,0),math.random(-28,28),c3(255,216,58),.15,0
	I("UICorner",tk).CornerRadius=UDim.new(0,2) local st=I("UIStroke",tk) st.Color,st.Thickness=c3(142,86,12),1
	tw(tk,2.2,E.EasingStyle.Linear,{Position=UDim2.new(tk.Position.X.Scale,0,1.04,0),Rotation=tk.Rotation+90})
end
rem.ToastFeed.OnClientEvent:Connect(function(p) if typeof(p)=="table" and p.worldPos then if p.kind=="bonk" then swingMallet(p.hold) popup(p.worldPos,p.text,c3(255,214,54),p.life or 2.8) elseif p.kind=="cash" then popup(p.worldPos+v3(0,2,0),p.text,c3(64,245,148),1.3) end end end)
local function setEv(ev) local w=shOn shOn,trOn=ev~=nil and ev.kind=="shower",ev~=nil and ev.kind=="train" if shOn and not w then for _=1,8 do ticket(math.random(12,65)/100) end end end
rem.EventBanner.OnClientEvent:Connect(setEv) rem.StateSync.OnClientEvent:Connect(function(s) setEv(s.eventBanner) end)
plr:GetAttributeChangedSignal("SwingMallet"):Connect(function() swingMallet() end)
plr:GetAttributeChangedSignal("TourMalletPose"):Connect(function() swingMallet(14) end)
local keys={[KC.L]=function() rem.LockPlatformGate:FireServer() end,[KC.F]=function() swingMallet() rem.WhackThief:FireServer() end,[KC.U]=function() plr:SetAttribute("ToggleModal","upgrades") end,[KC.R]=function() rem.PerformRebirth:FireServer() end,[KC.B]=function() plr:SetAttribute("ToggleModal","stampbook") end}
UIS.InputBegan:Connect(function(inp,pr) local f=not pr and keys[inp.KeyCode] if f then f() end end)
task.spawn(function() while true do task.wait(.28) if shOn then ticket() end end end)
Run.RenderStepped:Connect(function() if trOn and WS.CurrentCamera then local t=os.clock()*28 WS.CurrentCamera.CFrame*=cf(math.sin(t)*.05,math.cos(t*1.3)*.05,0) end end)
