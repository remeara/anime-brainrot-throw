local Players,Sh=game:GetService("Players"),game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cat,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("Remotes"))
local Eco,Heist,Plat,Ev=require(script.Parent.EconomyState),require(script.Parent.HeistAndThiefService),require(script.Parent.PlatformService),require(script.Parent.RunawayTrainEvent)
local Tour,wRef,v3,cf,ang,mr={IsActive=false},nil,Vector3.new,CFrame.new,CFrame.Angles,math.rad
function Tour.Init(w) wRef=w end
local function setProf(st)
	st.cash,st.rebirths,st.rebirthMult,st.upgrades=84.6e6,3,4,{sprint=6,mallet=6,lock=5,magnet=6,luck=5}
	for i,r in ipairs(Cat.GetShowcaseLoadout()) do st.pads[i]={characterId=r.charId,mutationId=r.mutId,storedCash=r.stored} end
	st.discovered={} for i=1,44 do st.discovered[Cat.CHARACTERS[i].id]=i>39 and "chrono" or i>32 and "prism" or i>24 and "crystal" or i>16 and "neon" or i>8 and "brass" or "normal" end
	st.questClaimed={} for i=1,11 do st.questClaimed["q"..i]=true end
	st.questProgress={buys=24,locks=8,collects=40,whacks=9,steals=5,trains=4,upgrades=28,pads=12,stamps=44,mutated=18,rebirths=3,chrono=3}
	Eco.RefreshActiveQuests(st) Eco.RecalcIncome(st) Plat.ApplyPlayerSpeed(st)
end
local function mv(st,c) local h=Eco.HRP(st.player) if h then h.AssemblyLinearVelocity,h.CFrame=v3(),c end end
local function tt(t,tn) return {text=t,tone=tn} end
local SC={
	cover={lk=36,sh=18,pos={-16.5,3.2,8,-115},th={{-7.5,0,14,"Pickpocket Pigeon"}},ts={tt("Banked GoldenTicket EmperorRex [Brass]!","gold"),tt("Turnstile LOCKED · Repelled Thief!","emerald"),tt("GOLDEN TICKET SHOWER! All mutated!","gold")}},
	heist={lk=0,sh=16,car={"orientexp","chrono","rival"},pos={-5.2,3.2,8,58},th={{-.2,0,4,"Pickpocket Pigeon"},{5.5,0,10,"Stowaway Raccoon"}},mal=true,ts={tt("HEIST! Stole OrientExpress -> DROP MAT!","crimson"),tt("BONK! Whacked Thief +$65.0K!","emerald"),tt("Rival Conductor OPEN · Grab & Dash!","gold")}},
	stampbook={lk=42,sh=18,mod="stampbook",pos={-19.5,3.2,2,-90},ts={tt("Stamp Book: 44/48 Discovered (91.7%)!","gold")}},
	locomotive={lk=28,tr=true,car={"diamondtracko","prism","parade"},pos={-12.2,3.2,13.5,112},th={{11.5,0,16,"Stowaway Raccoon"}},ts={tt("RUNAWAY EXPRESS! GET OFF TRACKS!","crimson"),tt("Carrying DiamondTracko -> DROP MAT!","gold"),tt("Sprinting to VIP Platform!","emerald")}},
}
function Tour.ApplyScene(name)
	if not wRef then local bf=script.Parent:FindFirstChild("_TourApply") return (bf and bf:IsA("BindableFunction")) and bf:Invoke(name) or "no world" end
	local k=string.lower(tostring(name or "cover")) if k=="resume" then Tour.IsActive=false return "resumed" end
	local d=SC[k] or SC.cover Tour.IsActive=true Heist.ClearThieves() Ev.ClearParade()
	local pr=k=="locomotive" and {{"godpigeon","chrono",-42},{"saxophono","neon",34}} or k=="heist" and {{"godpigeon","chrono",-32},{"orientexp","prism",-18},{"bullettraino","brass",28}} or {{"godpigeon","chrono",-34},{"orientexp","prism",-18},{"saxophono","neon",-4},{"turbosteam","crystal",10},{"bullettraino","brass",24}}
	for _,p in ipairs(pr) do Ev.SpawnParadeCreature(p[1],p[2],p[3]) end
	wRef.Rivals.north.locked,wRef.Rivals.north.timer=false,38 Heist.RefreshRivals()
	for _,t in ipairs(d.th or {}) do Heist.SpawnThief(v3(t[1],t[2],t[3]),t[4]) end
	if d.tr then Ev.StartRunawayExpress(14,-4) else Ev.StartGoldenShower(d.sh) end
	for _,plr in ipairs(Players:GetPlayers()) do local st=Eco.Get(plr) if st then
		setProf(st) Plat.ClearCarriedVisual(plr)
		st.lockSeconds,st.tourOpenModal,st.toasts=d.lk,d.mod,d.ts
		mv(st,cf(d.pos[1],d.pos[2],d.pos[3])*ang(0,mr(d.pos[4]),0))
		if d.car then st.carried={characterId=d.car[1],mutationId=d.car[2],origin=d.car[3]} Plat.AttachCarriedVisual(plr,d.car[1],d.car[2]) else st.carried=nil end
		if d.mal then plr:SetAttribute("TourMalletPose",os.clock()) Rem.Get().ToastFeed:FireClient(plr,{kind="bonk",text="BONK! +$65.0K",worldPos=v3(-.2,5.6,4),hold=14,life=14}) end
		Plat.RefreshPadVisuals(st) Eco.SyncClient(st)
	end end
	return "applied:"..k
end
return Tour
