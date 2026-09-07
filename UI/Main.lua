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

    -- Guardpoint.lua is loaded before Runtime/Bootstrap.lua and already owns
    -- the proven working GP_Main frame. Reuse it instead of creating a second
    -- frame. This keeps the UI lifecycle identical to the last known-good UI.
    local f=_G.GP_Main
    if not f then return end

    UI.frame=f
    f:SetFrameStrata("HIGH")
    if f.SetClampedToScreen then f:SetClampedToScreen(true) end
end

function UI.placeButtons(list,buttons,cx)
    if not buttons then return end
    local n=math.min(2,#list)
    for i=1,2 do if buttons[i] then buttons[i]:Hide() end end
    if n==0 then return end
    if n==1 then
        local b=buttons[1]
        b:ClearAllPoints();b:SetPoint("CENTER",UI.frame,"CENTER",cx,-31)
        b.data=list[1];b.icon:SetTexture(UI.iconFor(list[1]));b:Show()
    else
        buttons[1]:ClearAllPoints();buttons[2]:ClearAllPoints()
        buttons[1]:SetPoint("CENTER",UI.frame,"CENTER",cx-22,-31)
        buttons[2]:SetPoint("CENTER",UI.frame,"CENTER",cx+22,-31)
        for i=1,2 do
            buttons[i].data=list[i];buttons[i].icon:SetTexture(UI.iconFor(list[i]));buttons[i]:Show()
        end
    end
end

function UI.layout()
    local f=UI.frame
    if not f or not f.before or not f.after then return end
    local b=f.planBefore or {};local a=f.planAfter or {}
    if f.arrow then f.arrow:Hide() end
    for i=1,2 do
        if f.before[i] then f.before[i]:Hide() end
        if f.after[i] then f.after[i]:Hide() end
    end
    if #b==1 and #a==1 and U.same(b[1],a[1]) then
        local btn=f.before[1]
        btn:ClearAllPoints();btn:SetPoint("CENTER",f,"CENTER",0,-31)
        btn.data=b[1];btn.icon:SetTexture(UI.iconFor(b[1]));btn:Show()
        return
    end
    if #b>0 and #a>0 then
        local beforeCenter=-51;local afterCenter=51
        UI.placeButtons(b,f.before,beforeCenter);UI.placeButtons(a,f.after,afterCenter)
        local nearestBefore=beforeCenter+(#b==2 and 22 or 0)
        local nearestAfter=afterCenter-(#a==2 and 22 or 0)
        if f.arrow then
            f.arrow:ClearAllPoints();f.arrow:SetPoint("CENTER",f,"CENTER",(nearestBefore+nearestAfter)/2,-31);f.arrow:Show()
        end
    elseif #b>0 then
        UI.placeButtons(b,f.before,0)
    elseif #a>0 then
        UI.placeButtons(a,f.after,0)
    end
end

local function updateButtonState()
    if not UI.frame or not UI.frame:IsShown() then return end
    local f=UI.frame;local t=U.now();local encounter=NS.EncounterRegistry and NS.EncounterRegistry:GetActive();local timing=encounter and encounter.Timing;local lead=(timing and timing.GlowLead) or 5.0
    local preActive=(not S.active and S.nextAt and (S.nextAt-t)<=lead and (S.nextAt-t)>0);local postActive=S.active
    local function updateOne(b,side)
        if not b or not b.icon then return end
        local a=b.data
        if not a then
            if b.glowPixels then for i=1,#b.glowPixels do b.glowPixels[i]:SetAlpha(0);b.glowPixels[i]:Hide() end end
            if b.used then b.used:Hide() end;b.wasReady=false;return
        end
        local c=(a.kind=="item") and R.itemCD(a.slot) or R.spellCD(a.id);local ready=(c<=0.08);local actionable=((side==1 and preActive) or (side==2 and postActive))
        if actionable and ready then b.wasReady=true elseif b.wasReady and c>0.08 then S.used[U.key(a)]=true;b.wasReady=false end
        local used=U.isUsed(a)
        if used then b.icon:SetVertexColor(0.55,0.55,0.55,1);if b.used then b.used:Show() end else b.icon:SetVertexColor(1,1,1,1);if b.used then b.used:Hide() end end
        if b.cd then
            local showCD=false;local untilReaper=S.nextAt and (S.nextAt-t) or nil
            if not S.active and untilReaper and untilReaper>0 and c>0.08 and c<=untilReaper+0.10 then showCD=true end
            if showCD then b.cd:SetText(c>=10 and string.format("%.0f",c) or string.format("%.1f",c));b.cd:Show() else b.cd:SetText("");b.cd:Hide() end
        end
        if b.glowPixels then
            for i=1,#b.glowPixels do
                local tex=b.glowPixels[i]
                if actionable and ready and not used then local phase=((t*6.0)-(i-1)*0.60)%#b.glowPixels;local dist=math.min(phase,#b.glowPixels-phase);local alpha=0.16+0.84*math.exp(-(dist*dist)/2.6);tex:SetAlpha(alpha);tex:Show() else tex:SetAlpha(0);tex:Hide() end
            end
        end
    end
    if #((f.planBefore) or {})==1 and #((f.planAfter) or {})==1 and U.same(f.planBefore[1],f.planAfter[1]) then
        updateOne(f.before[1],S.active and 2 or 1)
        if f.after[1] then
            if f.after[1].glowPixels then for i=1,#f.after[1].glowPixels do f.after[1].glowPixels[i]:SetAlpha(0);f.after[1].glowPixels[i]:Hide() end end
            f.after[1].data=nil
        end
        return
    end
    for i=1,2 do updateOne(f.before[i],1);updateOne(f.after[i],2) end
end

function UI.render()
    UI.create()
    local f=UI.frame
    if not f then return end
    if not S.plan and not S.active then f:Hide();return end
    f.planBefore=(S.plan and S.plan.before) or {};f.planAfter=(S.plan and S.plan.after) or {}
    pcall(UI.layout)
    if f.timer then
        if S.active then f.timer:SetText(string.format("%.1f",math.max(0,(S.expire or U.now())-U.now()))) elseif S.nextAt then f.timer:SetText(string.format("%.1f",math.max(0,S.nextAt-U.now()))) else f.timer:SetText("") end
    end
    f:Show();pcall(updateButtonState)
end
NS.UI.updateButtonState=updateButtonState
