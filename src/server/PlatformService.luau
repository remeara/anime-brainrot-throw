local Players,Sh=game:GetService("Players"),game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cat,Rig,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("CreatureRig")),require(Sh:WaitForChild("Remotes"))
local Eco=require(script.Parent.EconomyState)
local Plat,wR,pR,tDb,sf,c3,I={},nil,nil,{},string.format,Color3.fromRGB,Instance.new
local FM,FR,GC,GM,BM,g,sy=Cat.FormatMoney,Cat.FormatRate,Cat.GetCharacter,Cat.GetMutation,Eco.BumpMetric,Eco.Get,Eco.SyncClient
local function tpl(h) return Players:GetPlayerFromCharacter(h.Parent) or (h.Parent and Players:GetPlayerFromCharacter(h.Parent.Parent)) end
local function tell(st,m,t) Eco.AddToast(st,m,t) sy(st) end
local function fail(st,m,t) Eco.AddToast(st,m,t or "crimson") end
local function fin(st,m,t) Eco.RecalcIncome(st) Plat.RefreshPadVisuals(st) tell(st,m,t) end
local function pRate(st,pd) return Cat.ComputeIncome(pd.characterId,pd.mutationId,st.rebirthMult,st.upgrades.magnet or 0) end
local function gtxt(l) return l>0 and sf("TURNSTILE LOCKED · %ds",math.ceil(l)) or "TURNSTILE OPEN · [L] LOCK" end
function Plat.ClearCarriedVisual(p) local o=p.Character and p.Character:FindFirstChild("CarriedBrainrotRig") if o then o:Destroy() end end
function Plat.AttachCarriedVisual(p,c,m)
	Plat.ClearCarriedVisual(p) local ch=p.Character local hd=ch and ch:FindFirstChild("Head") if not ch or not hd then return end
	local r=Rig.BuildCreature(c,m,hd.CFrame*CFrame.new(0,2.75,0),{anchored=false,scale=.78,hideGui=true}) r.Name,r.Parent="CarriedBrainrotRig",ch
	if r.PrimaryPart then local w=I("WeldConstraint",r.PrimaryPart) w.Part0,w.Part1=hd,r.PrimaryPart end
end
function Plat.ApplyPlayerSpeed(st) local h=st.player.Character and st.player.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=18+(st.upgrades.sprint or 0)*2.5 end end
function Plat.RefreshPadVisuals(st)
	local w=wR if not w then return end
	for i,s in ipairs(w.PlayerPads) do
		local pd=st.pads[i] if s.creatureModel then s.creatureModel:Destroy() s.creatureModel=nil end
		if pd and pd.characterId then
			local m=Rig.BuildCreature(pd.characterId,pd.mutationId,s.spawnCF,{anchored=true,scale=1.2,rateText=FR(pRate(st,pd))})
			m.Name,m.Parent="PedCreature_"..i,w.Root s.creatureModel=m s.cashLabel.Text,s.cashPad.Color=FM(pd.storedCash),c3(25,185,108)
		else s.cashLabel.Text,s.cashPad.Color="OPEN PAD",c3(48,72,62) end
	end
	local l=st.lockSeconds>0 for _,b in ipairs(w.GateLasers) do b.Transparency,b.Color=l and .1 or .88,l and c3(48,245,152) or c3(160,148,122) end
	w.GateStatusLabel.Text,w.GateStatusLabel.TextColor3=gtxt(st.lockSeconds),l and c3(84,248,162) or c3(255,226,98)
end
function Plat.CollectPadCash(p,idx)
	local st,w=g(p),wR if not st or not w then return end local got,pop,wp=0,nil,w.PlayerPads
	for i,pd in ipairs(st.pads) do if (idx==0 or idx==i) and pd.storedCash>=1 then got+=math.floor(pd.storedCash) pd.storedCash=0 wp[i].cashLabel.Text,pop="$0",wp[i].cashPad.Position end end
	if got>0 then st.cash+=got BM(st,"collects",1) Rem.Get().ToastFeed:FireClient(p,{kind="cash",text="+"..FM(got),worldPos=pop}) sy(st) end
end
function Plat.BankCarried(p,pref)
	local st=g(p) if not st or not st.carried then return end
	local idx=(pref and st.pads[pref] and not st.pads[pref].characterId) and pref or nil
	if not idx then local mr=math.huge for i,pd in ipairs(st.pads) do if not pd.characterId then idx=i break end local r=pRate(st,pd) if r<mr then mr,idx=r,i end end end
	local c=st.carried st.carried=nil Plat.ClearCarriedVisual(p) st.pads[idx].characterId,st.pads[idx].mutationId=c.characterId,c.mutationId
	Eco.RecordDiscovery(st,c.characterId,c.mutationId) BM(st,"pads",0,Eco.CountPads(st))
	if c.mutationId~="normal" then BM(st,"mutated",1) end if c.mutationId=="chrono" then BM(st,"chrono",1) end
	fin(st,sf("Banked %s [%s] #%d!",GC(c.characterId).name,GM(c.mutationId).name,idx),"emerald")
