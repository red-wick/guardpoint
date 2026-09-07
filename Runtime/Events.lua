-- Guardpoint runtime / encounter events
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local S=NS.State.data; local U=NS.Util; local R=NS.Resources; local P=NS.Planner; local UI=NS.UI
NS.Runtime=NS.Runtime or {}; local X=NS.Runtime
local ER=NS.EncounterRegistry
local function resolveEncounter()
    if ER then local encounter=ER:Resolve();if encounter then return encounter end end
    return NS.LichKing
end
function X.GetEncounter() return resolveEncounter() end
function X.ConfigureEncounter()
    local encounter=resolveEncounter();X.Encounter=encounter
    local timing=encounter and encounter.Timing or nil
    X.Timing={P2First=(timing and timing.P2First) or 32.0,P3First=(timing and timing.P3First) or 37.5,NextReaper=(timing and timing.NextReaper) or 34.0,ReaperDuration=(timing and timing.ReaperDuration) or 5.1,Prewarn=(timing and timing.Prewarn) or 8.0,GlowLead=(timing and timing.GlowLead) or 5.0}
    return encounter
end
local function scheduleNext()
    local encounter=resolveEncounter();local timing=X.Timing or {};local delay
    if encounter and encounter.GetReaperDelay then delay=encounter.GetReaperDelay(S.phase,S.reaper) end
    if not delay then delay=S.reaper==0 and (S.phase==3 and (timing.P3First or 37.5) or (timing.P2First or 32.0)) or (timing.NextReaper or 34.0) end
    S.nextNumber=S.reaper+1;if S.nextNumber>8 then S.nextNumber=1 end;S.nextAt=U.now()+delay
end
local function saveCorePair(pair,number)
    if not pair or not number then return end
    local encounter=resolveEncounter();if encounter and encounter.ShouldSaveCorePair and encounter.ShouldSaveCorePair(S.phase,number) then S.corePair={};for i=1,#pair do S.corePair[#S.corePair+1]=U.copy(pair[i]) end end
end
local function startReaper(expiration,isTest)
    local timing=X.Timing or {};local t=U.now();if t-(S.lastApplied or 0)<0.15 then return end;S.lastApplied=t;S.reaper=S.reaper+1;if S.reaper>8 then S.reaper=1 end;S.active=true;S.test=isTest and true or false;S.expire=(expiration and expiration>t) and expiration or t+(timing.ReaperDuration or 5.1)
    if not S.plan then S.used={};local b,a,pair=P.buildPlan(S.phase,S.reaper,S.expire);S.plan={before=b,after=a};saveCorePair(pair,S.reaper) end
    scheduleNext()
    UI.render()
    if UI.frame then UI.frame:Show() end
end
local function phaseReset(p)
    S.phase=p;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.active=false;S.expire=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false;scheduleNext();if UI.frame then UI.frame:Hide() end
end
local function markSpellUsed(id)
    if not S.plan then return end
    for _,name in ipairs({"before","after"}) do local list=S.plan[name] or {};for i=1,#list do local a=list[i];if a.kind=="spell" and a.id==id then S.used[U.key(a)]=true end end end
end
local function markItemUsed(slot)
    if not S.plan or not slot then return end
    for _,name in ipairs({"before","after"}) do local list=S.plan[name] or {};for i=1,#list do local a=list[i];if a.kind=="item" and a.slot==slot then S.used[U.key(a)]=true end end end
