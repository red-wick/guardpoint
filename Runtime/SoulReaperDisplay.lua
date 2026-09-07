-- Guardpoint Soul Reaper display
-- Independent display path for WoW 3.3.5a.
-- Combat log is the authoritative source for applying the debuff.

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
local lastApplyAt=0

local function showReaper(expiration)
    local now=GetTime()
    if not expiration or expiration<=now then return end
    if now-lastApplyAt>0.20 then
        number=number+1
        if number>8 then number=1 end
        lastApplyAt=now
    end
    activeUntil=expiration
    f.title:SetText(string.format("SOUL REAPER #%d",number))
    f.timer:SetText(string.format("%.1f",math.max(0,expiration-now)))
    f:Show();f:SetAlpha(1)
end

local function clearReaper()
    activeUntil=0
    f:Hide()
end

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("UNIT_AURA")
f:SetScript("OnEvent",function(self,event,...)
    if event=="UNIT_AURA" then
        local unit=...
        if unit~="player" then return end
        -- UNIT_AURA is only a fallback/synchronizer. It must not increment
        -- the counter while the aura is already being handled by combat log.
        if activeUntil>GetTime() then return end
        return
    end

    local timestamp,subEvent,hideCaster,sourceGUID,sourceName,sourceFlags,destGUID,destName,destFlags,spellID=...
    if destGUID~=UnitGUID("player") or not spellID or not REAPER_IDS[spellID] then return end
    if subEvent=="SPELL_AURA_APPLIED" or subEvent=="SPELL_AURA_APPLIED_DOSE" then
        local expiration
        for i=1,40 do
            local _,_,_,_,_,duration,exp,_,_,_,sid=UnitDebuff("player",i)
            if sid and REAPER_IDS[sid] then expiration=exp or (GetTime()+(duration or 5.1));break end
        end
        showReaper(expiration or (GetTime()+5.1))
    elseif subEvent=="SPELL_AURA_REMOVED" then
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
