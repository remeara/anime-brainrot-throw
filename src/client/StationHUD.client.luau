local Players,RS=game:GetService("Players"),game:GetService("ReplicatedStorage") local Sh=RS:WaitForChild("Shared")
local Cat,Rem=require(Sh:WaitForChild("BrainrotCatalog")),require(Sh:WaitForChild("Remotes"))
local plr,I,sf,cl,FM,FR=Players.LocalPlayer,Instance.new,string.format,math.clamp,Cat.FormatMoney,Cat.FormatRate
local gui=I("ScreenGui",plr:WaitForChild("PlayerGui")) gui.Name,gui.ResetOnSpawn,gui.IgnoreGuiInset,gui.ZIndexBehavior="StationHUD",false,true,Enum.ZIndexBehavior.Sibling
local E=Enum
local rem,u2,ud,fs,c3,GB,AX,v2=Rem.Get(),UDim2.fromOffset,UDim2.new,UDim2.fromScale,Color3.fromRGB,E.Font.GothamBlack,E.TextXAlignment.Left,Vector2.new
local CR,BG,DK,GD,EM,GN=c3(255,247,230),c3(94,18,36),c3(48,10,20),c3(242,183,5),c3(25,158,99),c3(84,245,152)
local function dec(p,r,sc,th) if r then I("UICorner",p).CornerRadius=UDim.new(0,r) end if sc then local s=I("UIStroke",p) s.Color,s.Thickness=sc,th or 2 end end
local function ll(p,pd,dr,ha) local l=I("UIListLayout",p) l.Padding=UDim.new(0,pd or 4) if dr then l.FillDirection=dr end if ha then l.HorizontalAlignment=ha end return l end
local function on(b,f) b.MouseButton1Click:Connect(f) end
local function base(k,p,sz,pos,bg,r,an,sc,th) local o=I(k,p) o.Size,o.Position,o.BackgroundColor3,o.BorderSizePixel=sz,pos,bg,0 if an then o.AnchorPoint=an end dec(o,r,sc,th) return o end
local function bx(p,sz,pos,bg,r,an,sc,th) return base("Frame",p,sz,pos,bg,r,an,sc,th) end
local function lb(p,t,sz,pos,col,tsz,fnt,ax) local l=I("TextLabel",p) l.Size,l.Position,l.BackgroundTransparency,l.Font,l.Text,l.TextColor3,l.TextSize=sz or fs(1,1),pos or ud(),1,fnt or E.Font.GothamBold,t,col,tsz if ax then l.TextXAlignment=ax end return l end
local function btn(p,sz,pos,bg,tx,fg,tsz,r,an,sc,th) local b=base("TextButton",p,sz,pos,bg,r or 6,an,sc,th) b.Font,b.Text,b.TextColor3,b.TextSize=GB,tx,fg,tsz return b end
local function pill(p,sz,pos,bg,r,an,sc,th,tx,fg,tsz) local b=bx(p,sz,pos,bg,r,an,sc,th) return b,lb(b,tx,nil,nil,fg,tsz,GB) end
local function modal(w,h,py,tit,clT)
	local m=bx(gui,u2(w,h),ud(.5,0,py,0),CR,12,v2(.5,.5),DK,3) m.Visible,m.ZIndex=false,10
	local hd=bx(m,ud(1,0,0,42),ud(),BG,11) local tl=lb(hd,tit,ud(1,-220,1,0),u2(14,0),GD,15,GB,AX)
	on(btn(hd,u2(72,26),ud(1,-10,.5,0),GD,clT,DK,11,6,v2(1,.5)),function() m.Visible=false end) return m,hd,tl
end

