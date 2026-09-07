-- Guardpoint
-- WoW 3.3.5a / 12340

local ADDON = ...
local DB = GuardpointDB or {}
GuardpointDB = DB

local LichKingEncounter = _G.GuardpointLichKing
local REAPER_IDS = LichKingEncounter and LichKingEncounter.ReaperIDs or { [69409]=true, [73797]=true, [73798]=true, [73799]=true }
local QUAKE_ID = LichKingEncounter and LichKingEncounter.QuakeID or 72262
local LK_BOSS_ID = LichKingEncounter and LichKingEncounter.BossID or 36597

local P2_FIRST = LichKingEncounter and LichKingEncounter.Timing.P2First or 32.0
local P3_FIRST = LichKingEncounter and LichKingEncounter.Timing.P3First or 37.5
local NEXT_REAPER = LichKingEncounter and LichKingEncounter.Timing.NextReaper or 34.0
local REAPER_DURATION = LichKingEncounter and LichKingEncounter.Timing.ReaperDuration or 5.1
local PREWARN = LichKingEncounter and LichKingEncounter.Timing.Prewarn or 8.0
local GLOW_LEAD = LichKingEncounter and LichKingEncounter.Timing.GlowLead or 5.0

local BloodDK = _G.Guardpoint and _G.Guardpoint.BloodDK
local SPELL = BloodDK and BloodDK.Spells or {
    TAP  = 45529,
    VB   = 55233,
    AMS  = 48707,
    IBF  = 48792,
    ARMY = 42650,
    PAIN = 33206,
    SAC  = 6940,
}
local ITEM = BloodDK and BloodDK.Items or {
    FANG_N = 50361,
    FANG_H = 50364,
    SATRINA_N = 47080,
    SATRINA_H = 47088,
    KEY = 50356,
}

local state = {
    phase = 1,
    reaper = 0,
    nextAt = nil,
    nextNumber = 1,
    active = false,
    expire = 0,
    plan = nil,
    used = {},
    corePair = nil,
    lastApplied = 0,
    test = false,
    t10Override = nil,
    encounter = false,
    encounterGUID = nil,
    encounterStart = 0,
}
local UI = {}

local function tnow() return GetTime() end
local function lower(s) return string.lower(s or "") end

local function spellExists(id)
    return GetSpellInfo(id) ~= nil
end

local function spellIcon(id)
    local _,_,tex = GetSpellInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function spellCD(id)
    local s,d,e = GetSpellCooldown(id)
    if not s or not d or not e or s == 0 or d == 0 or e == 0 then return 0 end
    return math.max(0, s+d-tnow())
end

local function itemID(slot) return GetInventoryItemID("player",slot) end
local function itemName(slot)
    local id=itemID(slot)
    if not id then return "" end
    return GetItemInfo(id) or ""
end
local function itemIcon(slot)
    local id=itemID(slot)
    if not id then return nil end
    local _,_,_,_,_,_,_,_,_,tex=GetItemInfo(id)
    return tex or GetInventoryItemTexture("player",slot)
end
local function itemCD(slot)
    local s,d,e=GetInventoryItemCooldown("player",slot)
    if not s or not d or not e or s==0 or d==0 or e==0 then return 0 end
    return math.max(0,s+d-tnow())
end

local function equippedExact(id)
    if itemID(13)==id then return 13 end
    if itemID(14)==id then return 14 end
end

local function equippedByText(parts)
    for _,slot in ipairs({13,14}) do
        local n=lower(itemName(slot))
        for _,p in ipairs(parts) do
            if string.find(n,lower(p),1,true) then return slot end
        end
    end
end

local function trinket(kind)
    local slot
    if kind=="fang" then
        slot=equippedByText({"синдрагос","sindragosa"})
    elseif kind=="satrina" then
        slot=equippedExact(ITEM.SATRINA_N) or equippedExact(ITEM.SATRINA_H)
    elseif kind=="key" then
        slot=equippedExact(ITEM.KEY)
    end
    if not slot then return nil end
    return {kind="item", key=kind, id=itemID(slot), slot=slot}
