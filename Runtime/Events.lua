-- Guardpoint runtime / encounter events
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

NS.Runtime = NS.Runtime or {}
local X = NS.Runtime

local function state() return NS.State.data end
local function util() return NS.Util end
local function resources() return NS.Resources end
local function planner() return NS.Planner end
local function ui() return NS.UI end
local function encounter() return NS.EncounterRegistry and NS.EncounterRegistry:GetActive() end

local function scheduleNext()
    local S,U,LK=state(),util(),encounter()
    if not LK then return end
    local timing=LK.Timing
    local delay
    if S.reaper==0 then delay=(S.phase==3 and timing.P3First or timing.P2First) else delay=timing.NextReaper end
    S.nextNumber=S.reaper+1
    if S.nextNumber>8 then S.nextNumber=1 end
    S.nextAt=U.now()+delay
end

local function saveCorePair(pair,number)
    local S,U=state(),util()
    if not pair or not number then return end
    if (S.phase==2 and number==3) or (S.phase==3 and number==1) then
        S.corePair={}
        for i=1,#pair do S.corePair[#S.corePair+1]=U.copy(pair[i]) end
    end
end

local function startReaper(expiration,isTest)
    local S,U,P,UI,LK=state(),util(),planner(),ui(),encounter()
    if not LK then return end
    local t=U.now()
    if t-S.lastApplied<0.15 then return end
    S.lastApplied=t
    S.reaper=S.reaper+1
    if S.reaper>8 then S.reaper=1 end
    S.active=true
    S.test=isTest and true or false
    S.expire=(expiration and expiration>t) and expiration or (t+LK.Timing.ReaperDuration)
    if not S.plan then
        S.used={}
        local b,a,pair=P.buildPlan(S.phase,S.reaper,S.expire)
        S.plan={before=b,after=a}
        saveCorePair(pair,S.reaper)
    end
    scheduleNext()
    UI.render()
end

local function resetPhase(p)
    local S,U,UI=state(),util(),ui()
    S.phase=p;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.active=false;S.expire=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false
    scheduleNext()
    if UI.frame then UI.frame:Hide() end
end

local function markSpellUsed(id)
    local S,U=state(),util()
    if not S.plan then return end
    for _,name in ipairs({"before","after"}) do
        local list=S.plan[name] or {}
        for i=1,#list do
            local a=list[i]
            if a.kind=="spell" and a.id==id then S.used[U.key(a)]=true end
        end
    end
end

local function markItemUsed(slot)
    local S,U=state(),util()
    if not S.plan or not slot then return end
    for _,name in ipairs({"before","after"}) do
        local list=S.plan[name] or {}
        for i=1,#list do
            local a=list[i]
            if a.kind=="item" and a.slot==slot then S.used[U.key(a)]=true end
        end
    end
end

local function hookItemUse()
    if not hooksecurefunc then return end
    if UseInventoryItem then hooksecurefunc("UseInventoryItem",function(slot) markItemUsed(slot) end) end
    if UseAction and GetActionInfo then
        hooksecurefunc("UseAction",function(action)
            local typ,id=GetActionInfo(action)
            if typ~="item" or not id then return end
            local S,U=state(),util()
            if not S.plan then return end
            for _,name in ipairs({"before","after"}) do
                local list=S.plan[name] or {}
                for i=1,#list do
                    local a=list[i]
                    if a.kind=="item" and a.id==id then S.used[U.key(a)]=true end
                end
            end
        end)
    end
end

local function findBossUnit()
    local LK=encounter()
    return LK and LK.FindUnit() or nil
end

local function scanReaper()
    local LK=encounter()
    return LK and LK.ScanSoulReaper() or nil
end

local function startEncounter(guid)
    local S,U=state(),util()
    if S.encounter then return end
    S.encounter=true;S.encounterGUID=guid or findBossUnit();S.encounterStart=U.now()
    S.phase=1;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.active=false;S.expire=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false
end

local function stopEncounter()
    local S,UI=state(),ui()
    S.encounter=false;S.encounterGUID=nil;S.encounterStart=0;S.active=false;S.expire=0;S.nextAt=nil;S.nextNumber=1;S.reaper=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false
    if UI.frame then UI.frame:Hide() end
end

local function bossStillPresent()
    local S=state();local LK=encounter()
    return LK and (LK.IsUnitPresent(S.encounterGUID) or LK.FindUnit()~=nil) or false
end

local function refreshModules()
    if NS.ClassRegistry then NS.ClassRegistry:Detect() end
    if NS.Resources and NS.ClassRegistry then NS.Resources.Configure(NS.ClassRegistry:GetActive()) end
    if NS.EncounterRegistry then NS.EncounterRegistry:Detect() end
