local Players,Sh=game:GetService("Players"),game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cat,Rig,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("CreatureRig")),require(Sh:WaitForChild("Remotes"))
local Eco,Plat=require(script.Parent.EconomyState),require(script.Parent.PlatformService)
local Ev,wRef,pRef,I,cf,ang,v3,c3,mr={},nil,nil,Instance.new,CFrame.new,CFrame.Angles,Vector3.new,Color3.fromRGB,math.rad
local nId,sAcc,cAcc,cTog,shSec,trSec,trDur,locoZ,frozen,kCd=0,0,0,false,0,0,14,-58,false,{}
local FM,FR=Cat.FormatMoney,Cat.FormatRate
local function banner(k,t,s) local p=k and t and {kind=k,title=t,secondsLeft=math.ceil(s or 0)} or nil for _,st in pairs(Eco.All()) do st.eventBanner=p end Rem.Get().EventBanner:FireAllClients(p) end
function Ev.SpawnParadeCreature(cid,mid,zO)
	if not pRef then return end local luck=0 for _,st in pairs(Eco.All()) do luck=math.max(luck,st.upgrades.luck or 0) end
	local ch,mut if cid and mid then ch,mut=Cat.GetCharacter(cid),Cat.GetMutation(mid) else ch,mut=Cat.PickRandomParade(luck,shSec>0) end
	nId+=1 local cost,z=math.floor(ch.cost*math.max(1,mut.mult*.6)),zO or -54
	local m=Rig.BuildCreature(ch.id,mut.id,cf(0,-.35,z)*ang(0,mr(180),0),{anchored=true,scale=1.2,rateText=FR(ch.income*mut.mult),tagText="BUY "..FM(cost).." [E]"})
	m.Name="Parade_"..nId m:SetAttribute("CharId",ch.id) m:SetAttribute("MutId",mut.id) m:SetAttribute("Cost",cost) m:SetAttribute("PosZ",z) m.Parent=pRef
	if m.PrimaryPart then
		local pr=I("ProximityPrompt",m.PrimaryPart) pr.ActionText,pr.ObjectText,pr.KeyboardKeyCode,pr.MaxActivationDistance,pr.HoldDuration="Buy "..FM(cost),ch.name,Enum.KeyCode.E,14,0
		pr.Triggered:Connect(function(plr) Plat.TryBuyParade(plr,m.Name) end)
	end
end
function Ev.ClearParade() if pRef then pRef:ClearAllChildren() end end
function Ev.SetLocomotiveZ(z) if wRef then locoZ=z wRef.Locomotive:PivotTo(cf(0,0,z)) end end
function Ev.StartGoldenShower(d) trSec,frozen,shSec=0,false,d or 18 Ev.SetLocomotiveZ(-68) banner("shower","GOLDEN TICKET SHOWER! EVERY BRAINROT IS MUTATED",shSec) end
function Ev.StartRunawayExpress(d,fz) shSec,trSec,trDur=0,d or 14,d or 14 frozen=fz~=nil Ev.SetLocomotiveZ(fz or -64) banner("train","ALERT: RUNAWAY EXPRESS! GET OFF THE TRACKS!",trSec) end
function Ev.Init(w,p) wRef,pRef=w,p Ev.SetLocomotiveZ(-66) Ev.SpawnParadeCreature("pigeoncini","normal",-36) Ev.SpawnParadeCreature("croissantini","brass",-18) Ev.SpawnParadeCreature("saxophono","neon",2) end
local g,AT=Eco.Get,Eco.AddToast
function Ev.Tick(dt)
	if not wRef or not pRef then return end
	for _,n in ipairs(pRef:GetChildren()) do if n:IsA("Model") then local z=n:GetAttribute("PosZ")+6.8*dt if z>52 then n:Destroy() else n:SetAttribute("PosZ",z) n:PivotTo(cf(0,-.35,z)*ang(0,mr(180),0)) end end end
	sAcc+=dt if sAcc>=2.8 and #pRef:GetChildren()<9 then sAcc=0 Ev.SpawnParadeCreature() end
	if shSec>0 then shSec=math.max(0,shSec-dt) if shSec<=0 then banner() end
	elseif trSec>0 then
		trSec=math.max(0,trSec-dt) if not frozen then Ev.SetLocomotiveZ(-64+(1-trSec/math.max(1,trDur))*134) end
		local fl=math.floor(os.clock()*6)%2==0 for _,b in ipairs(wRef.WarningLights) do b.Color=fl and c3(255,42,42) or c3(112,18,18) end
		for _,plr in ipairs(Players:GetPlayers()) do
			local hrp=Eco.HRP(plr) if hrp and math.abs(hrp.Position.X)<8.5 and math.abs(hrp.Position.Z-locoZ)<16 then
				local nw=os.clock() if not kCd[plr.UserId] or nw-kCd[plr.UserId]>1.5 then
					kCd[plr.UserId]=nw hrp.AssemblyLinearVelocity=v3(hrp.Position.X<0 and -52 or 52,34,14)
					local st=g(plr) if st then AT(st,"WHOA! Tossed clear of Express!","crimson") end
				end
			end
		end
		if trSec<=0 then
			frozen=false Ev.SetLocomotiveZ(-68) for _,b in ipairs(wRef.WarningLights) do b.Color=c3(180,40,40) end
			for _,st in pairs(Eco.All()) do Eco.BumpMetric(st,"trains",1) AT(st,"Survived Runaway Express! +$25.0K!","emerald") st.cash+=25e3 end banner()
		end
	else cAcc+=dt if cAcc>=32 then cAcc,cTog=0,not cTog if cTog then Ev.StartGoldenShower(18) else Ev.StartRunawayExpress(14) end end end
end
return Ev
