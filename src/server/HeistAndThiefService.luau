local Sh=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cat,Rig,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("CreatureRig")),require(Sh:WaitForChild("Remotes"))
local Eco,Plat=require(script.Parent.EconomyState),require(script.Parent.PlatformService)
local Heist,thieves,thiefF,rData,wRef,nId,c3,sf,I,v3,cf,ang,mr={},{},nil,{north={},south={}},nil,0,Color3.fromRGB,string.format,Instance.new,Vector3.new,CFrame.new,CFrame.Angles,math.rad
local FM,GC,AT,BM,g,sy=Cat.FormatMoney,Cat.GetCharacter,Eco.AddToast,Eco.BumpMetric,Eco.Get,Eco.SyncClient
local function wlbl(wk,wg) wg.statusLabel.Text=(wk=="north" and "RIVAL CONDUCTOR · " or "RIVAL BARON'S VAULT · ")..(wg.locked and sf("[LOCKED %ds]",math.ceil(wg.timer)) or "[OPEN - STEAL!]") end
local function refreshWing(wk)
	local w=wRef if not w then return end local wg=w.Rivals[wk]
	for i,s in ipairs(wg.slots) do
		if s.creatureModel then s.creatureModel:Destroy() s.creatureModel=nil end
		local inf=rData[wk][i] if inf and inf.cooldown<=0 then
			local m=Rig.BuildCreature(inf.charId,inf.mutId,s.spawnCF,{anchored=true,scale=1.2,tagText=wg.locked and "VAULT LOCKED" or "STEAL [E]",tagColor=wg.locked and c3(244,86,86) or c3(255,214,62)})
			m.Name,m.Parent="Rival_"..wk..i,w.Root
			if not wg.locked and m.PrimaryPart then
				local pr=I("ProximityPrompt",m.PrimaryPart) pr.ActionText,pr.ObjectText,pr.KeyboardKeyCode,pr.MaxActivationDistance,pr.HoldDuration="Steal",GC(inf.charId).name,Enum.KeyCode.E,12,0
				pr.Triggered:Connect(function(p) Heist.StealRival(p,wk,i) end)
			end
			s.creatureModel=m
		end
	end
	for _,b in ipairs(wg.lasers) do b.Transparency=wg.locked and .14 or .9 end wlbl(wk,wg)
end
function Heist.RefreshRivals() for _,wk in ipairs({"north","south"}) do for _,sd in ipairs(rData[wk]) do sd.cooldown=0 end refreshWing(wk) end end
function Heist.Init(w) wRef,thiefF=w,I("Folder",w.Root) thiefF.Name="ActiveThieves" for _,wk in ipairs({"north","south"}) do rData[wk]={} for i,it in ipairs(Cat.GetRivalLoadout(wk)) do rData[wk][i]={charId=it.charId,mutId=it.mutId,cooldown=0} end refreshWing(wk) end end
function Heist.StealRival(p,wk,idx)
	local w,st=wRef,g(p) if not w or not st then return end local wg=w.Rivals[wk]
	if wg.locked then return AT(st,"Rival Vault LOCKED!","crimson") end
	if st.carried then return AT(st,"Hands full! Go to DROP MAT!","crimson") end
	local sd,ws=rData[wk][idx],wg.slots[idx] if not sd or sd.cooldown>0 or not ws then return end
	local hrp=Eco.HRP(p) if hrp and (hrp.Position-ws.pedestal.Position).Magnitude>22 then return AT(st,"Move closer to steal!","gold") end
	sd.cooldown=18 refreshWing(wk) st.carried={characterId=sd.charId,mutationId=sd.mutId,origin="rival"}
	Plat.AttachCarriedVisual(p,sd.charId,sd.mutId) BM(st,"steals",1) AT(st,"HEIST! Stole "..GC(sd.charId).name.." -> DROP MAT!","gold") sy(st)
end
function Heist.SpawnThief(posO,kindO)
	if not thiefF or #thieves>=3 then return end nId+=1
	local k,pos=kindO or (nId%2==1 and "Pickpocket Pigeon" or "Stowaway Raccoon"),posO or v3(math.random(-6,6),0,math.random(-20,20))
	local m=Rig.BuildThief(k,cf(pos)*ang(0,mr(90),0)) m.Parent=thiefF table.insert(thieves,{id="t"..nId,kind=k,model=m,pos=pos,fleeing=false})
end
function Heist.ClearThieves() for _,t in ipairs(thieves) do t.model:Destroy() end table.clear(thieves) end
function Heist.WhackThief(p)
	local st,hrp=g(p),Eco.HRP(p) if not st or not hrp then return end
	local rch,bi,bd=15+(st.upgrades.mallet or 0)*2.5,nil,math.huge
	for i,t in ipairs(thieves) do local d=(v3(t.pos.X,hrp.Position.Y,t.pos.Z)-hrp.Position).Magnitude if d<=rch and d<bd then bd,bi=d,i end end
	if not bi then return AT(st,"Move near a thief and press [F]!","gold") end
	local hit=table.remove(thieves,bi) local hp=hit.pos hit.model:Destroy()
	local bn=math.floor(65e3*(1+(st.upgrades.mallet or 0)*.25)) st.cash+=bn BM(st,"whacks",1) AT(st,sf("BONK! Whacked %s +%s!",hit.kind,FM(bn)),"emerald")
	Rem.Get().ToastFeed:FireClient(p,{kind="bonk",text="BONK! +"..FM(bn),worldPos=hp+v3(0,3.6,0)}) sy(st)
end
function Heist.Tick(dt)
	local w=wRef if not w then return end
	for _,wk in ipairs({"north","south"}) do
		local wg,drt=w.Rivals[wk],false wg.timer-=dt if wg.timer<=0 then wg.locked=not wg.locked wg.timer=45 drt=true end
		for _,sd in ipairs(rData[wk]) do if sd.cooldown>0 then sd.cooldown=math.max(0,sd.cooldown-dt) if sd.cooldown<=0 then drt=true end end end
		if drt then refreshWing(wk) else wlbl(wk,wg) end
	end
	local lkd=false for _,st in pairs(Eco.All()) do if st.lockSeconds>0 then lkd=true end end
	for i=#thieves,1,-1 do
		local t=thieves[i] local dir=t.fleeing and 1 or -1 t.pos+=v3(dir*5.2*dt,0,math.sin(os.clock()*2+i)*1.2*dt)
		if (t.pos.X<-13.2 and lkd) or t.pos.X<-22 then t.fleeing=true elseif t.pos.X>16 then t.model:Destroy() table.remove(thieves,i) continue end
		t.model:PivotTo(cf(t.pos)*ang(0,mr(dir<0 and 90 or -90),0))
	end
end
return Heist
