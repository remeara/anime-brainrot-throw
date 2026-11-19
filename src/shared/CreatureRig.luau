local Cat=require(script.Parent.BrainrotCatalog)
local Rig,v3,cf,ang,c3,I,mr={},Vector3.new,CFrame.new,CFrame.Angles,Color3.fromRGB,Instance.new,math.rad
local B,M,Mt,Cy,N,E=Enum.PartType.Ball,Enum.Material.SmoothPlastic,Enum.Material.Metal,Enum.PartType.Cylinder,Enum.Material.Neon,Enum
local SH={loaf=v3(1.7,1.45,2.95),long=v3(1.7,1.45,2.95),tall=v3(1.7,2.45,1.8),chubby=v3(2.4,2,2.3),frog=v3(2.3,1.35,2.2),shell=v3(2.3,1.35,2.2)}
local function pt(p,sz,c,col,mat,shp,anc) local x=I("Part",p) x.Size,x.CFrame,x.Color,x.Material,x.Shape,x.Anchored,x.CanCollide,x.Massless=sz,c,col,mat or M,shp or E.PartType.Block,anc,false,true return x end
local function dec(p,r,sc,th) I("UICorner",p).CornerRadius=UDim.new(0,r) local s=I("UIStroke",p) s.Color,s.Thickness=sc,th end
local function addProp(m,pr,hcf,bcf,acc,s,anc)
	local gd=c3(246,198,52) local function pp(x,y,z,c,col,mat,shp) return pt(m,v3(x,y,z)*s,c,col,mat,shp,anc) end
	if pr=="hat" or pr=="crown" then pp(.2,2,2,hcf*cf(0,.94*s,0)*ang(0,0,mr(90)),pr=="crown" and gd or c3(34,42,76),Mt,Cy) pp(1.35,.68,1.35,hcf*cf(0,1.32*s,0),pr=="crown" and gd or acc,Mt)
	elseif pr=="halo" then pp(1.9,.22,1.9,hcf*cf(0,1.48*s,0),c3(255,226,86),N)
	elseif pr=="ticket" then pp(1.15,.68,.16,bcf*cf(1.3*s,.3*s,-.6*s)*ang(0,mr(-18),mr(14)),gd,N)
	elseif pr=="mug" then local cup=pp(.66,.8,.66,bcf*cf(-1.2*s,.2*s,-.6*s),c3(246,240,228),M) pp(.54,.14,.54,cup.CFrame*cf(0,.38*s,0),c3(82,44,24),M)
	elseif pr=="bag" then pp(.58,.88,1.1,bcf*cf(1.25*s,-.1*s,0),c3(142,78,42),E.Material.Wood)
	elseif pr=="sax" then pp(.34,1.3,.34,bcf*cf(1*s,.1*s,-.75*s)*ang(mr(22),0,mr(-15)),gd,Mt)
	elseif pr=="glasses" then pp(1.5,.26,.16,hcf*cf(0,.18*s,-.96*s),gd,Mt)
	else pp(.55,.9,.55,hcf*cf(0,1.2*s,0),acc,N,B) end
end
local function eyes(m,hcf,s,anc) for _,e in ipairs({{-.46,.08,.06},{.46,-.08,-.05}}) do pt(m,v3(.7,.7,.7)*s,hcf*cf(e[1]*s,.24*s,-.78*s),c3(252,252,250),M,B,anc) pt(m,v3(.34,.34,.34)*s,hcf*cf((e[1]+e[2])*s,(.24+e[3])*s,-1.03*s),c3(16,16,22),M,B,anc) end end
local function bbCard(hd,w,h,off,stCol,stTh)
	local gui=I("BillboardGui",hd) gui.Name,gui.Adornee,gui.AlwaysOnTop,gui.MaxDistance,gui.Size,gui.StudsOffset="TagGui",hd,false,48,UDim2.fromOffset(w,h),off
	local card=I("Frame",gui) card.Size,card.BackgroundColor3,card.BackgroundTransparency=UDim2.fromScale(1,1),c3(34,10,18),.14 dec(card,5,stCol,stTh) return card