end
local function hookItemUse()
    if not hooksecurefunc or X.itemHooks then return end
    X.itemHooks=true
    if UseInventoryItem then hooksecurefunc("UseInventoryItem",function(slot) markItemUsed(slot) end) end
    if UseAction and GetActionInfo then hooksecurefunc("UseAction",function(action)local typ,id=GetActionInfo(action);if typ=="item" and id and S.plan then for _,name in ipairs({"before","after"}) do local list=S.plan[name] or {};for i=1,#list do local a=list[i];if a.kind=="item" and a.id==id then S.used[U.key(a)]=true end end end end end) end
end
local function scanReaper() local encounter=resolveEncounter();return encounter and encounter.ScanSoulReaper and encounter.ScanSoulReaper() or nil end
local function findLKUnit() local encounter=resolveEncounter();return encounter and encounter.FindUnit and encounter.FindUnit() or nil end
local function startEncounter(guid)
    if S.encounter then return end
    local encounter=resolveEncounter();S.encounter=true;S.encounterGUID=guid or (encounter and encounter.FindUnit and encounter.FindUnit()) or nil;S.encounterStart=U.now();S.phase=1;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.active=false;S.expire=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false
    scheduleNext()
end
local function stopEncounter()
    S.encounter=false;S.encounterGUID=nil;S.encounterStart=0;S.active=false;S.expire=0;S.nextAt=nil;S.nextNumber=1;S.reaper=0;S.plan=nil;S.used={};S.corePair=nil;S.test=false;if UI.frame then UI.frame:Hide() end
end
local function bossStillPresent()
    local encounter=resolveEncounter();if encounter and encounter.IsUnitPresent and encounter.IsUnitPresent(S.encounterGUID) then return true end
    return findLKUnit()~=nil
end
function X.phaseReset(p) phaseReset(p) end
function X.initialize()
    if X.frame then return true end
    X.ConfigureEncounter();UI.create()
    local e=_G.GP_Events
    if not e then e=CreateFrame("Frame","GP_Events_Modular",UIParent) end
    X.frame=e;e:UnregisterAllEvents()
    e:RegisterEvent("PLAYER_LOGIN");e:RegisterEvent("PLAYER_ENTERING_WORLD");e:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");e:RegisterEvent("UNIT_AURA");e:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");e:RegisterEvent("PLAYER_UNGHOST");e:RegisterEvent("PLAYER_REGEN_ENABLED");e:RegisterEvent("UNIT_TARGET");e:RegisterEvent("PLAYER_TARGET_CHANGED");hookItemUse()
    e:SetScript("OnEvent",function(self,event,...)
        if event=="PLAYER_LOGIN" or event=="PLAYER_ENTERING_WORLD" then R.ConfigureActiveClass();X.ConfigureEncounter();stopEncounter();return end
        if event=="PLAYER_UNGHOST" then stopEncounter();return end
        if event=="PLAYER_REGEN_ENABLED" then if S.encounter and not bossStillPresent() then stopEncounter() end;return end
        if event=="UNIT_AURA" then local unit=...;if unit=="player" then local exp=scanReaper();if exp then if not S.encounter then startEncounter(findLKUnit()) end;if S.phase==1 then S.phase=2;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.plan=nil;S.used={};S.corePair=nil end;if not S.active then startReaper(exp,false) else S.expire=exp;UI.render();if UI.frame then UI.frame:Show() end end end end;return end
        if event=="UNIT_TARGET" or event=="PLAYER_TARGET_CHANGED" then if not S.encounter then local g=findLKUnit();if g and UnitAffectingCombat("player") then startEncounter(g) end end;return end
        if event=="UNIT_SPELLCAST_SUCCEEDED" then local unit,_,sid=...;if unit=="player" and sid then markSpellUsed(sid) end;return end
        local subEvent=arg2;local sourceGUID=arg3;local destGUID=arg6;local spellID=arg9;local encounter=resolveEncounter()
        if sourceGUID and encounter and encounter.IsBossGUID and encounter.IsBossGUID(sourceGUID) then if not S.encounter then startEncounter(sourceGUID) end;S.encounterGUID=sourceGUID end
        if subEvent=="UNIT_DIED" and destGUID and S.encounterGUID and destGUID==S.encounterGUID then stopEncounter();return end
        if spellID and encounter and encounter.IsReaperSpell and encounter.IsReaperSpell(spellID) and destGUID==UnitGUID("player") then
            if subEvent=="SPELL_AURA_APPLIED" or subEvent=="SPELL_AURA_APPLIED_DOSE" then startReaper(scanReaper(),false)
            elseif subEvent=="SPELL_AURA_REMOVED" and S.active and not S.test then S.active=false;S.expire=0;S.plan=nil;S.used={};UI.frame:Hide() end
        elseif subEvent=="SPELL_CAST_START" and encounter and encounter.IsQuakeSpell and encounter.IsQuakeSpell(spellID) and S.encounter and (S.phase==1 or S.phase==2) then
            S.phase=S.phase+1;S.reaper=0;S.nextAt=nil;S.nextNumber=1;S.active=false;S.expire=0;S.plan=nil;S.used={};S.corePair=nil;scheduleNext();UI.frame:Hide()
        elseif subEvent=="SPELL_CAST_SUCCESS" and sourceGUID==UnitGUID("player") then markSpellUsed(spellID) end
    end)
    e:SetScript("OnUpdate",function()
        local t=U.now();if not S.encounter and not S.test and not S.active then if UI.frame then UI.frame:Hide() end;return end
        if S.active then if t>=S.expire then S.active=false;S.test=false;S.expire=0;S.plan=nil;S.used={};if UI.frame then UI.frame:Hide() end;return end;UI.render();if UI.frame then UI.frame:Show() end
        elseif S.nextAt then local left=S.nextAt-t;if left<=(X.Timing.Prewarn or 8.0) and left>0 then if not S.plan then local b,a,pair=P.buildPlan(S.phase,S.nextNumber,S.nextAt);S.plan={before=b,after=a};saveCorePair(pair,S.nextNumber) end;UI.render() elseif left<=0 then if not S.plan then local b,a,pair=P.buildPlan(S.phase,S.nextNumber,t);S.plan={before=b,after=a};saveCorePair(pair,S.nextNumber) end;UI.render() else UI.frame:Hide() end end;UI.updateButtonState()
    end)
    return true
end
