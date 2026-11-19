local L,WS=game:GetService("Lighting"),game:GetService("Workspace")
local SW,v3,cf,c3,ang,mr,M,I,NI={},Vector3.new,CFrame.new,Color3.fromRGB,CFrame.Angles,math.rad,Enum.Material,Instance.new,Enum.NormalId
local Cy,Bl,N,Mt,Mb,Wd,Fb,R9=Enum.PartType.Cylinder,Enum.PartType.Ball,M.Neon,M.Metal,M.Marble,M.Wood,M.Fabric,ang(0,math.rad(90),0)
local BG,GD,EM,CM,CR,IR,FE=c3(108,22,40),c3(242,183,5),c3(25,158,99),c3(244,232,208),c3(168,26,42),c3(48,52,62),c3(36,38,46)
local function pt(p,nm,sz,c,col,mat,shp) local x=I("Part",p) x.Name,x.Size,x.CFrame,x.Color,x.Material,x.Shape,x.Anchored=nm,sz,c,col,mat or M.SmoothPlastic,shp or Enum.PartType.Block,true return x end
local function pts(p,r,b,d) for _,a in ipairs(r) do pt(p,a[1],v3(a[2],a[3],a[4]),(b or cf())*cf(a[5],a[6],a[7])*(a[11] or cf()),a[8],a[9] or d,a[10]) end end
local function sg(p,fc,tx,bg,fg,mx)
	local g=I("SurfaceGui",p) g.Face,g.SizingMode,g.PixelsPerStud=fc,Enum.SurfaceGuiSizingMode.PixelsPerStud,34
	local f=I("Frame",g) f.Size,f.BackgroundColor3,f.BorderSizePixel=UDim2.fromScale(1,1),bg or BG,0 local s=I("UIStroke",f) s.Color,s.Thickness=GD,4
	local l=I("TextLabel",f) l.Size,l.Position,l.BackgroundTransparency,l.Font,l.Text,l.TextColor3,l.TextScaled=UDim2.new(1,-14,1,-8),UDim2.fromOffset(7,4),1,Enum.Font.GothamBlack,tx,fg or c3(255,246,214),true
	I("UITextSizeConstraint",l).MaxTextSize=mx or 44 return l