end
function Rig.BuildThief(k,o)
	local m=I("Model") m.Name=k local bc=k=="Pickpocket Pigeon" and c3(132,146,174) or c3(122,108,96)
	local function tp(sz,p,c,s) return pt(m,sz,o*p,c,nil,s,true) end
	m.PrimaryPart=tp(v3(2.3,2.1,2.3),cf(0,1.7,0),bc) local hd=tp(v3(1.8,1.45,1.8),cf(0,3.4,-.2),bc)
	tp(v3(1.92,.56,.32),cf(0,3.55,-1.08),c3(22,22,26)) tp(v3(1.5,1.8,1.3),cf(0,2.1,1.45),c3(218,182,114),B)
	for _,x in ipairs({-.42,.42}) do tp(v3(.52,.72,.72),cf(x*1.4,.36,0),c3(242,162,42)) end
	eyes(m,o*cf(0,3.34,-.25),.9,true)
	local cd=bbCard(hd,162,46,v3(0,2.1,0),c3(255,214,58),2) cd.BackgroundColor3=c3(136,22,34)
	local l=I("TextLabel",cd) l.Size,l.BackgroundTransparency,l.Font,l.Text,l.TextColor3,l.TextScaled=UDim2.new(1,-8,1,-4),1,E.Font.GothamBlack,k.."\nTHIEF! WHACK [F]",c3(255,244,210),true
	I("UITextSizeConstraint",l).MaxTextSize=11 return m
end
function Rig.BuildCreature(cid,mid,ocf,opts)
	local o=opts or {} local s,anc=o.scale or 1.2,o.anchored==nil and true or o.anchored
	local ch,mut=Cat.GetCharacter(cid),Cat.GetMutation(mid)
	local rar,m,mn=Cat.RARITIES[ch.rarity],I("Model"),mut.id~="normal" m.Name=ch.name
	local mat,bCol=mut.id=="brass" and Mt or M,mut.id=="brass" and ch.bodyColor:Lerp(mut.color,.38) or ch.bodyColor
	local aCol=(mn and mut.id~="brass") and mut.color or ch.accentColor
	local sh,bSz=ch.shape,(SH[ch.shape] or v3(2,1.8,2.1))*s
	local function cp(sz,c,col,mt2) return pt(m,sz*s,c,col,mt2 or mat,nil,anc) end
	local rcf=ocf*cf(0,.72*s+bSz.Y*.5,0) local body=pt(m,bSz,rcf,bCol,mat,nil,anc) body.Name,m.PrimaryPart="Root",body
	for _,x in ipairs({-.58,.58}) do cp(v3(.55,.75,.75),ocf*cf(x*s,.37*s,0),aCol) cp(v3(.42,.9,.65),rcf*cf(x*1.18*s,.05*s,0)*ang(0,0,mr(x*-16)),sh=="bird" and aCol or bCol) end
	local hcf=rcf*cf(0,bSz.Y*.44+.66*s,-bSz.Z*.22) local head=cp(v3(1.75,1.5,1.65),hcf,bCol) eyes(m,hcf,s,anc)
	cp(v3(.76,.42,.62),hcf*cf(0,-.25*s,-.92*s),sh=="bird" and c3(248,168,38) or aCol,M) addProp(m,ch.prop,hcf,rcf,aCol,s,anc)
	if mn then
		local hl=I("Highlight",m) hl.Adornee,hl.FillColor,hl.OutlineColor,hl.FillTransparency,hl.OutlineTransparency,hl.DepthMode=m,mut.color,mut.color,mut.id=="brass" and .8 or .64,.12,E.HighlightDepthMode.Occluded
		if mut.id=="chrono" or mut.id=="prism" or mut.id=="crystal" then I("Sparkles",body).SparkleColor=mut.color end
	end
	if not anc then for _,d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") and d~=body then local w=I("WeldConstraint",body) w.Part0,w.Part1=body,d end end end
	if not o.hideGui then
		local fc=mn and mut.color or rar.color local card=bbCard(head,128,o.tagText and 48 or 38,v3(0,2.2*s,0),fc,1.6)
		local lay=I("UIListLayout",card) lay.HorizontalAlignment,lay.VerticalAlignment=E.HorizontalAlignment.Center,E.VerticalAlignment.Center
		local function ln(t,col,sz) local l=I("TextLabel",card) l.Size,l.BackgroundTransparency,l.Font,l.Text,l.TextColor3,l.TextSize,l.TextTruncate=UDim2.new(1,-6,0,sz+2),1,E.Font.GothamBlack,t,col,sz,E.TextTruncate.AtEnd local ts=I("UIStroke",l) ts.Thickness,ts.Color=1.2,c3(14,4,8) end
		ln(ch.name,c3(255,248,232),10) ln(mn and ("["..mut.name.." · "..ch.rarity.."]") or ("["..ch.rarity.."]"),fc,8)
		ln(o.rateText or Cat.FormatRate(ch.income*mut.mult),c3(84,245,152),10) if o.tagText then ln(o.tagText,o.tagColor or c3(255,214,62),9) end
	end
	return m
end
return Rig
