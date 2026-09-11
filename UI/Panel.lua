Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

UI.Panel = UI.Panel or CreateFrame("Frame", "GuardpointPanel", UI.Root)

function UI.Panel:Initialize()
    self:SetParent(UI.Root)
    self:SetWidth(320)
    self:SetHeight(80)
    self:SetPoint("CENTER", UI.Root, "CENTER", 0, 0)
    self:SetFrameLevel(UI.Root:GetFrameLevel() + 1)
    UI.Styles:ApplyFrame(self)
    self:Hide()
end

function UI.Panel:ShowPanel()
    self:Show()
end

function UI.Panel:HidePanel()
    self:Hide()
end

UI.Panel:Initialize()