pill(gui,u2(670,22),ud(.52,0,0,6),BG,6,v2(.5,0),GD,1.5,"48 BRAINROTS · 7 RARITIES · 6 MUTATIONS · STEAL · WHACK · LOCK · REBIRTH",GD,11)
local hdr=bx(gui,u2(670,50),ud(.52,0,0,32),CR,10,v2(.5,0),DK,2.5)
pill(hdr,u2(182,36),u2(8,7),BG,7,nil,GD,1.5,"BRAINROT EXPRESS",CR,15)
local cashL,rateL,rebL=lb(hdr,"$1,500",u2(140,38),u2(198,6),DK,23,GB,AX),lb(hdr,"+$66/s",u2(122,22),u2(340,5),EM,15,GB,AX),lb(hdr,"REBIRTH 0 · x1",u2(132,18),u2(340,26),BG,12,nil,AX)
local _,padsL=pill(hdr,u2(88,32),u2(478,9),BG,7,nil,nil,nil,"PADS 2/12",GD,13)
local lockP,lockTopL=pill(hdr,u2(92,32),u2(572,9),EM,7,nil,nil,nil,"GATE OPEN",CR,12)
local evBar,evL=pill(gui,u2(500,30),ud(.52,0,0,88),GD,8,v2(.5,0),DK,2,"",DK,12) evBar.Visible=false
local toastF=I("Frame",gui) toastF.Position,toastF.Size,toastF.BackgroundTransparency=u2(14,124),u2(296,130),1 ll(toastF,5)
local qBox=bx(gui,u2(244,194),ud(1,-14,0,124),DK,10,v2(1,0),GD,2) qBox.BackgroundTransparency=.08
local _,qTitleL=pill(qBox,ud(1,0,0,28),ud(),BG,9,nil,nil,nil,"QUESTS · 0/18 done",GD,12)
local qRows={} for i=1,3 do local r=btn(qBox,ud(1,-16,0,45),u2(8,34+(i-1)*51),CR,"",DK,11,7,nil,GD,1.5) local tl=lb(r,"Q",ud(1,-10,0,21),u2(6,2),DK,11,nil,AX) tl.TextTruncate=E.TextTruncate.AtEnd qRows[i]={btn=r,title=tl,prog=lb(r,"0/1",ud(1,-10,0,18),u2(6,23),EM,11,GB,AX)} end
local carryBar,carryL=pill(gui,u2(500,32),ud(.5,0,1,-72),EM,8,v2(.5,1),GD,2,"",CR,13) carryBar.Visible=false
local dock=I("Frame",gui) dock.AnchorPoint,dock.Position,dock.Size,dock.BackgroundTransparency=v2(.5,1),ud(.5,0,1,-12),u2(690,52),1 ll(dock,8,E.FillDirection.Horizontal,E.HorizontalAlignment.Center)

local sbM,sbH,sbTitle=modal(744,380,.535,"GRAND STATION STAMP BOOK · 2/48","CLOSE [B]")
local pFill=bx(bx(sbH,u2(130,14),ud(1,-222,.5,-7),DK,7,nil,GD,1.5),fs(.1,1),ud(),EM,6)
local tabBar=I("Frame",sbM) tabBar.Position,tabBar.Size,tabBar.BackgroundTransparency=u2(12,48),ud(1,-24,0,26),1 ll(tabBar,4,E.FillDirection.Horizontal)
local selF,tabB="ALL",{}
local sbS=I("ScrollingFrame",sbM) sbS.Position,sbS.Size,sbS.BackgroundTransparency,sbS.CanvasSize,sbS.AutomaticCanvasSize,sbS.ScrollBarThickness=u2(12,80),ud(1,-24,1,-88),1,ud(),E.AutomaticSize.Y,6
local sbG=I("UIGridLayout",sbS) sbG.CellSize,sbG.CellPadding=u2(113,64),u2(6,6)
local upM,upH,upTitle=modal(540,380,.54,"STATION UPGRADES · 0/40 bought","CLOSE [U]")
local latest,prevTM=nil,nil