end

local function fourT10()
    if state.t10Override ~= nil then return state.t10Override end

    if not UI.tip then
        UI.tip=CreateFrame("GameTooltip","GP_T10Scan",UIParent,"GameTooltipTemplate")
        UI.tip:SetOwner(UIParent,"ANCHOR_NONE")
    end

    local count=0
    for _,slot in ipairs({1,3,5,7,10}) do
        local id=itemID(slot)
        if id then
            local found=false
            local n=lower(itemName(slot))
            if string.find(n,"плет",1,true) or string.find(n,"scourgelord",1,true) then
                found=true
            else
                UI.tip:ClearLines()
                UI.tip:SetInventoryItem("player",slot)
                for line=1,UI.tip:NumLines() do
                    local obj=_G["GP_T10ScanTextLeft"..line]
                    local txt=obj and lower(obj:GetText()) or ""
                    if string.find(txt,"плет",1,true) or string.find(txt,"scourgelord",1,true) then
                        found=true
                        break
                    end
                end
            end
            if found then count=count+1 end
        end
    end
    return count>=4
end

local function spellA(id,key)
    if not spellExists(id) then return nil end
    return {kind="spell",id=id,key=key}
end

local function copy(a)
    if not a then return nil end
    local b={}
    for k,v in pairs(a) do b[k]=v end
    return b
end

local function key(a)
    return a and (a.kind..":"..tostring(a.id)) or ""
end

local function same(a,b)
    return a and b and key(a)==key(b)
end

local function has(list,a)
    if not a then return false end
    local k=key(a)
    for i=1,#list do if key(list[i])==k then return true end end
    return false
end