end

function X.phaseReset(p) resetPhase(p) end

function X.initialize()
    if X.frame then return end
    refreshModules()
    ui().create()
    local e=CreateFrame("Frame","GP_Events",UIParent)
    X.frame=e
    e:RegisterEvent("PLAYER_LOGIN");e:RegisterEvent("PLAYER_ENTERING_WORLD")
    e:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");e:RegisterEvent("UNIT_AURA")
    e:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");e:RegisterEvent("PLAYER_UNGHOST")
    e:RegisterEvent("PLAYER_REGEN_ENABLED");e:RegisterEvent("UNIT_TARGET")
    e:RegisterEvent("PLAYER_TARGET_CHANGED")
    hookItemUse()

    e:SetScript("OnEvent",function(self,event,...)
        local S,U,P,UI=state(),util(),planner(),ui()
        if event=="PLAYER_LOGIN" or event=="PLAYER_ENTERING_WORLD" then
            refreshModules();stopEncounter();return
        end
        if event=="PLAYER_UNGHOST" then stopEncounter();return end
        if event=="PLAYER_REGEN_ENABLED" then
            if S.encounter and not bossStillPresent() then stopEncounter() end
            return
        end
        local LK=encounter()
        if not LK then return end

        if event=="UNIT_AURA" then
            local unit=...
            if unit=="player" then
                local exp=scanReaper()
                if exp then
                    if not S.encounter then startEncounter(findBossUnit()) end
                    if S.phase==1 then
                        S.phase=2;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.plan=nil;S.used={};S.corePair=nil
                    end
                    if not S.active then startReaper(exp,false) else S.expire=exp end
                elseif S.active and not S.test then
                    S.active=false;S.plan=nil;UI.frame:Hide()
                end
            end
            return
        end

        if event=="UNIT_TARGET" or event=="PLAYER_TARGET_CHANGED" then
            if not S.encounter then
                local g=findBossUnit()
                if g and UnitAffectingCombat("player") then startEncounter(g) end
            end
            return
        end

        if event=="UNIT_SPELLCAST_SUCCEEDED" then
            local unit,_,sid=...
            if unit=="player" and sid then markSpellUsed(sid) end
            return
        end

        local subEvent=arg2;local sourceGUID=arg3;local destGUID=arg6;local spellID=arg9
        if sourceGUID and LK.IsBossGUID(sourceGUID) then
            if not S.encounter then startEncounter(sourceGUID) end
            S.encounterGUID=sourceGUID
        end
        if subEvent=="UNIT_DIED" and destGUID and S.encounterGUID and destGUID==S.encounterGUID then stopEncounter();return end

        if spellID and LK.ReaperIDs[spellID] and destGUID==UnitGUID("player") then
            if subEvent=="SPELL_AURA_APPLIED" or subEvent=="SPELL_AURA_APPLIED_DOSE" then
                startReaper(scanReaper(),false)
            elseif subEvent=="SPELL_AURA_REMOVED" then
                if S.active and not S.test then S.active=false;S.expire=0;S.plan=nil;S.used={};UI.frame:Hide() end
            end
        elseif subEvent=="SPELL_CAST_START" and spellID==LK.QuakeID and S.encounter then
            if S.phase==1 then resetPhase(2) elseif S.phase==2 then resetPhase(3) end
        elseif subEvent=="SPELL_CAST_SUCCESS" and sourceGUID==UnitGUID("player") then
            markSpellUsed(spellID)
        end
    end)

    e:SetScript("OnUpdate",function()
        local S,U,P,UI,LK=state(),util(),planner(),ui(),encounter()
        local t=U.now()
        if not S.encounter and not S.test then UI.frame:Hide();return end
        if not LK then UI.frame:Hide();return end
        if S.active then
            if t>=S.expire then
                S.active=false;S.test=false;S.expire=0;S.plan=nil;S.used={};UI.frame:Hide();return
            end
            UI.render()
        elseif S.nextAt then
            local left=S.nextAt-t
            if left<=LK.Timing.Prewarn and left>0 then
                if not S.plan then
                    local b,a,pair=P.buildPlan(S.phase,S.nextNumber,S.nextAt);S.plan={before=b,after=a};saveCorePair(pair,S.nextNumber)
                end
                UI.render()
            elseif left<=0 then
                if not S.plan then
                    local b,a,pair=P.buildPlan(S.phase,S.nextNumber,t);S.plan={before=b,after=a};saveCorePair(pair,S.nextNumber)
                end
                UI.render()
            else UI.frame:Hide() end
        end
        UI.updateButtonState()
    end)
end
