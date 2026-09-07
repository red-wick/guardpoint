-- Guardpoint player resources
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

local S = NS.State and NS.State.data
local U = NS.Util

NS.Resources = NS.Resources or {}
local R = NS.Resources
R.SPELL = R.SPELL or {}
R.ITEM = R.ITEM or {}

function R.Configure(classModule)
    classModule = classModule or {}
    R.SPELL = classModule.Spells or {}
    R.ITEM = classModule.Items or {}
    R.Class = classModule
end

function R.spellExists(id) return id and GetSpellInfo(id) ~= nil end
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
        slot=R.equippedByText({"синдрагос","sindragosa"})
    elseif kind=="satrina" then
        slot=R.equippedExact(R.ITEM.SATRINA_N) or R.equippedExact(R.ITEM.SATRINA_H)
    elseif kind=="key" then
        slot=R.equippedExact(R.ITEM.KEY)
    end
    if not slot then return nil end
    return {kind="item",key=kind,id=R.itemID(slot),slot=slot}
end
function R.fourT10()
    if S and S.t10Override ~= nil then return S.t10Override end
    if not R.tip then
        R.tip=CreateFrame("GameTooltip","GP_T10Scan",UIParent,"GameTooltipTemplate")
        R.tip:SetOwner(UIParent,"ANCHOR_NONE")
    end
    local count=0
    for _,slot in ipairs({1,3,5,7,10}) do
        local id=R.itemID(slot)
        if id then
            local found=false
            local n=U.lower(R.itemName(slot))
            if string.find(n,"плет",1,true) or string.find(n,"scourgelord",1,true) then
                found=true
            else
                R.tip:ClearLines(); R.tip:SetInventoryItem("player",slot)
                for line=1,R.tip:NumLines() do
                    local obj=_G["GP_T10ScanTextLeft"..line]
                    local txt=obj and U.lower(obj:GetText()) or ""
                    if string.find(txt,"плет",1,true) or string.find(txt,"scourgelord",1,true) then found=true; break end
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
    if not a or (U.isUsed and U.isUsed(a)) then return false end
    local c=a.kind=="item" and R.itemCD(a.slot) or R.spellCD(a.id)
    return c <= math.max(0,deadline-U.now()) + 0.10
end
