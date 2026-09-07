-- Guardpoint modular activation bridge
local NS = _G.Guardpoint or {}
_G.Guardpoint = NS

-- Create the migration-safe Soul Reaper host before the runtime starts.
-- It is deliberately independent from both legacy and modular UI objects.
if not _G.GP_SoulReaperHost then
    local f=CreateFrame("Frame","GP_SoulReaperHost",UIParent)
    f:SetWidth(190);f:SetHeight(76);f:SetPoint("CENTER",UIParent,"CENTER",0,-140)
    f:SetFrameStrata("TOOLTIP");f:SetAlpha(1);f:Show()
    if f.SetBackdrop then
        f:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=12,insets={left=3,right=3,top=3,bottom=3}})
        f:SetBackdropColor(0,0,0,0.85);f:SetBackdropBorderColor(0.35,0.65,1,1)
    end
    f.text=f:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    f.text:SetPoint("CENTER",f,"CENTER",0,0);f.text:SetTextColor(1,0.86,0.35,1);f.text:SetText("")
    f:Hide()
    _G.GP_SoulReaperHost=f
end

if NS.Runtime and NS.Runtime.initialize then
    NS.Runtime.initialize()
end

if NS.Runtime and NS.Runtime.RegisterCommands then
    NS.Runtime.RegisterCommands()
end

DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGuardpoint|r modular runtime active")
