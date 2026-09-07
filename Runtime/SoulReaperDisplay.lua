-- Guardpoint Soul Reaper display
-- Independent display path for WoW 3.3.5a.
-- UNIT_AURA is authoritative here because it directly exposes the player's debuff.

local REAPER_IDS={ [69409]=true, [73797]=true, [73798]=true, [73799]=true }
local f=CreateFrame("Frame","GP_SR_Display",UIParent)
f:SetWidth(260);f:SetHeight(74);f:SetFrameStrata("TOOLTIP");f:SetToplevel(true);f:SetClampedToScreen(true);f:SetPoint("CENTER",UIParent,"CENTER",0,-120)
if f.SetBackdrop then
    f:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
    f:SetBackdropColor(0,0,0,0.92);f:SetBackdropBorderColor(0.2,0.65,1,1)
end
f.title=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");f.title:SetPoint("TOP",f,"TOP",0,-8);f.title:SetTextColor(1,0.85,0.25,1);f.title:SetShadowColor(0,0,0,1);f.title:SetShadowOffset(1,-1)
f.timer=f:CreateFontString(nil,"OVERLAY","NumberFontNormalHuge");f.timer:SetPoint("BOTTOM",f,"BOTTOM",0,7);f.timer:SetTextColor(1,1,1,1);f.timer:SetShadowColor(0,0,0,1);f.timer:SetShadowOffset(1,-1);f:Hide()

local activeUntil=0
local number=0

local function scanReaper()
    for i=1,40 do
        local _,_,_,_,_,duration,expiration,_,_,_,spellID=UnitDebuff("player",i)
        if spellID and REAPER_IDS[spellID] then
            return expiration or (GetTime()+(duration or 5.1))
        end
    end
end

local function showReaper(expiration)
    local now=GetTime()
    if not expiration or expiration<=now then return end
    number=number+1
    if number>8 then number=1 end
    activeUntil=expiration
    f.title:SetText(string.format("SOUL REAPER #%d",number))
    f.timer:SetText(string.format("%.1f",math.max(0,expiration-now)))
    f:Show();f:SetAlpha(1)
end

local function clearReaper()
    activeUntil=0
    f:Hide()
end

f:RegisterEvent("UNIT_AURA")
f:SetScript("OnEvent",function(self,event,...)
    if event~="UNIT_AURA" then return end
    local unit=...
    if unit~="player" then return end
    local expiration=scanReaper()
    if expiration then
        if activeUntil<=GetTime() then
            showReaper(expiration)
        else
            activeUntil=expiration
            f.timer:SetText(string.format("%.1f",math.max(0,expiration-GetTime())))
            f:Show();f:SetAlpha(1)
        end
    elseif activeUntil>0 then
        clearReaper()
    end
end)

f:SetScript("OnUpdate",function(self)
    if activeUntil<=0 then return end
    local left=activeUntil-GetTime()
    if left<=0 then clearReaper();return end
    f.timer:SetText(string.format("%.1f",left))
end)

_G.GP_SR_Display=f
