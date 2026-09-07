-- Guardpoint Blood Death Knight planner
local NS = _G.Guardpoint
local S = NS.State.data
local U = NS.Util
local R = NS.Resources

NS.BloodDK.Planner = NS.BloodDK.Planner or {}
local P = NS.BloodDK.Planner

function P.coreList()
    local r={}
    local fang=R.trinket("fang")
    if fang then r[#r+1]=fang end
    if R.fourT10() then
        local tap=R.spellA(R.SPELL.TAP,"tap")
        if tap then r[#r+1]=tap end
    end
    local vb=R.spellA(R.SPELL.VB,"vb")
    if vb then r[#r+1]=vb end
    return r
end
function P.chooseCorePair(deadline)
    local out={};local all=P.coreList()
    for i=1,#all do
        if R.readyBy(all[i],deadline) then U.add(out,all[i]);if #out==2 then break end end
    end
    return out
end
function P.chooseRemainingCore(deadline)
    if not S.corePair then return nil end
    local all=P.coreList()
    for i=1,#all do
        local a=all[i]
        if not U.has(S.corePair,a) and R.readyBy(a,deadline) then return U.copy(a) end
    end
end
function P.choosePreFallback(deadline,exclude)
    local candidates={R.spellA(R.SPELL.PAIN,"pain"),R.spellA(R.SPELL.SAC,"sac")}
    for i=1,#candidates do
        local a=candidates[i]
        if a and not U.has(exclude,a) and R.readyBy(a,deadline) then return a end
    end
end
function P.chooseSolo(preferredID,deadline,exclude)
    local order={}
    local function put(id,k)local a=R.spellA(id,k);if a then order[#order+1]=a end end
    put(preferredID,"preferred")
    if preferredID~=R.SPELL.IBF then put(R.SPELL.IBF,"ibf") end
    if preferredID~=R.SPELL.AMS then put(R.SPELL.AMS,"ams") end
    if preferredID~=R.SPELL.ARMY then put(R.SPELL.ARMY,"army") end
    if preferredID~=R.SPELL.PAIN then put(R.SPELL.PAIN,"pain") end
    if preferredID~=R.SPELL.SAC then put(R.SPELL.SAC,"sac") end
    for i=1,#order do local a=order[i];if not U.has(exclude,a) and R.readyBy(a,deadline) then return a end end
end
function P.chooseTrinket(deadline,exclude)
    local a=R.trinket("satrina")
    if a and not U.has(exclude,a) and R.readyBy(a,deadline) then return a end
    a=R.trinket("key")
    if a and not U.has(exclude,a) and R.readyBy(a,deadline) then return a end
end
function P.closeSpellID(name)
    if name=="ams" then return R.SPELL.AMS elseif name=="ibf" then return R.SPELL.IBF elseif name=="army" then return R.SPELL.ARMY elseif name=="pain" then return R.SPELL.PAIN elseif name=="sac" then return R.SPELL.SAC end
end
function P.buildDataPlan(plan,deadline)
    if not plan or not plan.type or not plan.close then return nil end
    local before,after,pair={}, {},nil
    if plan.type=="pair" then
        pair=P.chooseCorePair(deadline);for i=1,#pair do U.add(before,pair[i]) end
        while #before<2 do local a=P.choosePreFallback(deadline,before);if not a then break end;U.add(before,a) end
    elseif plan.type=="solo" then
        local closeID=P.closeSpellID(plan.close);if not closeID then return nil end
        local solo=P.chooseSolo(closeID,deadline,before);U.add(before,solo);U.add(after,solo);return before,after,pair
    elseif plan.type=="remaining" then
        U.add(before,P.chooseRemainingCore(deadline));if plan.extra=="trinket" then U.add(before,P.chooseTrinket(deadline,before)) end
    else return nil end
    local closeID=P.closeSpellID(plan.close);if not closeID then return nil end
    U.add(after,P.chooseSolo(closeID,deadline,before));return before,after,pair
end
function P.buildPlan(phase,n,deadline)
    local sr=NS.LichKingSoulReaper
    local dataPlan=sr and sr.GetPlan and sr.GetPlan(phase,n) or nil
    if dataPlan then local before,after,pair=P.buildDataPlan(dataPlan,deadline);if before and after then return before,after,pair end end
    return {},{},nil
end
