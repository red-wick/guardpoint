-- Guardpoint Soul Reaper display
-- Independent display path for WoW 3.3.5a.
-- This intentionally does not depend on Runtime/Events.lua or UI/Main.lua.

local function scanSoulReaper()
    local ids={ [69409]=true, [73797]=true, [73798]=true, [73799]=true }
    for i=1,40 do
        local _,_,_,_,_,duration,expiration,_,_,_,spellID=UnitDebuff("player",i)
        if spellID and ids[spellID] then
            return expiration or (GetTime()+(duration or 5.1)),spellID
        end
    end
end

local f=CreateFrame("Frame","GP_SR_Display",UIParent)
f:SetWidth(260)
f:SetHeight(74)
f:SetFrameStrata("TOOLTIP")
f:SetToplevel(true)
f:SetClampedToScreen(true)
f:SetPoint("CENTER",UIParent,"CENTER",0,-120)
if f.SetBackdrop then
    f:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
    f:SetBackdropColor(0,0,0,0.92)
    f:SetBackdropBorderColor(0.2,0.65,1,1)
end

f.title=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
f.title:SetPoint("TOP",f,"TOP",0,-8)
f.title:SetTextColor(1,0.85,0.25,1)
f.title:SetShadowColor(0,0,0,1)
f.title:SetShadowOffset(1,-1)

f.timer=f:CreateFontString(nil,"OVERLAY","NumberFontNormalHuge")
f.timer:SetPoint("BOTTOM",f,"BOTTOM",0,7)
f.timer:SetTextColor(1,1,1,1)
f.timer:SetShadowColor(0,0,0,1)
f.timer:SetShadowOffset(1,-1)
f:Hide()

local activeUntil=0
local number=0
local lastExpiration=0

local function showReaper(expiration)
    local now=GetTime()
    if expiration<=now then return end
    if expiration~=lastExpiration then
        number=number+1
        if number>8 then number=1 end
        lastExpiration=expiration
    end
    activeUntil=expiration
    f.title:SetText(string.format("SOUL REAPER #%d",number))
    f.timer:SetText(string.format("%.1f",math.max(0,expiration-now)))
    f:Show()
end

f:RegisterEvent("UNIT_AURA")
f:SetScript("OnEvent",function(self,event,unit)
    if event~="UNIT_AURA" or unit~="player" then return end
    local expiration=scanSoulReaper()
    if expiration then
        showReaper(expiration)
    elseif activeUntil>0 and GetTime()>=activeUntil then
        activeUntil=0
        f:Hide()
    end
end)

f:SetScript("OnUpdate",function(self)
    if activeUntil<=0 then
        if self:IsShown() then self:Hide() end
        return
    end
    local left=activeUntil-GetTime()
    if left<=0 then
        activeUntil=0
        self:Hide()
        return
    end
    self.timer:SetText(string.format("%.1f",left))
end)

_G.GP_SR_Display=f
