-- Guardpoint UI
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local S = NS.State.data
local U = NS.Util
local R = NS.Resources

NS.UI = NS.UI or {}
local UI = NS.UI

function UI.iconFor(a)
    if not a then return "Interface\\Icons\\INV_Misc_QuestionMark" end
    if a.kind=="item" then return R.itemIcon(a.slot) or "Interface\\Icons\\INV_Misc_QuestionMark" end
    return R.spellIcon(a.id)
end

function UI.create()
    if UI.frame then return end
    local f=CreateFrame("Frame","GP_Main_Modular",UIParent)
    UI.frame=f; f:SetWidth(190); f:SetHeight(76); f:SetFrameStrata("HIGH")
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) if not S.DB.locked then self:StartMoving() end end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing(); local p,_,rp,x,y=self:GetPoint()
        S.DB.point=p; S.DB.relPoint=rp; S.DB.x=x; S.DB.y=y
    end)
    if S.DB.point then f:SetPoint(S.DB.point,UIParent,S.DB.relPoint or S.DB.point,S.DB.x or 0,S.DB.y or 0) else f:SetPoint("CENTER",UIParent,"CENTER",0,-140) end
    f.timer=f:CreateFontString(nil,"OVERLAY","NumberFontNormalHuge")
    f.timer:SetPoint("TOP",f,"TOP",0,-2); f.timer:SetTextColor(1,0.86,0.35,1); f.timer:SetShadowColor(0,0,0,1); f.timer:SetShadowOffset(1,-1)
    f.before={}; f.after={}
    local function button()
        local b=CreateFrame("Button",nil,f); b:SetWidth(40); b:SetHeight(40); b:SetFrameLevel(f:GetFrameLevel()+2)
        b.icon=b:CreateTexture(nil,"BACKGROUND"); b.icon:SetAllPoints(b); b.icon:SetTexCoord(0.07,0.93,0.07,0.93); b.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        b.glowPixels={}; local glowPoints={{-15,-18},{-7,-18},{1,-18},{9,-18},{15,-18},{18,-14},{18,-6},{18,2},{18,10},{18,15},{15,18},{7,18},{-1,18},{-9,18},{-15,18},{-18,15},{-18,7},{-18,-1},{-18,-9},{-18,-15}}
        for i=1,#glowPoints do local tex=b:CreateTexture(nil,"OVERLAY");tex:SetTexture("Interface\\Buttons\\WHITE8X8");tex:SetBlendMode("ADD");tex:SetWidth(3);tex:SetHeight(3);tex:SetPoint("CENTER",b,"CENTER",glowPoints[i][1],glowPoints[i][2]);tex:SetVertexColor(0.10,1.0,0.20,1);tex:SetAlpha(0);tex:Hide();b.glowPixels[i]=tex end
        b.cd=b:CreateFontString(nil,"OVERLAY");b.cd:SetFont("Fonts\\FRIZQT__.TTF",22,"OUTLINE");b.cd:SetPoint("CENTER",b,"CENTER",0,0);b.cd:SetTextColor(1,1,1,1);b.cd:SetShadowColor(0,0,0,1);b.cd:SetShadowOffset(1,-1);b.cd:Hide()
        b.used=b:CreateTexture(nil,"OVERLAY");b.used:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");b.used:SetWidth(22);b.used:SetHeight(22);b.used:SetPoint("CENTER",b,"CENTER",0,0);b.used:SetVertexColor(0.15,1.0,0.15,1);b.used:SetAlpha(1);b.used:Hide();b.wasReady=false;b.lastCD=0;b:Hide();return b
    end
    for i=1,2 do f.before[i]=button();f.after[i]=button() end
    f.arrow=f:CreateTexture(nil,"OVERLAY");f.arrow:SetTexture("Interface\\AddOns\\Guardpoint\\arrow.tga");f.arrow:SetWidth(20);f.arrow:SetHeight(20);f.arrow:SetPoint("CENTER",f,"CENTER",0,-31);f.arrow:Hide();f:Hide()
end