local function add(list,a)
    if a and not has(list,a) then list[#list+1]=copy(a) end
end

local function isUsed(a) return a and state.used[key(a)] end

local function readyBy(a,deadline)
    if not a or isUsed(a) then return false end
    local c
    if a.kind=="item" then c=itemCD(a.slot) else c=spellCD(a.id) end
    return c <= math.max(0,deadline-tnow()) + 0.10
end

local function coreList()
    local r={}
    local fang=trinket("fang")
    if fang then r[#r+1]=fang end

    if fourT10() then
        local tap=spellA(SPELL.TAP,"tap")
        if tap then r[#r+1]=tap end
    end

    local vb=spellA(SPELL.VB,"vb")
    if vb then r[#r+1]=vb end
    return r
end

local function chooseCorePair(deadline)
    local out={}
    local all=coreList()
    for i=1,#all do
        if readyBy(all[i],deadline) then
            add(out,all[i])
            if #out==2 then break end
        end
    end
    return out
end

local function chooseRemainingCore(deadline)
    if not state.corePair then return nil end
    local all=coreList()
    for i=1,#all do
        local a=all[i]
        if not has(state.corePair,a) and readyBy(a,deadline) then
            return copy(a)
        end
    end
end

local function choosePreFallback(deadline,exclude)
    local candidates={
        spellA(SPELL.PAIN,"pain"),
        spellA(SPELL.SAC,"sac"),
    }
    for i=1,#candidates do
        local a=candidates[i]
        if a and not has(exclude,a) and readyBy(a,deadline) then return a end
    end
end

local function chooseSolo(preferredID,deadline,exclude)
    local order={}
    local function put(id,k)
        local a=spellA(id,k)
        if a then order[#order+1]=a end
    end

    put(preferredID, "preferred")
    if preferredID~=SPELL.IBF then put(SPELL.IBF,"ibf") end
    if preferredID~=SPELL.AMS then put(SPELL.AMS,"ams") end
    if preferredID~=SPELL.ARMY then put(SPELL.ARMY,"army") end
    if preferredID~=SPELL.PAIN then put(SPELL.PAIN,"pain") end
    if preferredID~=SPELL.SAC then put(SPELL.SAC,"sac") end

    for i=1,#order do
        local a=order[i]
        if not has(exclude,a) and readyBy(a,deadline) then return a end
    end
end

local function chooseTrinket(deadline,exclude)
    local a=trinket("satrina")
    if a and not has(exclude,a) and readyBy(a,deadline) then return a end
    a=trinket("key")
    if a and not has(exclude,a) and readyBy(a,deadline) then return a end
end

local function soulReaperPlan(phase,n)
    local sr=_G.GuardpointLichKing and _G.GuardpointLichKing.SoulReaper
    if sr and sr.GetPlan then
        return sr.GetPlan(phase,n)
    end
end

local function actionSpellID(name)
    if name=="ams" then return SPELL.AMS end
    if name=="ibf" then return SPELL.IBF end
    if name=="army" then return SPELL.ARMY end
    if name=="pain" then return SPELL.PAIN end
    if name=="sac" then return SPELL.SAC end
end

local function buildActionList(tokens,deadline,corePair)
    local list={}
    local coreIndex=0
    local pair=corePair

    for i=1,#tokens do
        local token=tokens[i]
        local a
        if token=="core" then
            if not pair then pair=chooseCorePair(deadline) end
            coreIndex=coreIndex+1
            a=pair[coreIndex]
        elseif token=="remaining_core" then
            a=chooseRemainingCore(deadline)
        elseif token=="trinket" then
            a=chooseTrinket(deadline,list)
        else
            local id=actionSpellID(token)
            if id then a=chooseSolo(id,deadline,list) end
        end
        add(list,a)
    end

    return list,pair
end

local function buildDataPlan(plan,deadline)
    if not plan or not plan.actions then return nil end
    if not plan.actions.before or not plan.actions.after then return nil end

    local before,pair=buildActionList(plan.actions.before,deadline)
    if not before then return nil end
    while #before<2 do
        local a=choosePreFallback(deadline,before)
        if not a then break end
        add(before,a)
    end

    local after=buildActionList(plan.actions.after,deadline,pair)
    if not after then return nil end
    return before,after,pair
end

local function buildPlan(phase,n,deadline)
    local dataPlan=soulReaperPlan(phase,n)
    if dataPlan then
        local before,after,pair=buildDataPlan(dataPlan,deadline)
        if before and after then return before,after,pair end
    end

    return {},{},nil
end

local function iconFor(a)
    if not a then return "Interface\\Icons\\INV_Misc_QuestionMark" end
    if a.kind=="item" then return itemIcon(a.slot) or "Interface\\Icons\\INV_Misc_QuestionMark" end
    return spellIcon(a.id)
end

local function createUI()
    if UI.frame then return end

    local f=CreateFrame("Frame","GP_Main",UIParent)
    UI.frame=f
    f:SetWidth(190); f:SetHeight(76)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) if not DB.locked then self:StartMoving() end end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing()
        local p,_,rp,x,y=self:GetPoint()
        DB.point=p; DB.relPoint=rp; DB.x=x; DB.y=y
    end)

    if DB.point then
        f:SetPoint(DB.point,UIParent,DB.relPoint or DB.point,DB.x or 0,DB.y or 0)
    else
        f:SetPoint("CENTER",UIParent,"CENTER",0,-140)
    end

    f.timer=f:CreateFontString(nil,"OVERLAY","NumberFontNormalHuge")
    f.timer:SetPoint("TOP",f,"TOP",0,-2)
    f.timer:SetTextColor(1,0.86,0.35,1)
    f.timer:SetShadowColor(0,0,0,1); f.timer:SetShadowOffset(1,-1)

    f.before={}; f.after={}
    local function button()
        local b=CreateFrame("Button",nil,f)
        b:SetWidth(40); b:SetHeight(40)
        b:SetFrameLevel(f:GetFrameLevel()+2)

        b.icon=b:CreateTexture(nil,"BACKGROUND")
        b.icon:SetAllPoints(b)
        b.icon:SetTexCoord(0.07,0.93,0.07,0.93)
        b.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

        b.glowPixels={}
        local glowPoints={
            {-15,-18},{-7,-18},{1,-18},{9,-18},{15,-18},
            {18,-14},{18,-6},{18,2},{18,10},{18,15},
            {15,18},{7,18},{-1,18},{-9,18},{-15,18},
            {-18,15},{-18,7},{-18,-1},{-18,-9},{-18,-15},
        }
        for i=1,#glowPoints do
            local tex=b:CreateTexture(nil,"OVERLAY")
            tex:SetTexture("Interface\\Buttons\\WHITE8X8")
            tex:SetBlendMode("ADD")
            tex:SetWidth(3); tex:SetHeight(3)
            tex:SetPoint("CENTER",b,"CENTER",glowPoints[i][1],glowPoints[i][2])
            tex:SetVertexColor(0.10,1.0,0.20,1)
            tex:SetAlpha(0)
            tex:Hide()
            b.glowPixels[i]=tex
        end

        b.cd=b:CreateFontString(nil,"OVERLAY")
        b.cd:SetFont("Fonts\\FRIZQT__.TTF",22,"OUTLINE")
        b.cd:SetPoint("CENTER",b,"CENTER",0,0)
        b.cd:SetTextColor(1,1,1,1)
        b.cd:SetShadowColor(0,0,0,1); b.cd:SetShadowOffset(1,-1)
        b.cd:Hide()

        b.used=b:CreateTexture(nil,"OVERLAY")
        b.used:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        b.used:SetWidth(22); b.used:SetHeight(22)
        b.used:SetPoint("CENTER",b,"CENTER",0,0)
        b.used:SetVertexColor(0.15,1.0,0.15,1)
        b.used:SetAlpha(1)
        b.used:Hide()
        b.wasReady=false
        b.lastCD=0
        b:Hide()
        return b
    end
    for i=1,2 do f.before[i]=button(); f.after[i]=button() end

    f.arrow=f:CreateTexture(nil,"OVERLAY")
    f.arrow:SetTexture("Interface\\AddOns\\Guardpoint\\arrow.tga")
    f.arrow:SetWidth(20); f.arrow:SetHeight(20)
    f.arrow:SetPoint("CENTER",f,"CENTER",0,-31)
    f.arrow:Hide()

    f:Hide()
end

local function placeButtons(list,buttons,cx)
    local n=math.min(2,#list)
    for i=1,2 do buttons[i]:Hide() end
    if n==0 then return end
    if n==1 then
        buttons[1]:ClearAllPoints()
        buttons[1]:SetPoint("CENTER",UI.frame,"CENTER",cx,-31)
        buttons[1].data=list[1]
        buttons[1].icon:SetTexture(iconFor(list[1]))
        buttons[1]:Show()
    else
        buttons[1]:ClearAllPoints(); buttons[2]:ClearAllPoints()
        buttons[1]:SetPoint("CENTER",UI.frame,"CENTER",cx-22,-31)
        buttons[2]:SetPoint("CENTER",UI.frame,"CENTER",cx+22,-31)
        for i=1,2 do
            buttons[i].data=list[i]
            buttons[i].icon:SetTexture(iconFor(list[i]))
            buttons[i]:Show()
        end
    end
end

local function layout()
    local f=UI.frame
    local b=f.planBefore or {}
    local a=f.planAfter or {}
    f.arrow:Hide()
    for i=1,2 do f.before[i]:Hide(); f.after[i]:Hide() end

    if #b==1 and #a==1 and same(b[1],a[1]) then
        local btn=f.before[1]
        btn:ClearAllPoints()
        btn:SetPoint("CENTER",f,"CENTER",0,-31)
        btn.data=b[1]
        btn.icon:SetTexture(iconFor(b[1]))
        btn:Show()
        f.arrow:Hide()
        return
    end

    if #b>0 and #a>0 then
        local beforeCenter=-51
        local afterCenter=51
        placeButtons(b,f.before,beforeCenter)
        placeButtons(a,f.after,afterCenter)
        local nearestBefore=beforeCenter+(#b==2 and 22 or 0)
        local nearestAfter=afterCenter-(#a==2 and 22 or 0)
        local arrowX=(nearestBefore+nearestAfter)/2
        f.arrow:ClearAllPoints()
        f.arrow:SetPoint("CENTER",f,"CENTER",arrowX,-31)
        f.arrow:Show()
    elseif #b>0 then
        placeButtons(b,f.before,0)
    elseif #a>0 then
        placeButtons(a,f.after,0)
    end
end

local updateButtonState

local function render()
    createUI()
    local f=UI.frame
    if not state.plan then f:Hide(); return end
    f.planBefore=state.plan.before or {}
    f.planAfter=state.plan.after or {}
    layout()
    if state.active then
        f.timer:SetText(string.format("%.1f",math.max(0,(state.expire or tnow())-tnow())))
    elseif state.nextAt then
        f.timer:SetText(string.format("%.1f",math.max(0,state.nextAt-tnow())))
    else
        f.timer:SetText("")
    end
    f:Show()
    updateButtonState()
end

updateButtonState=function()
    if not UI.frame or not UI.frame:IsShown() then return end
    local f=UI.frame
    local t=tnow()
    local preActive=(not state.active and state.nextAt and (state.nextAt-t)<=GLOW_LEAD and (state.nextAt-t)>0)
    local postActive=state.active

    local function updateOne(b,side)
        local a=b.data
        if not a then
            if b.glowPixels then
                for i=1,#b.glowPixels do b.glowPixels[i]:SetAlpha(0); b.glowPixels[i]:Hide() end
            end
            b.used:Hide(); b.wasReady=false
            return
        end
        local c=(a.kind=="item") and itemCD(a.slot) or spellCD(a.id)
        local ready=(c<=0.08)
        local actionable=((side==1 and preActive) or (side==2 and postActive))
        if actionable and ready then
            b.wasReady=true
        elseif b.wasReady and c>0.08 then
            state.used[key(a)]=true
            b.wasReady=false
        end
        local used=isUsed(a)
        if used then b.icon:SetVertexColor(0.55,0.55,0.55,1); b.used:Show()
        else b.icon:SetVertexColor(1,1,1,1); b.used:Hide() end

        local showCD=false
        local untilReaper=state.nextAt and (state.nextAt-t) or nil
        if not state.active and untilReaper and untilReaper>0 and c>0.08 and c<=untilReaper+0.10 then showCD=true end
        if showCD then
            b.cd:SetText(c>=10 and string.format("%.0f",c) or string.format("%.1f",c)); b.cd:Show()
        else
            b.cd:SetText(""); b.cd:Hide()
        end

        local function setPixelGlow(on)
            local count=#b.glowPixels
            for i=1,count do
                local tex=b.glowPixels[i]
                if on then
                    local phase=((t*6.0)-(i-1)*0.60)%count
                    local dist=math.min(phase,count-phase)
                    local alpha=0.16+0.84*math.exp(-(dist*dist)/2.6)
                    tex:SetAlpha(alpha); tex:Show()
                else
                    tex:SetAlpha(0); tex:Hide()
                end
            end
        end
        setPixelGlow(actionable and ready and not used)
    end

    if #((f.planBefore) or {})==1 and #((f.planAfter) or {})==1 and same(f.planBefore[1],f.planAfter[1]) then
        updateOne(f.before[1],state.active and 2 or 1)
        if f.after[1].glowPixels then for i=1,#f.after[1].glowPixels do f.after[1].glowPixels[i]:SetAlpha(0); f.after[1].glowPixels[i]:Hide() end end
        f.after[1].data=nil
        return
    end
    for i=1,2 do updateOne(f.before[i],1); updateOne(f.after[i],2) end
end

local function scheduleNext()
    local delay
    if state.reaper==0 then delay=(state.phase==3 and P3_FIRST or P2_FIRST) else delay=NEXT_REAPER end
    state.nextNumber=state.reaper+1
    if state.nextNumber>8 then state.nextNumber=1 end
    state.nextAt=tnow()+delay
end

local function saveCorePair(pair)
    if not pair then return end
    if (state.phase==2 and state.reaper==3) or (state.phase==3 and state.reaper==1) then
        state.corePair={}
        for i=1,#pair do state.corePair[#state.corePair+1]=copy(pair[i]) end
    end
end

local function startReaper(expiration,isTest)
    local t=tnow()
    if t-state.lastApplied<0.15 then return end
    state.lastApplied=t
    state.reaper=state.reaper+1
    if state.reaper>8 then state.reaper=1 end
    state.active=true
    state.test=isTest and true or false
    state.expire=(expiration and expiration>t) and expiration or (t+REAPER_DURATION)
    if not state.plan then
        state.used={}
        local b,a,pair=buildPlan(state.phase,state.reaper,state.expire)
        state.plan={before=b,after=a}
        saveCorePair(pair)
    end
    scheduleNext()
    render()
end

local function phaseReset(p)
    state.phase=p; state.reaper=0; state.nextAt=nil; state.nextNumber=1
    state.active=false; state.expire=0; state.plan=nil; state.used={}; state.corePair=nil; state.test=false
    scheduleNext()
    if UI.frame then UI.frame:Hide() end
end

local function markSpellUsed(id)
    if not state.plan then return end
    for _,listName in ipairs({"before","after"}) do
        local list=state.plan[listName]
        for i=1,#list do
            local a=list[i]
            if a.kind=="spell" and a.id==id then state.used[key(a)]=true end
        end
    end
end

local function markItemUsed(slot)
    if not state.plan or not slot then return end
    for _,listName in ipairs({"before","after"}) do
        local list=state.plan[listName]
        for i=1,#list do
            local a=list[i]
            if a.kind=="item" and a.slot==slot then state.used[key(a)]=true end
        end
    end
end

local function hookItemUse()
    if not hooksecurefunc then return end
    if UseInventoryItem then hooksecurefunc("UseInventoryItem",function(slot) markItemUsed(slot) end) end
    if UseAction and GetActionInfo then
        hooksecurefunc("UseAction",function(action)
            local typ,id=GetActionInfo(action)
            if typ=="item" and id and state.plan then
                for _,listName in ipairs({"before","after"}) do
                    local list=state.plan[listName]
                    for i=1,#list do
                        local a=list[i]
                        if a.kind=="item" and a.id==id then state.used[key(a)]=true end
                    end
                end
            end
        end)
    end
end

local function scanReaper()
    return LichKingEncounter and LichKingEncounter.ScanSoulReaper() or nil
end

local function isLKGUID(guid)
    return LichKingEncounter and LichKingEncounter.IsBossGUID(guid) or false
end

local function findLKUnit()
    return LichKingEncounter and LichKingEncounter.FindUnit() or nil
end

local function startEncounter(guid)
    if state.encounter then return end
    state.encounter=true; state.encounterGUID=guid or findLKUnit(); state.encounterStart=tnow()
    state.phase=1; state.reaper=0; state.nextAt=nil; state.nextNumber=1; state.active=false; state.expire=0
    state.plan=nil; state.used={}; state.corePair=nil; state.test=false
end

local function stopEncounter()
    state.encounter=false; state.encounterGUID=nil; state.encounterStart=0; state.active=false; state.expire=0
    state.nextAt=nil; state.nextNumber=1; state.reaper=0; state.plan=nil; state.used={}; state.corePair=nil; state.test=false
    if UI.frame then UI.frame:Hide() end
end

local function bossStillPresent()
    if LichKingEncounter and LichKingEncounter.IsUnitPresent(state.encounterGUID) then return true end
    return findLKUnit() ~= nil
end

local function eventFrame()
    local e=CreateFrame("Frame","GP_Events",UIParent)
    e:RegisterEvent("PLAYER_LOGIN"); e:RegisterEvent("PLAYER_ENTERING_WORLD"); e:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    e:RegisterEvent("UNIT_AURA"); e:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED"); e:RegisterEvent("PLAYER_UNGHOST"); e:RegisterEvent("PLAYER_REGEN_ENABLED")
    e:RegisterEvent("UNIT_TARGET"); e:RegisterEvent("PLAYER_TARGET_CHANGED")
    hookItemUse()

    e:SetScript("OnEvent",function(self,event,...)
        if event=="PLAYER_LOGIN" or event=="PLAYER_ENTERING_WORLD" then
            if _G.Guardpoint and _G.Guardpoint.BloodDK then
                SPELL=_G.Guardpoint.BloodDK.Spells or SPELL
                ITEM=_G.Guardpoint.BloodDK.Items or ITEM
            end
            local lk=_G.Guardpoint and _G.Guardpoint.LichKing
            if lk then
                REAPER_IDS=lk.ReaperIDs or REAPER_IDS; QUAKE_ID=lk.QuakeID or QUAKE_ID; LK_BOSS_ID=lk.BossID or LK_BOSS_ID
                local timing=lk.Timing
                if timing then
                    P2_FIRST=timing.P2First or P2_FIRST; P3_FIRST=timing.P3First or P3_FIRST; NEXT_REAPER=timing.NextReaper or NEXT_REAPER
                    REAPER_DURATION=timing.ReaperDuration or REAPER_DURATION; PREWARN=timing.Prewarn or PREWARN; GLOW_LEAD=timing.GlowLead or GLOW_LEAD
                end
            end
            stopEncounter(); return
        end

        if event=="PLAYER_UNGHOST" then stopEncounter(); return end
        if event=="PLAYER_REGEN_ENABLED" then
            if state.encounter and not bossStillPresent() then stopEncounter() end
            return
        end

        if event=="UNIT_AURA" then
            local unit=...
            if unit=="player" then
                local exp=scanReaper()
                if exp then
                    if not state.encounter then startEncounter(findLKUnit()) end
                    if state.phase==1 then
                        state.phase=2; state.reaper=0; state.nextAt=nil; state.nextNumber=1; state.plan=nil; state.used={}; state.corePair=nil
                    end
                    if not state.active then startReaper(exp,false) else state.expire=exp end
                elseif state.active and not state.test then
                    state.active=false; state.plan=nil; UI.frame:Hide()
                end
            end
            return
        end

        if event=="UNIT_TARGET" or event=="PLAYER_TARGET_CHANGED" then
            if not state.encounter then
                local g=findLKUnit()
                if g and UnitAffectingCombat("player") then startEncounter(g) end
            end
            return
        end

        if event=="UNIT_SPELLCAST_SUCCEEDED" then
            local unit,_,sid=...
            if unit=="player" and sid then markSpellUsed(sid) end
            return
        end

        local subEvent=arg2; local sourceGUID=arg3; local destGUID=arg6; local spellID=arg9

        if sourceGUID and isLKGUID(sourceGUID) then
            if not state.encounter then startEncounter(sourceGUID) end
            state.encounterGUID=sourceGUID
        end

        if subEvent=="UNIT_DIED" and destGUID and state.encounterGUID and destGUID==state.encounterGUID then
            stopEncounter(); return
        end

        if spellID and REAPER_IDS[spellID] and destGUID==UnitGUID("player") then
            if subEvent=="SPELL_AURA_APPLIED" or subEvent=="SPELL_AURA_APPLIED_DOSE" then
                local exp=scanReaper(); startReaper(exp,false)
            elseif subEvent=="SPELL_AURA_REMOVED" then
                if state.active and not state.test then state.active=false; state.expire=0; state.plan=nil; state.used={}; UI.frame:Hide() end
            end
        elseif subEvent=="SPELL_CAST_START" and spellID==QUAKE_ID and state.encounter then
            if state.phase==1 then
                state.phase=2; state.reaper=0; state.nextAt=nil; state.nextNumber=1; state.active=false; state.expire=0; state.plan=nil; state.used={}; state.corePair=nil; scheduleNext(); UI.frame:Hide()
            elseif state.phase==2 then
                state.phase=3; state.reaper=0; state.nextAt=nil; state.nextNumber=1; state.active=false; state.expire=0; state.plan=nil; state.used={}; state.corePair=nil; scheduleNext(); UI.frame:Hide()
            end
        elseif subEvent=="SPELL_CAST_SUCCESS" and sourceGUID==UnitGUID("player") then
            markSpellUsed(spellID)
        end
    end)

    e:SetScript("OnUpdate",function()
        local t=tnow()
        if not state.encounter and not state.test then if UI.frame then UI.frame:Hide() end; return end
        if state.active then
            if t>=state.expire then
                state.active=false; state.test=false; state.expire=0; state.plan=nil; state.used={}; if UI.frame then UI.frame:Hide() end; return
            end
            render()
        else
            if state.nextAt then
                local left=state.nextAt-t
                if left<=PREWARN and left>0 then
                    if not state.plan then local b,a=buildPlan(state.phase,state.nextNumber,state.nextAt); state.plan={before=b,after=a} end
                    render()
                elseif left<=0 then
                    if not state.plan then local b,a=buildPlan(state.phase,state.nextNumber,t); state.plan={before=b,after=a} end
                    render()
                else
                    UI.frame:Hide()
                end
            end
        end
        updateButtonState()
    end)
end

SLASH_GUARDPOINT1="/guardpoint"
SLASH_GUARDPOINT2="/gp"
SlashCmdList["GUARDPOINT"]=function(msg)
    msg=lower(msg)
    if msg=="" or msg=="help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r: /guardpoint test | pre | p2 | p3 | reset | show | hide | lock | unlock | 4t10 on/off/auto")
    elseif msg=="test" then
        state.test=true; state.encounter=false; state.active=true; state.phase=2; state.reaper=state.reaper+1
        if state.reaper>8 then state.reaper=1 end
        state.expire=tnow()+REAPER_DURATION; state.nextAt=nil; state.used={}
        local b,a,pair=buildPlan(state.phase,state.reaper,state.expire); state.plan={before=b,after=a}; saveCorePair(pair); render()
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r test: P"..state.phase.." Жнец #"..state.reaper)
    elseif msg=="pre" then
        state.test=false; state.active=false; state.reaper=0; state.nextNumber=1; state.nextAt=tnow()+PREWARN; state.plan=nil; UI.frame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r pre: P2 Жнец #1 через 8 сек")
    elseif msg=="p2" then phaseReset(2); DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r P2")
    elseif msg=="p3" then phaseReset(3); DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r P3")
    elseif msg=="reset" then phaseReset(2); DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r reset")
    elseif msg=="show" then createUI(); UI.frame:Show(); UI.frame.timer:SetText("TEST")
    elseif msg=="hide" then UI.frame:Hide()
    elseif msg=="lock" then DB.locked=true; DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r locked")
    elseif msg=="unlock" then DB.locked=false; DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r unlocked")
    elseif msg=="4t10 on" then state.t10Override=true; DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 ON")
    elseif msg=="4t10 off" then state.t10Override=false; DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 OFF")
    elseif msg=="4t10 auto" then state.t10Override=nil; DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r 4T10 AUTO")
    else DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGP|r неизвестная команда. /guardpoint help") end
end

if DB.locked==nil then DB.locked=false end
createUI()
eventFrame()
DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r загружен. /guardpoint help")