end
function Plat.TryBuyParade(p,pid)
	local st=g(p) if not st or not pR then return end if st.carried then return fail(st,"Hands full! Go to DROP MAT!") end
	local n=pR:FindFirstChild(pid) if not n or not n:IsA("Model") or not n.PrimaryPart then return end
	local hrp=Eco.HRP(p) if hrp and (hrp.Position-n.PrimaryPart.Position).Magnitude>26 then return fail(st,"Move closer to Track!","gold") end
	local cid,mid,cost=n:GetAttribute("CharId"),n:GetAttribute("MutId"),n:GetAttribute("Cost")
	if st.cash<cost then return fail(st,"Need "..FM(cost).."!") end
	st.cash-=cost n:Destroy() st.carried={characterId=cid,mutationId=mid,origin="parade"} Plat.AttachCarriedVisual(p,cid,mid) BM(st,"buys",1)
	tell(st,"Bought "..GC(cid).name.."! -> DROP MAT!","emerald")
end
function Plat.LockGate(p) local st=g(p) if not st then return end local dur=45+(st.upgrades.lock or 0)*6 st.lockSeconds=dur BM(st,"locks",1) Plat.RefreshPadVisuals(st) tell(st,sf("Turnstile LOCKED %ds!",dur),"emerald") end
function Plat.BuyUpgrade(p,tid)
	local st,inf=g(p),Cat.UPGRADES_BY_ID[tid] if not st or not inf then return end
	local cur=st.upgrades[tid] or 0 if cur>=inf.maxLevel then return fail(st,inf.name.." maxed!","gold") end
	local cost=Cat.GetUpgradeCost(tid,cur) if st.cash<cost then return fail(st,"Need "..FM(cost)) end
	st.cash-=cost st.upgrades[tid]=cur+1 BM(st,"upgrades",1) Plat.ApplyPlayerSpeed(st) fin(st,sf("%s Lv.%d!",inf.name,cur+1),"emerald")
end
function Plat.PerformRebirth(p)
	local st=g(p) if not st then return end local req=math.floor(5e4*(4^st.rebirths))
	if st.cash<req then return fail(st,"Need "..FM(req).." to Rebirth!") end
	st.rebirths+=1 st.rebirthMult=st.rebirths+1 st.cash,st.carried,st.pads=1500,nil,Eco.MakeStarterPads() Plat.ClearCarriedVisual(p)
	BM(st,"rebirths",0,st.rebirths) BM(st,"pads",0,2) fin(st,sf("REBIRTH %d! Permanent x%d!",st.rebirths,st.rebirthMult),"gold")
end
function Plat.ClaimQuest(p,qid)
	local st=g(p) if not st or st.questClaimed[qid] then return end
	for _,q in ipairs(Cat.QUESTS) do if q.id==qid and (st.questProgress[q.metric] or 0)>=q.target then st.questClaimed[qid]=true st.cash+=q.reward Eco.RefreshActiveQuests(st) tell(st,"Quest Done! +"..FM(q.reward),"emerald") break end end
end
function Plat.Init(w,p)
	wR,pR=w,p local function ot(pt,cd,fn) pt.Touched:Connect(function(h) local pl=tpl(h) if not pl then return end local nw=os.clock() if tDb[pl.UserId] and nw-tDb[pl.UserId]<cd then return end tDb[pl.UserId]=nw fn(pl) end) end
	ot(w.DropMat,.45,function(pl) local st=g(pl) if st and st.carried then Plat.BankCarried(pl,nil) end end)
	for i,s in ipairs(w.PlayerPads) do ot(s.cashPad,.35,function(pl) Plat.CollectPadCash(pl,i) end) end
end
function Plat.Tick(dt)
	local w=wR if not w then return end
	for _,st in pairs(Eco.All()) do
		local drt=false if st.lockSeconds>0 then st.lockSeconds=math.max(0,st.lockSeconds-dt) drt=true end
		for i,pd in ipairs(st.pads) do if pd.characterId then pd.storedCash+=pRate(st,pd)*dt if w.PlayerPads[i] then w.PlayerPads[i].cashLabel.Text=FM(pd.storedCash) end end end
		if drt then if st.lockSeconds<=0 then Plat.RefreshPadVisuals(st) else w.GateStatusLabel.Text=gtxt(st.lockSeconds) end end
	end
end
return Plat
