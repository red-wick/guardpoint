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

    local text = parent:CreateFontString(nil, "OVERLAY")
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
