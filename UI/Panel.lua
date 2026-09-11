Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

UI.Panel = UI.Panel or CreateFrame("Frame", "GuardpointPanel", UI.Root)

function UI.Panel:ApplyPosition()
    local position = Guardpoint.Config:GetPosition()
    if type(position) ~= "table" then
        self:ClearAllPoints()
        self:SetPoint("CENTER", UI.Root, "CENTER", 0, 0)
        return
    end

    self:ClearAllPoints()
    self:SetPoint(
        position.point or "CENTER",
        UI.Root,
        position.relativePoint or "CENTER",
        position.x or 0,
        position.y or 0
    )
end

function UI.Panel:SavePosition()
    local point, _, relativePoint, x, y = self:GetPoint()
    if not point then
        return false
    end

    return Guardpoint.Config:SetPosition(
        point,
        relativePoint or point,
        x or 0,
        y or 0
    )
end

function UI.Panel:ApplyScale()
    local scale = tonumber(Guardpoint.Config:Get("scale")) or 1

    if scale <= 0 then
        scale = 1
    end

    self:SetScale(scale)
end

function UI.Panel:Initialize()
    self:SetParent(UI.Root)
    self:SetWidth(320)
    self:SetHeight(80)
    self:SetFrameLevel(UI.Root:GetFrameLevel() + 1)
    self:SetClampedToScreen(true)
    self:EnableMouse(true)
    self:SetMovable(true)
    self:RegisterForDrag("LeftButton")
    UI.Styles:ApplyFrame(self)
    self:ApplyScale()
    self:ApplyPosition()
    self:Hide()
end

function UI.Panel:ShowPanel()
    UI.Root:Show()
    self:Show()
end

function UI.Panel:HidePanel()
    self:Hide()
end

function UI.Panel:IsPanelShown()
    return self:IsShown() and UI.Root:IsShown()
end

function UI.Panel:Reset()
    Guardpoint.Config:SetPosition("CENTER", "CENTER", 0, 0)
    Guardpoint.Config:Set("scale", Guardpoint.Config.Defaults.scale)
    self:SetWidth(320)
    self:SetHeight(80)
    self:ApplyScale()
    self:ApplyPosition()
    self:Hide()
end

UI.Panel:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and not Guardpoint.Config:Get("locked") then
        self:StartMoving()
    end
end)

UI.Panel:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
        self:SavePosition()
    end
end)

UI.Panel:Initialize()
