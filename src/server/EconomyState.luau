local Sh=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cat,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("Remotes"))
local Eco,states,I={}, {},Instance.new
local function cnt(m,fn) local n=0 for k,v in pairs(m) do if not fn or fn(v,k) then n+=1 end end return n end
local function uLS(st) local ls=st.player:FindFirstChild("leaderstats") if ls then ls.Cash.Value,ls.Rate.Value,ls.Rebirths.Value=math.floor(st.cash),math.floor(st.incomePerSec),st.rebirths end end
function Eco.HRP(p) local ch=p and p.Character return ch and ch:FindFirstChild("HumanoidRootPart") end
function Eco.MakeStarterPads() local p={} for i=1,12 do p[i]={characterId=nil,mutationId="normal",storedCash=0} end p[1],p[2]={characterId="pigeoncini",mutationId="normal",storedCash=120},{characterId="baguettino",mutationId="brass",storedCash=240} return p end
function Eco.RecalcIncome(st) local t,m=0,st.upgrades.magnet or 0 for _,p in ipairs(st.pads) do if p.characterId then t+=Cat.ComputeIncome(p.characterId,p.mutationId,st.rebirthMult,m) end end st.incomePerSec=t uLS(st) end
function Eco.CountPads(st) return cnt(st.pads,function(p) return p.characterId~=nil end) end
function Eco.CountDiscovered(st) return cnt(st.discovered) end
function Eco.CountUpgrades(st) local n=0 for _,v in pairs(st.upgrades) do n+=v end return n end
function Eco.CountClaimedQuests(st) return cnt(st.questClaimed,function(v) return v end) end
function Eco.RefreshActiveQuests(st) local a={} for _,q in ipairs(Cat.QUESTS) do if not st.questClaimed[q.id] then table.insert(a,q.id) if #a>=3 then break end end end st.activeQuestIds=a end
function Eco.BumpMetric(st,m,d,ex) st.questProgress[m]=ex~=nil and math.max(st.questProgress[m] or 0,ex) or (st.questProgress[m] or 0)+d end
function Eco.RecordDiscovery(st,c,m) local cur=st.discovered[c] if not cur or Cat.GetMutation(m).mult>Cat.GetMutation(cur).mult then st.discovered[c]=m end Eco.BumpMetric(st,"stamps",0,cnt(st.discovered)) end
function Eco.AddToast(st,tx,tn) table.insert(st.toasts,1,{text=tx,tone=tn or "gold"}) while #st.toasts>3 do table.remove(st.toasts) end Rem.Get().ToastFeed:FireClient(st.player,{text=tx,tone=tn or "gold"}) end
function Eco.SyncClient(st)
	uLS(st) local pads={} for i,p in ipairs(st.pads) do pads[i]={characterId=p.characterId,mutationId=p.mutationId,storedCash=math.floor(p.storedCash)} end
	Rem.Get().StateSync:FireClient(st.player,{cash=math.floor(st.cash),incomePerSec=st.incomePerSec,rebirths=st.rebirths,rebirthMult=st.rebirthMult,rebirthCost=math.floor(5e4*(4^st.rebirths)),pads=pads,padsFilled=Eco.CountPads(st),carried=st.carried,lockSeconds=math.ceil(st.lockSeconds),discovered=st.discovered,discoveredCount=cnt(st.discovered),upgrades=st.upgrades,upgradesBought=Eco.CountUpgrades(st),questProgress=st.questProgress,questClaimed=st.questClaimed,questsDone=Eco.CountClaimedQuests(st),activeQuestIds=st.activeQuestIds,toasts=st.toasts,eventBanner=st.eventBanner,tourOpenModal=st.tourOpenModal})
end
function Eco.InitPlayer(plr)
	local ls=I("Folder",plr) ls.Name="leaderstats"
	for _,r in ipairs({{"Cash",1500},{"Rate",0},{"Rebirths",0}}) do local x=I("IntValue",ls) x.Name,x.Value=r[1],r[2] end
	local st={player=plr,cash=1500,incomePerSec=0,rebirths=0,rebirthMult=1,pads=Eco.MakeStarterPads(),lockSeconds=0,discovered={pigeoncini="normal",baguettino="brass"},upgrades={sprint=0,mallet=0,lock=0,magnet=0,luck=0},questProgress={pads=2,stamps=2},questClaimed={},activeQuestIds={},toasts={{text="Welcome! Press [E] on Parade Brainrots!",tone="gold"}}}
	Eco.RefreshActiveQuests(st) Eco.RecalcIncome(st) states[plr.UserId]=st return st
end
function Eco.Get(p) return states[p.UserId] end
function Eco.All() return states end
function Eco.Remove(p) states[p.UserId]=nil end
return Eco
