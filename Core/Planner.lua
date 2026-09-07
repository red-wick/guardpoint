-- Guardpoint plan builder
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS
local S = NS.State.data
local U = NS.Util
local R = NS.Resources

NS.Planner = NS.Planner or {}
local P = NS.Planner

local function config()
    return R.Class and R.Class.Planner
end

function P.coreList()
    local C = config()
    if not C or not C.Core then return {} end

    local r={}
    local core=C.Core

    for i=1,#(core.Trinkets or {}) do
        local a=R.trinket(core.Trinkets[i])
        if a then r[#r+1]=a end
    end

    for i=1,#(core.Spells or {}) do
        local name=core.Spells[i]
        local requiresT10=false
        for j=1,#(core.FourT10Spells or {}) do
            if core.FourT10Spells[j]==name then
                requiresT10=true
                break
            end
        end
        if not requiresT10 or R.fourT10() then
            local a=R.spellA(R.spellID(name),string.lower(name))
            if a then r[#r+1]=a end
        end
    end

    return r
end

function P.chooseCorePair(deadline)
    local out={}
    local all=P.coreList()
    for i=1,#all do
        if R.readyBy(all[i],deadline) then
            U.add(out,all[i])
            if #out==2 then break end
        end
    end
    return out
end

function P.chooseRemainingCore(deadline)
    if not S.corePair then return nil end
    local all=P.coreList()
    for i=1,#all do
        local a=all[i]
        if not U.has(S.corePair,a) and R.readyBy(a,deadline) then
            return U.copy(a)
        end
    end
end

function P.choosePreFallback(deadline,exclude)
    local C=config()
    local candidates={}
    for i=1,#((C and C.PreFallback) or {}) do
        local name=C.PreFallback[i]
        candidates[#candidates+1]=R.spellA(R.spellID(name),string.lower(name))
    end
    for i=1,#candidates do
        local a=candidates[i]
        if a and not U.has(exclude,a) and R.readyBy(a,deadline) then
            return a
        end
    end
end

function P.chooseSolo(preferredName,deadline,exclude)
    local C=config()
    local order={}

    local function put(name,keyName)
        local a=R.spellA(R.spellID(name),keyName or string.lower(name))
        if a then order[#order+1]=a end
    end

    if preferredName then
        put(preferredName,"preferred")
    end

    for i=1,#((C and C.SoloPriority) or {}) do
        local name=C.SoloPriority[i]
        if not preferredName or string.upper(name)~=string.upper(preferredName) then
            put(name,string.lower(name))
        end
    end

    for i=1,#order do
        local a=order[i]
        if not U.has(exclude,a) and R.readyBy(a,deadline) then
            return a
        end
    end
end

function P.chooseTrinket(deadline,exclude)
    local C=config()
    for i=1,#((C and C.Trinkets) or {}) do
        local a=R.trinket(C.Trinkets[i])
        if a and not U.has(exclude,a) and R.readyBy(a,deadline) then
            return a
        end
    end
end

function P.soulReaperPlan(phase,n)
    local encounter
    if NS.EncounterRegistry then
        encounter=NS.EncounterRegistry:Resolve()
    end
    if encounter and encounter.GetSoulReaperPlan then
        return encounter:GetSoulReaperPlan(phase,n)
    end
    if encounter and encounter.GetSoulReaper then
        local sr=encounter:GetSoulReaper()
        if sr and sr.GetPlan then return sr.GetPlan(phase,n) end
    end
    local sr=NS.LichKingSoulReaper
    if sr and sr.GetPlan then return sr.GetPlan(phase,n) end
end

function P.closeSpellID(name)
    return R.spellID(name)
end

function P.buildDataPlan(plan,deadline)
    if not plan or not plan.type or not plan.close then return nil end

    local before,after,pair={}, {},nil
    if plan.type=="pair" then
        pair=P.chooseCorePair(deadline)
        for i=1,#pair do U.add(before,pair[i]) end
        while #before<2 do
            local a=P.choosePreFallback(deadline,before)
            if not a then break end
            U.add(before,a)
        end
    elseif plan.type=="solo" then
        local solo=P.chooseSolo(plan.close,deadline,before)
        if not solo then return nil end
        U.add(before,solo)
        U.add(after,solo)
        return before,after,pair
    elseif plan.type=="remaining" then
        U.add(before,P.chooseRemainingCore(deadline))
        if plan.extra=="trinket" then
            U.add(before,P.chooseTrinket(deadline,before))
        end
    else
        return nil
    end

    local close=P.chooseSolo(plan.close,deadline,before)
    U.add(after,close)
    return before,after,pair
end

function P.buildPlan(phase,n,deadline)
    local dataPlan=P.soulReaperPlan(phase,n)
    if not dataPlan then return {},{},nil end

    local before,after,pair=P.buildDataPlan(dataPlan,deadline)
    if before and after then return before,after,pair end

    return {},{},nil
end
