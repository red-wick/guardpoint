Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

if not UI.Root then
    UI.Root = CreateFrame("Frame", "GuardpointRoot", UIParent)
end

function UI.Root:Initialize()
    self:SetParent(UIParent)
    self:SetFrameStrata("MEDIUM")
    self:SetScale(Guardpoint.Config:Get("scale") or 1)
    self:Hide()
end

function UI.Root:SetScaleValue(scale)
    if type(scale) ~= "number" or scale <= 0 then
        return false
    end

    Guardpoint.Config:Set("scale", scale)
    self:SetScale(scale)
    return true
end

UI.Root:Initialize()
