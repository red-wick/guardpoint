-- Guardpoint player resources
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS
local S = NS.State and NS.State.data
local U = NS.Util

NS.Resources = NS.Resources or {}
local R = NS.Resources

R.SPELL = R.SPELL or {
    TAP=45529, VB=55233, AMS=48707, IBF=48792, ARMY=42650, PAIN=33206, SAC=6940,
}
R.ITEM = R.ITEM or {
    FANG_N=50361, FANG_H=50364, SATRINA_N=47080, SATRINA_H=47088, KEY=50356,
}
R.Class = R.Class or nil

function R.Configure(classModule)
    if not classModule then return end
    R.Class = classModule
    if classModule.Spells then R.SPELL = classModule.Spells end
    if classModule.Items then R.ITEM = classModule.Items end
end

function R.ConfigureActiveClass()
    if NS.ClassRegistry then
        local classModule = NS.ClassRegistry:GetActive()
        if not classModule and NS.ClassRegistry.Detect then
            classModule = NS.ClassRegistry:Detect()
        end
        if classModule then
            R.Configure(classModule)
            return classModule
        end
    end
    return nil
end

function R.spellExists(id) return GetSpellInfo(id) ~= nil end
function R.spellIcon(id)
    local _,_,tex=GetSpellInfo(id)
    return tex or "Interface\\Icons\\INV_Misc_QuestionMark"
end
function R.spellCD(id)
    local s,d,e=GetSpellCooldown(id)
    if not s or not d or not e or s==0 or d==0 or e==0 then return 0 end
    return math.max(0,s+d-U.now())
end
function R.itemID(slot) return GetInventoryItemID("player",slot) end
function R.itemName(slot)
    local id=R.itemID(slot)
    if not id then return "" end
    return GetItemInfo(id) or ""
end
function R.itemIcon(slot)
    local id=R.itemID(slot)
    if not id then return nil end
    local _,_,_,_,_,_,_,_,_,tex=GetItemInfo(id)
    return tex or GetInventoryItemTexture("player",slot)
end
function R.itemCD(slot)
    local s,d,e=GetInventoryItemCooldown("player",slot)
    if not s or not d or not e or s==0 or d==0 or e==0 then return 0 end
    return math.max(0,s+d-U.now())
end
function R.equippedExact(id)
    if R.itemID(13)==id then return 13 end
    if R.itemID(14)==id then return 14 end
end
function R.equippedByText(parts)
    for _,slot in ipairs({13,14}) do
        local n=U.lower(R.itemName(slot))
        for _,p in ipairs(parts) do
            if string.find(n,U.lower(p),1,true) then return slot end
        end
    end
end
function R.trinket(kind)
    local slot
    if kind=="fang" then
        local names=R.Class and R.Class.Trinkets and R.Class.Trinkets.fang and R.Class.Trinkets.fang.Names
        if names then slot=R.equippedByText(names) end
    elseif kind=="satrina" then
        slot=R.equippedExact(R.ITEM.SATRINA_N) or R.equippedExact(R.ITEM.SATRINA_H)
    elseif kind=="key" then
        slot=R.equippedExact(R.ITEM.KEY)
    end
    if not slot then return nil end
    return {kind="item",key=kind,id=R.itemID(slot),slot=slot}
end
function R.fourT10()
    if S.t10Override ~= nil then return S.t10Override end
    if not R.Class or not R.Class.Features or not R.Class.Features.FourT10 then
        return false
    end
    local markers = R.Class.Features.FourT10Markers
    if not markers or #markers == 0 then return false end
    if not R.tip then
        R.tip=CreateFrame("GameTooltip","GP_T10Scan",UIParent,"GameTooltipTemplate")
        R.tip:SetOwner(UIParent,"ANCHOR_NONE")
    end
    local function hasMarker(text)
        for _,marker in ipairs(markers) do
            if string.find(text,U.lower(marker),1,true) then return true end
        end
        return false
    end
    local count=0
    for _,slot in ipairs({1,3,5,7,10}) do
        local id=R.itemID(slot)
        if id then
            local found=false
            local n=U.lower(R.itemName(slot))
            if hasMarker(n) then
                found=true
            else
                R.tip:ClearLines(); R.tip:SetInventoryItem("player",slot)
                for line=1,R.tip:NumLines() do
                    local obj=_G["GP_T10ScanTextLeft"..line]
                    local txt=obj and U.lower(obj:GetText()) or ""
                    if hasMarker(txt) then found=true; break end
                end
            end
            if found then count=count+1 end
        end
    end
    return count>=4
end
function R.spellA(id,key)
    if not R.spellExists(id) then return nil end
    return {kind="spell",id=id,key=key}
end
function R.readyBy(a,deadline)
    if not a or U.isUsed(a) then return false end
    local c
    if a.kind=="item" then c=R.itemCD(a.slot) else c=R.spellCD(a.id) end
    return c <= math.max(0,deadline-U.now()) + 0.10
end