local GC,GM=Cat.GetCharacter,Cat.GetMutation
local function clr(p,k) for _,c in ipairs(p:GetChildren()) do if c:IsA("Frame") and c~=k then c:Destroy() end end end
local function renderSB()
	if not latest then return end clr(sbS) local disc,list=latest.discovered or {},Cat.CHARACTERS
	for id,b in pairs(tabB) do local onS=id==selF b.BackgroundColor3,b.TextColor3=onS and BG or c3(235,220,192),onS and GD or DK end
	for i=#list,1,-1 do local ch=list[i] if selF=="ALL" or ch.rarity==selF then
		local mid,rar=disc[ch.id],Cat.RARITIES[ch.rarity]
		local card=bx(sbS,ud(),ud(),mid and DK or c3(224,212,188),7,nil,mid and rar.color or c3(165,152,132),2)
		lb(card,mid and ch.name or "?? "..ch.rarity,ud(1,-8,0,24),u2(4,3),mid and CR or c3(110,98,86),10).TextWrapped=true
		if mid then local mut=GM(mid) lb(card,mut.name.." · "..ch.rarity,ud(1,-8,0,15),u2(4,29),mut.color,9,GB) lb(card,FR(ch.income*mut.mult),ud(1,-8,0,17),u2(4,45),GN,11,GB)
		else lb(card,"UNDISCOVERED",ud(1,-8,0,16),u2(4,38),c3(128,114,98),9) end
	end end
end
local function renderUp()
	if not latest then return end clr(upM,upH) local ups=latest.upgrades or {} upTitle.Text=sf("STATION UPGRADES · %d/40 bought",latest.upgradesBought or 0)
	for i,inf in ipairs(Cat.UPGRADES) do
		local lv=ups[inf.id] or 0 local mx=lv>=inf.maxLevel local row=bx(upM,ud(1,-28,0,54),u2(14,54+(i-1)*62),DK,8,nil,GD,1.5)
		lb(row,sf("%s (Lv.%d/%d)",inf.name,lv,inf.maxLevel),u2(290,24),u2(10,4),CR,13,GB,AX) lb(row,inf.desc,u2(290,18),u2(10,29),GD,11,nil,AX)
		on(btn(row,u2(132,36),ud(1,-10,.5,0),mx and c3(110,100,92) or EM,mx and "MAXED" or "BUY "..FM(Cat.GetUpgradeCost(inf.id,lv)),CR,12,7,v2(1,.5)),function() rem.BuyUpgrade:FireServer(inf.id) end)
	end
end
for _,pair in ipairs(string.split("ALL:ALL (48),Secret:SECRET (5),Mythic:MYTHIC (6),Legendary:LEGENDARY (7),Epic:EPIC (7),Rare:RARE (7),Uncommon:UNCOMMON (8),Common:COMMON (8)",",")) do
	local f=string.split(pair,":") local tb=btn(tabBar,u2(86,24),ud(),CR,f[2],DK,10) on(tb,function() selF=f[1] renderSB() end) tabB[f[1]]=tb
end
local function tog(n) if n=="stampbook" then sbM.Visible,upM.Visible=not sbM.Visible,false if sbM.Visible then renderSB() end elseif n=="upgrades" then upM.Visible,sbM.Visible=not upM.Visible,false if upM.Visible then renderUp() end end end
local dS={} for i,d in ipairs({{"[L] LOCK","45s Gate",EM,CR,function() rem.LockPlatformGate:FireServer() end},{"[F] WHACK","+$65K Bonk",BG,CR,function() plr:SetAttribute("SwingMallet",os.clock()) rem.WhackThief:FireServer() end},{"[U] UPGRADES","0/40",CR,DK,function() tog("upgrades") end,BG},{"[R] REBIRTH","$50.0K",DK,CR,function() rem.PerformRebirth:FireServer() end},{"[B] STAMP BOOK","2/48",BG,CR,function() tog("stampbook") end}}) do
	local b=btn(dock,u2(130,50),ud(),d[3],"",d[4],13,9,nil,GD,2) lb(b,d[1],ud(1,-8,0,24),u2(4,3),d[4],13,GB) dS[i]=lb(b,d[2],ud(1,-8,0,18),u2(4,27),d[6] or GD,11) on(b,d[5])
