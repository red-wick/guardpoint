Guardpoint.UI = Guardpoint.UI or {}

local UI = Guardpoint.UI

UI.Elements = UI.Elements or {}
local Elements = UI.Elements

function Elements:CreateFrame(frameType, name, parent)
    parent = parent or UI.Root

    if type(frameType) ~= "string" then
        return nil
    end

    return CreateFrame(frameType, name, parent)
end

function Elements:CreateButton(name, parent)
    local button = self:CreateFrame("Button", name, parent)
    if not button then
        return nil
    end

    button:SetWidth(100)
    button:SetHeight(24)

    return button
end

function Elements:CreateText(parent)
    parent = parent or UI.Root

    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("MIDDLE")

    return text
end

function Elements:CreateTexture(parent)
    parent = parent or UI.Root
    return parent:CreateTexture(nil, "ARTWORK")
end

function Elements:CreateContainer(parent, name)
    parent = parent or UI.Root
    return self:CreateFrame("Frame", name, parent)
end

function Elements:CreateRow(parent, height)
    local row = self:CreateContainer(parent)
    if not row then
        return nil
    end

    row:SetHeight(height or 24)
    return row
end

function Elements:CreateIcon(parent, size)
    local icon = self:CreateTexture(parent)
    if not icon then
        return nil
    end

    local iconSize = size or 24
    icon:SetWidth(iconSize)
    icon:SetHeight(iconSize)

    return icon
end