function UI.placeButtons(list,buttons,cx)
    local n=math.min(2,#list);for i=1,2 do buttons[i]:Hide() end;if n==0 then return end
    if n==1 then buttons[1]:ClearAllPoints();buttons[1]:SetPoint("CENTER",UI.frame,"CENTER",cx,-31);buttons[1].data=list[1];buttons[1].icon:SetTexture(UI.iconFor(list[1]));buttons[1]:Show()
    else buttons[1]:ClearAllPoints();buttons[2]:ClearAllPoints();buttons[1]:SetPoint("CENTER",UI.frame,"CENTER",cx-22,-31);buttons[2]:SetPoint("CENTER",UI.frame,"CENTER",cx+22,-31);for i=1,2 do buttons[i].data=list[i];buttons[i].icon:SetTexture(UI.iconFor(list[i]));buttons[i]:Show() end end
end
function UI.layout()
    local f=UI.frame;local b=f.planBefore or {};local a=f.planAfter or {};f.arrow:Hide();for i=1,2 do f.before[i]:Hide();f.after[i]:Hide() end
    if #b==1 and #a==1 and U.same(b[1],a[1]) then local btn=f.before[1];btn:ClearAllPoints();btn:SetPoint("CENTER",f,"CENTER",0,-31);btn.data=b[1];btn.icon:SetTexture(UI.iconFor(b[1]));btn:Show();return end
    if #b>0 and #a>0 then local beforeCenter=-51;local afterCenter=51;UI.placeButtons(b,f.before,beforeCenter);UI.placeButtons(a,f.after,afterCenter);local nearestBefore=beforeCenter+(#b==2 and 22 or 0);local nearestAfter=afterCenter-(#a==2 and 22 or 0);local arrowX=(nearestBefore+nearestAfter)/2;f.arrow:ClearAllPoints();f.arrow:SetPoint("CENTER",f,"CENTER",arrowX,-31);f.arrow:Show()
    elseif #b>0 then UI.placeButtons(b,f.before,0) elseif #a>0 then UI.placeButtons(a,f.after,0) end
end
local function updateButtonState()
    if not UI.frame or not UI.frame:IsShown() then return end
    local f=UI.frame;local t=U.now();local encounter=NS.EncounterRegistry and NS.EncounterRegistry:GetActive();local timing=encounter and encounter.Timing;local lead=(timing and timing.GlowLead) or 5.0
    local preActive=(not S.active and S.nextAt and (S.nextAt-t)<=lead and (S.nextAt-t)>0);local postActive=S.active
    local function updateOne(b,side)
        local a=b.data;if not a then for i=1,#b.glowPixels do b.glowPixels[i]:SetAlpha(0);b.glowPixels[i]:Hide() end;b.used:Hide();b.wasReady=false;return end
        local c=(a.kind=="item") and R.itemCD(a.slot) or R.spellCD(a.id);local ready=(c<=0.08);local actionable=((side==1 and preActive) or (side==2 and postActive))
        if actionable and ready then b.wasReady=true elseif b.wasReady and c>0.08 then S.used[U.key(a)]=true;b.wasReady=false end
        local used=U.isUsed(a);if used then b.icon:SetVertexColor(0.55,0.55,0.55,1);b.used:Show() else b.icon:SetVertexColor(1,1,1,1);b.used:Hide() end
        local showCD=false;local untilReaper=S.nextAt and (S.nextAt-t) or nil;if not S.active and untilReaper and untilReaper>0 and c>0.08 and c<=untilReaper+0.10 then showCD=true end
        if showCD then b.cd:SetText(c>=10 and string.format("%.0f",c) or string.format("%.1f",c));b.cd:Show() else b.cd:SetText("");b.cd:Hide() end
        for i=1,#b.glowPixels do local tex=b.glowPixels[i];if actionable and ready and not used then local phase=((t*6.0)-(i-1)*0.60)%#b.glowPixels;local dist=math.min(phase,#b.glowPixels-phase);local alpha=0.16+0.84*math.exp(-(dist*dist)/2.6);tex:SetAlpha(alpha);tex:Show() else tex:SetAlpha(0);tex:Hide() end end
    end
    if #((f.planBefore) or {})==1 and #((f.planAfter) or {})==1 and U.same(f.planBefore[1],f.planAfter[1]) then updateOne(f.before[1],S.active and 2 or 1);for i=1,#f.after[1].glowPixels do f.after[1].glowPixels[i]:SetAlpha(0);f.after[1].glowPixels[i]:Hide() end;f.after[1].data=nil;return end
    for i=1,2 do updateOne(f.before[i],1);updateOne(f.after[i],2) end
end
function UI.render()
    UI.create();local f=UI.frame;if not S.plan then f:Hide();return end;f.planBefore=S.plan.before or {};f.planAfter=S.plan.after or {};UI.layout();if S.active then f.timer:SetText(string.format("%.1f",math.max(0,(S.expire or U.now())-U.now()))) elseif S.nextAt then f.timer:SetText(string.format("%.1f",math.max(0,S.nextAt-U.now()))) else f.timer:SetText("") end;f:Show();updateButtonState()
end
NS.UI.updateButtonState=updateButtonState
