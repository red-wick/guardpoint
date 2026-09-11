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

function UI.Panel:GetContent()
    return self.Content
end

function UI.Panel:GetHeader()
    return self.Header
end

function UI.Panel:GetBody()
    return self.Body
end

function UI.Panel:GetTitle()
    return self.Title
end

function UI.Panel:SetTitle(text)
    if not self.Title then
        return false
    end

    self.Title:SetText(text or "")
    return true
end

function UI.Panel:GetStatus()
    return self.Status
end

function UI.Panel:SetStatus(text)
    if not self.Status then
        return false
    end

    self.Status:SetText(text or "")
    return true
end

function UI.Panel:RefreshState()
    local state = Guardpoint.State
    if not state then
        return false
    end

    local text = "Ready"

    if state.playerClass then
        text = "Class: " .. state.playerClass
    end

    if state.instance then
        text = text .. "\nInstance: " .. (state.instance.name or "Unknown")
    end

    if state.encounter then
        text = text .. "\nEncounter: " .. (state.encounter.name or "Unknown")
    end

    self:SetTitle("GuardPoint")
    self:SetStatus(text)
    return true
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

    if not self.Content then
        self.Content = UI.Elements:CreateContainer(self, "GuardpointPanelContent")
        self.Content:SetPoint("TOPLEFT", self, "TOPLEFT", 8, -8)
        self.Content:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8)
    end

    if not self.Header then
        self.Header = UI.Elements:CreateContainer(self.Content, "GuardpointPanelHeader")
        self.Header:SetPoint("TOPLEFT", self.Content, "TOPLEFT")
        self.Header:SetPoint("TOPRIGHT", self.Content, "TOPRIGHT")
        self.Header:SetHeight(20)
    end

    if not self.Body then
        self.Body = UI.Elements:CreateContainer(self.Content, "GuardpointPanelBody")
        self.Body:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -4)
        self.Body:SetPoint("BOTTOMRIGHT", self.Content, "BOTTOMRIGHT")
    end

    if not self.Title then
        self.Title = UI.Elements:CreateText(self.Header)
        self.Title:SetPoint("TOPLEFT", self.Header, "TOPLEFT", 4, 0)
        self.Title:SetPoint("BOTTOMRIGHT", self.Header, "BOTTOMRIGHT", -4, 0)
        self.Title:SetText("GuardPoint")
        UI.Styles:ApplyText(self.Title, 12)
    end

    if not self.Status then
        self.Status = UI.Elements:CreateText(self.Body)
        self.Status:SetPoint("TOPLEFT", self.Body, "TOPLEFT", 4, 0)
        self.Status:SetPoint("BOTTOMRIGHT", self.Body, "BOTTOMRIGHT", -4, 0)
        UI.Styles:ApplyText(self.Status, 11)
    end

    self:ApplyScale()
    self:ApplyPosition()
    self:Hide()
end

function UI.Panel:ShowPanel()
    UI.Root:Show()
    self:Show()
    self:RefreshState()
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