end
plr:SetAttribute("ToggleModal","") plr:GetAttributeChangedSignal("ToggleModal"):Connect(function() local v=plr:GetAttribute("ToggleModal") if v=="stampbook" or v=="upgrades" then tog(v) plr:SetAttribute("ToggleModal","") end end)
local function applyBanner(ev) if ev and ev.title then evBar.Visible=true local tr=ev.kind=="train" evBar.BackgroundColor3,evL.TextColor3,evL.Text=tr and c3(196,32,46) or GD,tr and CR or DK,sf("%s · %ds",ev.title,ev.secondsLeft or 0) else evBar.Visible=false end end
rem.EventBanner.OnClientEvent:Connect(applyBanner)
rem.StateSync.OnClientEvent:Connect(function(s)
	latest=s cashL.Text,rateL.Text=FM(s.cash or 0),FR(s.incomePerSec or 0)
	rebL.Text,padsL.Text=sf("REBIRTH %d · x%d",s.rebirths or 0,s.rebirthMult or 1),sf("PADS %d/12",s.padsFilled or 0)
	local ls=s.lockSeconds or 0 lockP.BackgroundColor3,lockTopL.Text,dS[1].Text=ls>0 and EM or c3(168,42,54),ls>0 and sf("LOCKED %ds",ls) or "GATE OPEN",ls>0 and sf("LOCKED %ds",ls) or "45s Gate"
	dS[3].Text,dS[4].Text=sf("%d/40",s.upgradesBought or 0),FM(s.rebirthCost or 5e4)
	local dc=s.discoveredCount or 0 dS[5].Text,sbTitle.Text,pFill.Size=sf("%d/48",dc),sf("GRAND STATION STAMP BOOK · %d/48 (%.1f%%)",dc,(dc/48)*100),fs(cl(dc/48,.02,1),1)
	if s.carried then carryBar.Visible=true carryL.Text=sf("CARRYING: %s [%s] -> DASH TO DROP MAT!",GC(s.carried.characterId).name,GM(s.carried.mutationId).name) else carryBar.Visible=false end
	applyBanner(s.eventBanner) clr(toastF)
	for _,t in ipairs(s.toasts or {}) do local card=bx(toastF,ud(1,0,0,36),ud(),DK,7,nil,t.tone=="emerald" and EM or t.tone=="crimson" and c3(235,68,78) or GD,1.8) card.BackgroundTransparency=.12 lb(card,t.text,ud(1,-12,1,0),u2(6,0),CR,10,nil,AX).TextWrapped=true end
	qTitleL.Text=sf("QUESTS · %d/18 done",s.questsDone or 0)
	local act,pm=s.activeQuestIds or {},s.questProgress or {}
	for i,r in ipairs(qRows) do
		local f=nil for _,q in ipairs(Cat.QUESTS) do if q.id==act[i] then f=q break end end
		if f then r.btn.Visible=true local cur=math.min(f.target,pm[f.metric] or 0) local dn=cur>=f.target r.btn.BackgroundColor3,r.title.Text=dn and c3(214,248,224) or CR,f.title r.prog.Text=dn and ("CLAIM +"..FM(f.reward)) or sf("%d/%d · +%s",cur,f.target,FM(f.reward)) r.btn:SetAttribute("QuestId",f.id) else r.btn.Visible=false end
	end
	if s.tourOpenModal=="stampbook" then sbM.Visible=true upM.Visible=false renderSB() elseif s.tourOpenModal==nil and prevTM~=nil then sbM.Visible=false end
	prevTM=s.tourOpenModal if sbM.Visible then renderSB() end if upM.Visible then renderUp() end
end)
for _,r in ipairs(qRows) do on(r.btn,function() local q=r.btn:GetAttribute("QuestId") if typeof(q)=="string" then rem.ClaimQuest:FireServer(q) end end) end