end
local function sg2(p,f1,f2,t1,t2,bg,fg,mx) local a=sg(p,f1,t1,bg,fg,mx) sg(p,f2,t2 or t1,bg,fg,mx) return a end
local function awn(p,c,w,d,a,b) local st=d/9 for i=1,9 do pt(p,"A",v3(w,.5,st-.08),c*cf(0,0,-d*.5+(i-.5)*st)*ang(0,0,mr(-5)),i%2==1 and a or b,Fb) end pt(p,"T",v3(.45,.8,d+.4),c*cf(w*.5,-.4,0),GD,Mt) end
function SW.Build()
	local old=WS:FindFirstChild("StationWorld") if old then old:Destroy() end
	L.ClockTime,L.Brightness,L.Ambient,L.OutdoorAmbient,L.ColorShift_Top,L.GlobalShadows=17.1,2.5,c3(118,98,84),c3(148,124,98),c3(255,206,148),true
	local at=L:FindFirstChildOfClass("Atmosphere") or I("Atmosphere",L) at.Density,at.Offset,at.Color,at.Decay,at.Glare,at.Haze=.2,.1,c3(255,218,174),c3(238,178,128),.35,1.2
	local rt=I("Folder",WS) rt.Name="StationWorld"
	local iv,yw,yp=c3(245,234,212),c3(255,230,138),"YOUR PLATFORM · 12 PEDESTALS"
	local function q(sx,sy,sz,x,y,z,col,mat,shp,rt2,nm) return pt(rt,nm or "P",v3(sx,sy,sz),cf(x,y,z)*(rt2 or cf()),col,mat,shp) end
	pts(rt,{{"W",900,4,900,0,-6,0,c3(64,156,198)},{"S",132,4,180,0,-2.5,-2,c3(224,208,182),M.Concrete},{"B",18,.8,166,0,-.95,-2,c3(98,90,84),M.Slate},{"Cp",5.4,.16,156,0,-.45,-2,CR,Fb},{"VA",29,.35,62,-28.5,.18,2,c3(252,244,224),Mb},{"Hd",38,24,14,0,32,-76,iv,M.Limestone},{"B1",40,1.4,15.2,0,21.5,-76,GD,Mt},{"B2",40,1.8,15.2,0,43,-76,BG},{"Sh",16,18,4,0,9,-81,c3(20,12,16)},{"Cp2",20,8,12,0,48,-76,iv,M.Limestone},{"Sp",1.1,10,1.1,0,63,-76,GD,N},{"Dm",12,10,12,0,55,-76,GD,Mt,Bl},{"CR",.8,14.6,14.6,0,32,-68.9,GD,Mt,Cy,R9}})
	for _,s in ipairs({-1,1}) do pts(rt,{{"P",46,1.2,166,32.2*s,-.6,-2,CM,Mb},{"C",.8,1.3,166,9.4*s,-.55,-2,GD,Mt},{"R",.45,.45,164,4.4*s,-.35,-2,c3(196,202,212),Mt},{"T",.35,.18,156,2.85*s,-.44,-2,GD,Mt},{"Ap",1.5,17,1.5,10.5*s,8.5,-34,IR,Mt},{"Pl",11,22,14,13.5*s,11,-76,iv,M.Limestone}}) end
	local fc=q(1.1,13.2,13.2,0,32,-68.6,c3(252,242,216),nil,Cy,R9,"ClockFace")
	for h=1,12 do local a=mr(h*30) q(.4,.9,.45,math.sin(a)*5.3,32+math.cos(a)*5.3,-68,BG,Mt) end
	pt(rt,"HM",v3(.4,4.8,.5),fc.CFrame*cf(-.6,1.8,0)*ang(mr(12),0,0),BG,Mt) pt(rt,"HH",v3(.4,3.4,.6),fc.CFrame*cf(-.6,.8,1.2)*ang(mr(-62),0,0),BG,Mt)
	for z=-74,70,4 do q(11.6,.28,1.1,0,-.58,z,c3(102,64,38),Wd) end
	for i=-4,4 do local h=28+((i*19)%34) q(18,h,18,i*34,h*.5-4,118,c3(218,184,146)) end
	for _,xs in ipairs({-52,52}) do for _,zt in ipairs({-44,-14,16,46}) do q(1.1,8,1.1,xs,4,zt,c3(118,76,46),Wd) q(6,5,6,xs,9,zt,c3(54,148,72),M.Grass,Bl) end end
	for _,zb in ipairs({-56,-28,0,28,56}) do for _,s in ipairs({-1,1}) do q(1.8,28,1.8,50*s,14,zb,IR,Mt) q(.3,6.5,2.4,15*s,25,zb,s<0 and BG or GD,Fb) q(52,1.4,1.4,25*s,32,zb,IR,Mt,nil,ang(0,0,mr(-15*s))) end end
	for _,zl in ipairs({-44,-12,42}) do for _,xl in ipairs({-13.2,13.2}) do q(.55,9.5,.55,xl,4.75,zl,IR,Mt) local gl=q(1.8,1.8,1.8,xl,10.1,zl,yw,N,Bl) local pl=I("PointLight",gl) pl.Color,pl.Range,pl.Brightness=c3(255,212,122),28,1.1 end end
	sg2(q(25,4.6,1.6,0,17.2,-34,BG,Mt,nil,nil,"Board"),NI.Back,NI.Front,"BRAINROT EXPRESS · GRAND STATION HEIST","BRAINROT EXPRESS · PARADE TRACK",BG,GD,54)
	awn(rt,cf(-28.5,16,2),27,60,EM,CM)
	for _,xc in ipairs({-41.5,-15.5}) do for _,zc in ipairs({-26,30}) do q(.65,15.8,.65,xc,7.9,zc,GD,Mt) end end
	sg(q(25,2.8,1.1,-28.5,17.6,31,BG,nil,nil,nil,"VMF"),NI.Front,yp,BG,nil,48) sg(q(1.1,2.8,28,-15.5,17.6,2,BG,nil,nil,nil,"VMS"),NI.Right,yp,BG,nil,48)
	local pads,idx={},0
	for _,zp in ipairs({-22,-12.5,-3,6.5,16,25.5}) do for _,xp in ipairs({-34.5,-23.5}) do
		idx+=1 local ped=q(4,1.3,4,xp,.95,zp,BG,Mb,nil,nil,"Ped"..idx) q(4.3,.35,4.3,xp,.5,zp,GD,Mt)
		local cp=q(2.8,.26,3.2,xp+3.7,.44,zp,EM,N,nil,nil,"CashPad"..idx) cp:SetAttribute("PadIndex",idx)
		table.insert(pads,{index=idx,pedestal=ped,cashPad=cp,cashLabel=sg(cp,NI.Top,"$0",c3(18,92,58),nil,48),spawnCF=cf(xp,1.6,zp)*ang(0,mr(-90),0)})
	end end
	local dropMat=q(5.4,.32,6.2,-16.2,.45,2,EM,N,nil,nil,"DropMat") sg(dropMat,NI.Top,"DROP MAT · BANK HERE",c3(16,128,78),nil,40)
	local gateLasers={} for _,zp in ipairs({-25,-12,14,29}) do q(.7,6.2,.7,-13.8,3.1,zp,GD,Mt) end
	for _,yb in ipairs({2.2,4,5.8}) do local bm=q(.3,.3,56,-13.8,yb,2,c3(48,244,152),N) bm.CanCollide,bm.Transparency=false,.85 table.insert(gateLasers,bm) end
	local gateLbl=sg2(q(.8,2.2,12,-13.8,8,2,BG,nil,nil,nil,"GB"),NI.Right,NI.Left,"TURNSTILE OPEN · [L] LOCK",nil,BG,yw,42)
	local function wing(wk,zc,tit,lkd)
		q(26,.35,28,28,.18,zc,CM,Mb) awn(rt,cf(28,16,zc),24,26,CR,GD)
		for _,xc in ipairs({17,39}) do for _,z2 in ipairs({zc-11,zc+11}) do q(.65,15.8,.65,xc,7.9,z2,GD,Mt) end end
		local sl=sg(q(22,2.8,1.1,28,17.5,zc+13,BG),NI.Front,tit,BG,yw,42) sg(q(1.1,2.8,22,15.5,17.5,zc,BG),NI.Left,tit,BG,yw,42)
		local slots,ri={},0 for _,zo in ipairs({-5.5,5.5}) do for _,xp in ipairs({23,33}) do ri+=1 local pd=q(4,1.3,4,xp,.95,zc+zo,BG,Mb) q(4.3,.35,4.3,xp,.5,zc+zo,GD,Mt) table.insert(slots,{wing=wk,index=ri,pedestal=pd,spawnCF=cf(xp,1.6,zc+zo)*R9}) end end
		local ls={} for _,yb in ipairs({2.2,4,5.8}) do local b=q(.3,.3,26,14.2,yb,zc,c3(246,56,72),N) b.CanCollide,b.Transparency=false,lkd and .15 or .92 table.insert(ls,b) end
		return {slots=slots,lasers=ls,statusLabel=sl,locked=lkd,timer=lkd and 32 or 45}
	end
	local north,south=wing("north",-13,"RIVAL CONDUCTOR · [OPEN - STEAL!]",false),wing("south",23,"RIVAL BARON'S VAULT · [LOCKED 32s]",true)
	local loco,org=I("Model",rt),cf(0,0,-58) loco.Name="RunawayLocomotive" loco.PrimaryPart=pt(loco,"Chassis",v3(8.2,1.8,22),org*cf(0,2.1,0),FE,Mt)
	pts(loco,{{"Boiler",13.5,6.2,6.2,0,5.8,2.2,CR,Mt,Cy,R9},{"St",1.8,3.8,1.8,0,10.2,6.2,FE},{"SR",2.4,.7,2.4,0,12.1,6.2,GD},{"Cb",8.4,7.2,6.8,0,6.5,-7.2,CR},{"CR",9.2,.8,7.8,0,10.4,-7.2,GD},{"CW",8.6,2.6,3.6,0,7.2,-7.2,yw,N},{"Cs",7.8,6.4,12,0,4.8,-18.5,GD},{"CS",8,1.5,12.2,0,5.2,-18.5,CR,M.SmoothPlastic},{"Cw",7.8,2.6,4.2,0,1.5,12.6,GD,Mt,Enum.PartType.Wedge}},org,Mt)
	for _,zb in ipairs({-2.5,2.2,6.8}) do pt(loco,"Bd",v3(.55,6.5,6.5),org*cf(0,5.8,zb)*R9,GD,Mt,Cy) end
	for i=1,5 do pt(loco,"Pf",v3(2.2+i*.65,2+i*.55,2.2+i*.65),org*cf(i%2==0 and .6 or -.5,13.6+i*1.4,5.6-i*1.8),c3(252,250,246),nil,Bl).Transparency=.14 end
	local lmp=pt(loco,"Lamp",v3(2.2,2.2,1.2),org*cf(0,6.4,9.2),yw,N,Bl) local spL=I("SpotLight",lmp) spL.Color,spL.Range,spL.Angle,spL.Brightness,spL.Face=yw,55,52,3,NI.Front
	for _,x in ipairs({-4.3,4.3}) do for _,z in ipairs({-6.8,.5,7.5}) do pt(loco,"W",v3(.8,3.4,3.4),org*cf(x,1.7,z),CR,Mt,Cy) pt(loco,"H",v3(1,1.4,1.4),org*cf(x,1.7,z),GD,Mt,Cy) end end
	for _,d in ipairs(loco:GetDescendants()) do if d:IsA("BasePart") then d.CanCollide=false end end
	local warns={} for _,zp in ipairs({-18,14}) do for _,xp in ipairs({-10.6,10.6}) do q(.55,4.8,.55,xp,2.4,zp,FE,Mt) table.insert(warns,q(1.2,1.2,1.2,xp,5.2,zp,c3(246,52,52),N,Bl)) end end
	local sp=I("SpawnLocation",rt) sp.Name,sp.Size,sp.CFrame,sp.Anchored,sp.CanCollide,sp.Transparency="StationSpawn",v3(6,1,6),cf(-19.5,.3,2),true,false,1
	return {Root=rt,PlayerPads=pads,DropMat=dropMat,GateLasers=gateLasers,GateStatusLabel=gateLbl,Rivals={north=north,south=south},Locomotive=loco,WarningLights=warns,SpawnCF=cf(-19.5,3.2,2)*ang(0,mr(-90),0)}
end
return SW
